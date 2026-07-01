import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:turnable_page/turnable_page.dart';

void main() async {
  await pdfrxFlutterInitialize();
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
  PdfDocument? document;
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);
  bool loadingPDF = true;

  @override
  void initState() {
    super.initState();
    controller = PageFlipController();
    _loadDocument();
  }

  void _loadDocument() async {
    final doc = await PdfDocument.openAsset(sampleAssetPath);
    setState(() {
      document = doc;
      loadingPDF = false;
    });
  }

  @override
  void dispose() {
    currentPageNotifier.dispose();
    document?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingPDF) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (document == null) {
      return const Center(child: Text('Failed to load PDF'));
    }

    final totalPages = document!.pages.length;
    if (totalPages == 0) {
      return const Center(child: Text('No pages found in PDF'));
    }
    // final ratio = MediaQuery.of(context).size.aspectRatio;
    return Scaffold(
      body: TurnablePage(
        controller: controller,
        pageCount: totalPages,
        pageViewMode: PageViewMode.single,
        enablePinchZoom: true,
        minScale: 1.0,
        maxScale: 4.0,
        zoomThreshold: 1.01,
        zoomNormalizeThreshold: 1.04,
        topOverlayAutoHide: true,
        topControlsAutoHideDelay: const Duration(seconds: 2),
        topOverlayAnimationDuration: const Duration(milliseconds: 220),
        bottomOverlayAutoHide: false,
        bottomOverlayAnimationDuration: const Duration(milliseconds: 320),
        paperBoundaryDecoration: PaperBoundaryDecoration.modern,
        settings: FlipSettings(
          startPageIndex: currentPageNotifier.value,
          drawShadow: true,
          flippingTime: 700,
          swipeDistance: 42,
          cornerTriggerAreaSize: 0.30,
        ),
        topOverlay: _topWidget(),
        bottomOverlay: _bottomWidget(totalPages),
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
      ),
    );
  }

  Widget _topWidget() {
    return Align(
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
    );
  }

  Widget _bottomWidget(int totalPages) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}
