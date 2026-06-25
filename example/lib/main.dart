import 'package:flutter/material.dart';
import 'package:turnable_page/turnable_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turnable Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _AnimationTestPage(),
    );
  }
}

class _AnimationTestPage extends StatefulWidget {
  const _AnimationTestPage();

  @override
  _AnimationTestPageState createState() => _AnimationTestPageState();
}

class _AnimationTestPageState extends State<_AnimationTestPage> {
  late PageFlipController _controller;
  final List<String> _displayItemsFromMockApi = [];

  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _flipCountNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _controller = PageFlipController();
    _displayItemsFromMockApi.addAll(["1", "2", "3", "4", "5", "6", "7", "8"]);
  }

  @override
  void dispose() {
    _currentPageNotifier.dispose();
    _flipCountNotifier.dispose();
    super.dispose();
  }

  Widget _buildLoadingPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.pinkAccent),
          SizedBox(height: 20),
          Text("Loading Page...", style: TextStyle(color: Colors.pinkAccent)),
        ],
      ),
    );
  }

  Widget _buildTestPage(int index, BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.primaries[index % Colors.primaries.length].shade300,
            Colors.primaries[index % Colors.primaries.length].shade600,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Test content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Test Page ${_displayItemsFromMockApi[index]}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Swipe to turn the page',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
                SizedBox(height: 40),
                // Interactive button for testing
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Page ${_displayItemsFromMockApi[index]} button tapped',
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(Icons.touch_app),
                  label: Text('Label'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                        Colors.primaries[index % Colors.primaries.length],
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          // Page info overlay
          Positioned(
            top: 20,
            left: 20,
            child: ValueListenableBuilder<int>(
              valueListenable: _flipCountNotifier,
              builder: (context, flipCount, child) {
                return ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, child) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Animation Test\nCurrent Page: ${currentPage + 1}\nNumber of Flips: $flipCount',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _displayItemsFromMockApi.isEmpty
          ? null
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _controller.previousPage();
                  },
                  child: Icon(Icons.arrow_back_ios_new_rounded),
                ),
                FloatingActionButton(
                  onPressed: () {
                    _controller.nextPage();
                  },
                  child: Icon(Icons.arrow_forward_ios_rounded),
                ),
              ],
            ),
      body: Center(
        child: TurnablePage(
          key: UniqueKey(),
          controller: _controller,
          pageCount: _displayItemsFromMockApi.isEmpty
              ? 1
              : _displayItemsFromMockApi.length,
          pageViewMode: PageViewMode.single,
          paperBoundaryDecoration: PaperBoundaryDecoration.modern,
          settings: FlipSettings(
            hideLeftShadow: true,
            onlyVerticalPageFlip: true,
            drawShadow: true,
            flippingTime: 800,
            swipeDistance: 60.0,
            cornerTriggerAreaSize: 0.15,
            usePortrait: false,
          ),
          onPageChanged: (leftPageIndex, rightPageIndex) {
            // log('Page: $leftPageIndex, $rightPageIndex');
            _currentPageNotifier.value = rightPageIndex;
            _flipCountNotifier.value = _flipCountNotifier.value + 1;
          },
          builder: (context, pageIndex, constraints) {
            if (_displayItemsFromMockApi.isEmpty) {
              return _buildLoadingPage();
            }
            return _buildTestPage(pageIndex, constraints);
          },
        ),
      ),
    );
  }
}
