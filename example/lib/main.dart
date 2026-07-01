import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:turnable_page/turnable_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turnable Page + pdfrx',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D3B66)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PdfBookDemoPage(),
    );
  }
}

class PdfBookDemoPage extends StatefulWidget {
  const PdfBookDemoPage({super.key});

  @override
  State<PdfBookDemoPage> createState() => _PdfBookDemoPageState();
}

class _PdfBookDemoPageState extends State<PdfBookDemoPage> {
  static const String sampleAssetPath = 'assets/PDF32000_2008.pdf';

  late final PageFlipController controller;
  late final Future<PdfDocument> _documentFuture;
  PdfDocument? _document;
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    controller = PageFlipController();
    _documentFuture = _loadDocument();
  }

  Future<PdfDocument> _loadDocument() async {
    await pdfrxFlutterInitialize();
    final document = await PdfDocument.openAsset(sampleAssetPath);
    _document = document;
    return document;
  }

  @override
  void dispose() {
    currentPageNotifier.dispose();
    _document?.dispose();
    super.dispose();
  }

  void _scheduleSetState() {
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void _handleZoomChanged(bool zoomed) {
    if (_isZoomed != zoomed) {
      _isZoomed = zoomed;
      _scheduleSetState();
    }
  }

  Widget buildPdfPage(PdfDocument document, int pageIndex) {
    return ZoomablePdfPage(
      key: ValueKey<int>(pageIndex),
      document: document,
      pageNumber: pageIndex + 1,
      onZoomChanged: (zoomed) {
        _handleZoomChanged(zoomed);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TurnablePage + pdfrx'),
        actions: [
          IconButton(
            onPressed: controller.previousPage,
            tooltip: 'Previous page',
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          IconButton(
            onPressed: controller.nextPage,
            tooltip: 'Next page',
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sample PDF: PDF32000_2008.pdf',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    _isZoomed ? 'Zoom: ON' : 'Zoom: OFF',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: currentPageNotifier,
                  builder: (context, currentPage, child) {
                    return Text(
                      'Current: ${currentPage + 1}',
                      style: Theme.of(context).textTheme.labelLarge,
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<PdfDocument>(
              future: _documentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load PDF: ${snapshot.error}'),
                  );
                }

                final document = snapshot.data;
                if (document == null) {
                  return const Center(child: Text('Failed to load PDF'));
                }

                final totalPages = document.pages.length;
                if (totalPages == 0) {
                  return const Center(child: Text('No pages found in PDF'));
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TurnablePage(
                    controller: controller,
                    pageCount: totalPages,
                    pageViewMode: PageViewMode.single,
                    interactionEnabled: !_isZoomed,
                    paperBoundaryDecoration: PaperBoundaryDecoration.modern,
                    settings: FlipSettings(
                      startPageIndex: currentPageNotifier.value,
                      drawShadow: true,
                      flippingTime: 700,
                      swipeDistance: 42,
                      cornerTriggerAreaSize: 0.30,
                    ),
                    onPageChanged: (leftPageIndex, rightPageIndex) {
                      final newPage = rightPageIndex >= 0
                          ? rightPageIndex
                          : leftPageIndex;

                      currentPageNotifier.value = newPage;

                      if (_isZoomed) {
                        _isZoomed = false;
                        _scheduleSetState();
                      }
                    },
                    builder: (context, pageIndex, constraints) {
                      return buildPdfPage(document, pageIndex);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ZoomablePdfPage extends StatefulWidget {
  const ZoomablePdfPage({
    super.key,
    required this.document,
    required this.pageNumber,
    required this.onZoomChanged,
  });

  final PdfDocument document;
  final int pageNumber;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<ZoomablePdfPage> createState() => _ZoomablePdfPageState();
}

class _ZoomablePdfPageState extends State<ZoomablePdfPage> {
  late final TransformationController _transformationController;
  bool _isZoomed = false;
  static const double _zoomThreshold = 1.01;
  static const double _normalizeThreshold = 1.04;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    if (_isZoomed) {
      widget.onZoomChanged(false);
      _isZoomed = false;
    }
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final zoomed =
        _transformationController.value.getMaxScaleOnAxis() > _zoomThreshold;
    if (zoomed == _isZoomed) {
      return;
    }
    _isZoomed = zoomed;
    widget.onZoomChanged(zoomed);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale <= _normalizeThreshold) {
      _transformationController.value = Matrix4.identity();
      if (_isZoomed) {
        _isZoomed = false;
        widget.onZoomChanged(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        panEnabled: true,
        scaleEnabled: true,
        onInteractionEnd: _onInteractionEnd,
        clipBehavior: Clip.hardEdge,
        child: PdfPageView(
          document: widget.document,
          pageNumber: widget.pageNumber,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
