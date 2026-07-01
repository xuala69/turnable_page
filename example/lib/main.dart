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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PdfDocument>(
        future: _documentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load PDF: ${snapshot.error}'));
          }

          final document = snapshot.data;
          if (document == null) {
            return const Center(child: Text('Failed to load PDF'));
          }

          final totalPages = document.pages.length;
          if (totalPages == 0) {
            return const Center(child: Text('No pages found in PDF'));
          }

          return TurnablePage(
            controller: controller,
            pageCount: totalPages,
            pageViewMode: PageViewMode.single,
            enablePinchZoom: true,
            minScale: 1.0,
            maxScale: 4.0,
            zoomThreshold: 1.01,
            zoomNormalizeThreshold: 1.04,
            paperBoundaryDecoration: PaperBoundaryDecoration.modern,
            settings: FlipSettings(
              startPageIndex: currentPageNotifier.value,
              drawShadow: true,
              flippingTime: 700,
              swipeDistance: 42,
              cornerTriggerAreaSize: 0.30,
            ),
            topOverlay: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: controller.previousPage,
                        tooltip: 'Previous page',
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      IconButton(
                        onPressed: controller.nextPage,
                        tooltip: 'Next page',
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomOverlay: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ValueListenableBuilder<int>(
                      valueListenable: currentPageNotifier,
                      builder: (context, currentPage, child) {
                        return Text(
                          'Page ${currentPage + 1} / $totalPages',
                          style: const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            onPageChanged: (leftPageIndex, rightPageIndex) {
              currentPageNotifier.value = rightPageIndex >= 0
                  ? rightPageIndex
                  : leftPageIndex;
            },
            builder: (context, pageIndex, constraints) {
              return ColoredBox(
                color: Colors.white,
                child: PdfPageView(
                  document: document,
                  pageNumber: pageIndex + 1,
                  alignment: Alignment.center,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
