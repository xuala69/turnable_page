import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../turnable_page.dart';
import '../page/page_flip.dart';
import '../page/page_host.dart';
import 'paper_widget.dart';
import 'turnable_book_render_object_widget.dart';

class TurnablePageView extends StatefulWidget {
  final PageFlipController? controller;
  final PageWidgetBuilder builder;
  final int pageCount;
  final TurnablePageCallback? onPageChanged;
  final FlipSettings settings;
  final double aspectRatio;
  final Size bookSize;
  final PaperBoundaryDecoration paperBoundaryDecoration;
  final bool pagesBoundaryIsEnabled;

  const TurnablePageView({
    super.key,
    this.controller,
    this.onPageChanged,
    required this.builder,
    required this.pageCount,
    required this.aspectRatio,
    required this.bookSize,
    required this.settings,
    required this.paperBoundaryDecoration,
    this.pagesBoundaryIsEnabled = true,
  });

  @override
  State<TurnablePageView> createState() => _TurnablePageViewState();
}

class _TurnablePageViewState extends State<TurnablePageView> {
  /// PageFlip core logic
  late PageFlip _pageFlip;
  late int _currentPageIndex;
  final Map<int, Widget> _pageCache = {};
  final List<int> _cacheOrder = [];

  /// Get the adjusted settings for the PageFlip instance
  FlipSettings get _settings => widget.settings.copyWith(
    width: widget.bookSize.width,
    height: widget.bookSize.height,
    startPage: widget.settings.startPageIndex,
  );

  @override
  void initState() {
    _currentPageIndex = widget.settings.startPageIndex;
    _pageFlip = PageFlip(_settings);
    _setupPageFlipEventsAndController();
    super.initState();
  }

  Future<void> _setupPageFlipEventsAndController() async {
    widget.controller?.initializeController(pageFlip: _pageFlip);
    _pageFlip.on('flip', (_) {
      if (!mounted) return;
      final newIndex = _pageFlip.getCurrentPageIndex();
      final left = newIndex.clamp(0, widget.pageCount - 1);
      final right = (newIndex + 1 < widget.pageCount) ? newIndex + 1 : -1;
      widget.settings.startPageIndex = left;
      _currentPageIndex = left;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pageFlip.updateSetting(_settings);
        setState(() {});
        widget.onPageChanged?.call(left, right);
      });
    });
  }

  List<int> _activePageIndices() {
    final indices = <int>{};
    if (widget.settings.usePortrait) {
      indices.addAll([
        _currentPageIndex - 1,
        _currentPageIndex,
        _currentPageIndex + 1,
      ]);
    } else {
      indices.addAll([
        _currentPageIndex - 2,
        _currentPageIndex - 1,
        _currentPageIndex,
        _currentPageIndex + 1,
        _currentPageIndex + 2,
        _currentPageIndex + 3,
      ]);
    }
    indices.removeWhere((i) => i < 0 || i >= widget.pageCount);
    final sorted = indices.toList()..sort();
    return sorted;
  }

  void _ensurePageCache(List<int> activeIndices, BuildContext context) {
    final maxCacheSize = activeIndices.length * 2;

    for (final index in activeIndices) {
      if (!_pageCache.containsKey(index)) {
        _pageCache[index] = widget.builder(context, index);
      }
      _cacheOrder.remove(index);
      _cacheOrder.add(index);
    }

    final activeSet = activeIndices.toSet();
    final evicted = _pageCache.keys
        .where((index) => !activeSet.contains(index))
        .toList();
    for (final index in evicted) {
      _pageCache.remove(index);
      _cacheOrder.remove(index);
    }

    while (_cacheOrder.length > maxCacheSize) {
      final oldest = _cacheOrder.removeAt(0);
      _pageCache.remove(oldest);
    }
  }

  List<Widget> _buildActiveChildren(BuildContext context) {
    final activeIndices = _activePageIndices();
    _ensurePageCache(activeIndices, context);
    return activeIndices
        .map(
          (index) => PageHost(
            key: ValueKey(index),
            index: index,
            child: _pageCache[index]!,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return PaperWidget(
      size: widget.bookSize,
      isSinglePage: widget.settings.usePortrait,
      paperBoundaryDecoration: widget.paperBoundaryDecoration,
      isEnabled: widget.pagesBoundaryIsEnabled,
      child: TurnableBookRenderObjectWidget(
        pageCount: widget.pageCount,
        settings: _settings,
        pageFlip: _pageFlip,
        children: _buildActiveChildren(context),
      ),
    );
  }
}
