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
  final bool interactionEnabled;
  final bool enablePinchZoom;
  final double minScale;
  final double maxScale;
  final double zoomThreshold;
  final double zoomNormalizeThreshold;
  final double doubleTapZoomScale;
  final DoubleTapZoomAnchor doubleTapZoomAnchor;

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
    this.interactionEnabled = true,
    this.enablePinchZoom = false,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.zoomThreshold = 1.01,
    this.zoomNormalizeThreshold = 1.04,
    required this.doubleTapZoomScale,
    this.doubleTapZoomAnchor = DoubleTapZoomAnchor.tapPoint,
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
  final Set<int> _zoomedPages = <int>{};

  bool get _isAnyPageZoomed => _zoomedPages.isNotEmpty;

  void _safeSetState() {
    if (!mounted) {
      return;
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _handlePageZoomChanged({required int pageIndex, required bool zoomed}) {
    final hadAnyZoom = _isAnyPageZoomed;
    if (zoomed) {
      _zoomedPages.add(pageIndex);
    } else {
      _zoomedPages.remove(pageIndex);
    }
    if (hadAnyZoom != _isAnyPageZoomed) {
      _safeSetState();
    }
  }

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
      if (_zoomedPages.isNotEmpty) {
        _zoomedPages.clear();
      }

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
    return activeIndices.map((index) {
      final baseChild = _pageCache[index]!;
      final child = widget.enablePinchZoom
          ? _TurnableZoomWrapper(
              key: ValueKey('zoom-$index'),
              minScale: widget.minScale,
              maxScale: widget.maxScale,
              zoomThreshold: widget.zoomThreshold,
              zoomNormalizeThreshold: widget.zoomNormalizeThreshold,
              doubleTapZoomScale: widget.doubleTapZoomScale,
              doubleTapZoomAnchor: widget.doubleTapZoomAnchor,
              onZoomChanged: (zoomed) {
                _handlePageZoomChanged(pageIndex: index, zoomed: zoomed);
              },
              child: baseChild,
            )
          : baseChild;

      return PageHost(key: ValueKey(index), index: index, child: child);
    }).toList();
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
        interactionEnabled: widget.interactionEnabled && !_isAnyPageZoomed,
        children: _buildActiveChildren(context),
      ),
    );
  }
}

class _TurnableZoomWrapper extends StatefulWidget {
  const _TurnableZoomWrapper({
    super.key,
    required this.child,
    required this.minScale,
    required this.maxScale,
    required this.zoomThreshold,
    required this.zoomNormalizeThreshold,
    required this.doubleTapZoomScale,
    required this.doubleTapZoomAnchor,
    required this.onZoomChanged,
  });

  final Widget child;
  final double minScale;
  final double maxScale;
  final double zoomThreshold;
  final double zoomNormalizeThreshold;
  final double doubleTapZoomScale;
  final DoubleTapZoomAnchor doubleTapZoomAnchor;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_TurnableZoomWrapper> createState() => _TurnableZoomWrapperState();
}

class _TurnableZoomWrapperState extends State<_TurnableZoomWrapper> {
  late final TransformationController _controller;
  bool _isZoomed = false;
  TapDownDetails? _lastDoubleTapDown;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
    _controller.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    if (_isZoomed) {
      widget.onZoomChanged(false);
      _isZoomed = false;
    }
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final zoomed = _controller.value.getMaxScaleOnAxis() > widget.zoomThreshold;
    if (zoomed == _isZoomed) {
      return;
    }
    _isZoomed = zoomed;
    widget.onZoomChanged(zoomed);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    final scale = _controller.value.getMaxScaleOnAxis();
    if (scale <= widget.zoomNormalizeThreshold) {
      _controller.value = Matrix4.identity();
      if (_isZoomed) {
        _isZoomed = false;
        widget.onZoomChanged(false);
      }
    }
  }

  void _onDoubleTapDown(TapDownDetails details) {
    _lastDoubleTapDown = details;
  }

  void _onDoubleTap() {
    final currentScale = _controller.value.getMaxScaleOnAxis();
    if (currentScale > widget.zoomThreshold) {
      _controller.value = Matrix4.identity();
      return;
    }

    final targetScale = widget.doubleTapZoomScale
        .clamp(widget.minScale, widget.maxScale)
        .toDouble();

    if (widget.doubleTapZoomAnchor == DoubleTapZoomAnchor.pageCenter) {
      _controller.value = Matrix4.diagonal3Values(
        targetScale,
        targetScale,
        1.0,
      );
      return;
    }

    final localPosition = _lastDoubleTapDown?.localPosition;
    if (localPosition == null) {
      _controller.value = Matrix4.diagonal3Values(
        targetScale,
        targetScale,
        1.0,
      );
      return;
    }

    final matrix = Matrix4.diagonal3Values(targetScale, targetScale, 1.0)
      ..setTranslationRaw(
        -localPosition.dx * (targetScale - 1.0),
        -localPosition.dy * (targetScale - 1.0),
        0.0,
      );
    _controller.value = matrix;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: widget.minScale,
        maxScale: widget.maxScale,
        panEnabled: true,
        scaleEnabled: true,
        onInteractionEnd: _onInteractionEnd,
        clipBehavior: Clip.hardEdge,
        child: widget.child,
      ),
    );
  }
}
