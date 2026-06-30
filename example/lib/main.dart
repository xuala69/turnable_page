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
  final ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    controller = PageFlipController();
  }

  @override
  void dispose() {
    currentPageNotifier.dispose();
    super.dispose();
  }

  Widget buildPdfPage(PdfDocument document, int pageIndex) {
    return ColoredBox(
      color: Colors.white,
      child: PdfPageView(
        document: document,
        pageNumber: pageIndex + 1,
        alignment: Alignment.center,
      ),
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
            child: PdfDocumentViewBuilder.asset(
              sampleAssetPath,
              builder: (context, document) {
                if (document == null) {
                  return const Center(child: CircularProgressIndicator());
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
                    paperBoundaryDecoration: PaperBoundaryDecoration.modern,
                    settings: FlipSettings(
                      drawShadow: true,
                      flippingTime: 700,
                      swipeDistance: 70,
                      cornerTriggerAreaSize: 0.14,
                    ),
                    onPageChanged: (leftPageIndex, rightPageIndex) {
                      currentPageNotifier.value = rightPageIndex >= 0
                          ? rightPageIndex
                          : leftPageIndex;
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
