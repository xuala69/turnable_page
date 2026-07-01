import 'dart:async';

import 'package:flutter/material.dart';

import '../enums/page_view_mode.dart';
import '../flip/flip_settings.dart';
import '../model/paper_boundary_decoration.dart';
import 'page_flip_controller.dart';
import 'turnable_page_view.dart';

/// A widget that renders a book-like page flip interface.
///
/// Use [TurnablePage] when you want to display a sequence of widgets with
/// realistic page-turn animations and interactive page content.
class TurnablePage extends StatelessWidget {
  /// Optional controller for programmatically controlling page navigation.
  final PageFlipController? controller;

  /// A builder that creates page widgets on demand.
  ///
  /// The builder is invoked for each active page index and may be called again
  /// when pages are evicted from the internal cache.
  final TurnableBuilder builder;

  /// The total number of pages in the book.
  final int pageCount;

  /// Callback fired when the visible page changes.
  ///
  /// The first argument is the leftmost visible page index; the second
  /// argument is the rightmost visible page index or -1 when absent.
  final TurnablePageCallback? onPageChanged;

  /// Flip animation and gesture settings.
  final FlipSettings settings;

  /// Layout mode: single page or double page spread.
  final PageViewMode pageViewMode;

  /// Whether the book should automatically resize to fill available space.
  final bool autoResponseSize;

  /// Styling for the paper boundary decoration.
  final PaperBoundaryDecoration paperBoundaryDecoration;

  /// Optional custom page aspect ratio.
  final double? aspectRatio;

  /// Whether page boundary decoration is enabled.
  final bool pagesBoundaryIsEnabled;

  /// Optional widget rendered in a top safe area overlay above the book.
  final Widget? topOverlay;

  /// Optional widget rendered in a bottom safe area overlay above the book.
  final Widget? bottomOverlay;

  /// Whether top/bottom overlays auto-hide after a delay.
  final bool autoHideOverlays;

  /// How long overlays stay visible before auto-hide starts.
  final Duration overlayVisibleDuration;

  /// Duration of the overlay show/hide animation.
  final Duration overlayAnimationDuration;

  /// Custom animation builder for overlay transitions.
  final TurnableOverlayAnimationBuilder? overlayAnimationBuilder;

  /// Curve used by the default overlay animation.
  final Curve overlayAnimationCurve;

  /// Whether page content should support built-in pinch zoom.
  final bool enablePinchZoom;

  /// Minimum scale used by built-in pinch zoom.
  final double minScale;

  /// Maximum scale used by built-in pinch zoom.
  final double maxScale;

  /// Scale threshold above which page-turn gestures are temporarily locked.
  final double zoomThreshold;

  /// Scale threshold used to normalize zoom back to identity on interaction end.
  final double zoomNormalizeThreshold;

  /// Scale used when double-tapping to zoom in.
  final double doubleTapZoomScale;

  final bool interactionEnabled;

  TurnablePage({
    super.key,
    this.controller,
    this.aspectRatio,
    required this.builder,
    required this.pageCount,
    this.onPageChanged,
    this.pageViewMode = PageViewMode.single,
    this.autoResponseSize = true,
    this.paperBoundaryDecoration = PaperBoundaryDecoration.vintage,
    FlipSettings? settings,
    this.pagesBoundaryIsEnabled = true,
    this.topOverlay,
    this.bottomOverlay,
    this.autoHideOverlays = false,
    this.overlayVisibleDuration = const Duration(seconds: 2),
    this.overlayAnimationDuration = const Duration(milliseconds: 260),
    this.overlayAnimationBuilder,
    this.overlayAnimationCurve = Curves.easeOutCubic,
    this.enablePinchZoom = false,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.zoomThreshold = 1.01,
    this.zoomNormalizeThreshold = 1.04,
    this.doubleTapZoomScale = 2.0,
    this.interactionEnabled = true,
  }) : settings = settings ?? FlipSettings() {
    if (settings != null) {
      assert(
        this.settings.startPageIndex >= 0,
        'Page count must be greater than 0',
      );
      assert(
        this.settings.startPageIndex < pageCount,
        'Start page index must be less than page count',
      );
    }
  }

  Size _calculateBookSize({
    required double maxWidth,
    required double maxHeight,
    required double aspectRatio,
  }) {
    double height = maxWidth / aspectRatio;
    if (height > maxHeight) {
      height = maxHeight;
      maxWidth = height * aspectRatio;
    }
    return Size(maxWidth, height);
  }

  double _getAspectRatio(bool isMobile) {
    if (!autoResponseSize && pageViewMode == PageViewMode.single) {
      return aspectRatio ?? 2 / 3;
    }
    if (pageViewMode == PageViewMode.single) {
      return aspectRatio ?? 2 / 3 * (isMobile ? 1 : 2);
    }
    return aspectRatio ?? (2 / 3) * 2;
  }

  FlipSettings _getAdjustedSetting(bool isMobile) {
    if (!autoResponseSize && pageViewMode == PageViewMode.single) {
      return settings.copyWith(usePortrait: true);
    }
    final usePortrait = pageViewMode == PageViewMode.single && isMobile;
    return settings.copyWith(usePortrait: usePortrait);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final aspectRatio = _getAspectRatio(isMobile);
        FlipSettings adjustedSettings = _getAdjustedSetting(isMobile);

        final bookSize = _calculateBookSize(
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
          aspectRatio: aspectRatio,
        );
        adjustedSettings = adjustedSettings.copyWith(
          width: bookSize.width,
          height: bookSize.height,
        );

        final pageView = TurnablePageView(
          builder: (context, index) => builder(context, index, constraints),
          bookSize: bookSize,
          settings: adjustedSettings,
          pageCount: pageCount,
          controller: controller,
          aspectRatio: aspectRatio,
          onPageChanged: onPageChanged,
          pagesBoundaryIsEnabled: pagesBoundaryIsEnabled,
          interactionEnabled: interactionEnabled,
          enablePinchZoom: enablePinchZoom,
          minScale: minScale,
          maxScale: maxScale,
          zoomThreshold: zoomThreshold,
          zoomNormalizeThreshold: zoomNormalizeThreshold,
          doubleTapZoomScale: doubleTapZoomScale,
          paperBoundaryDecoration: paperBoundaryDecoration,
        );

        if (topOverlay == null && bottomOverlay == null) {
          return pageView;
        }

        return _TurnableOverlayContainer(
          topOverlay: topOverlay,
          bottomOverlay: bottomOverlay,
          autoHideOverlays: autoHideOverlays,
          overlayVisibleDuration: overlayVisibleDuration,
          overlayAnimationDuration: overlayAnimationDuration,
          overlayAnimationBuilder: overlayAnimationBuilder,
          overlayAnimationCurve: overlayAnimationCurve,
          child: pageView,
        );
      },
    );
  }
}

class _TurnableOverlayContainer extends StatefulWidget {
  const _TurnableOverlayContainer({
    required this.child,
    required this.topOverlay,
    required this.bottomOverlay,
    required this.autoHideOverlays,
    required this.overlayVisibleDuration,
    required this.overlayAnimationDuration,
    required this.overlayAnimationBuilder,
    required this.overlayAnimationCurve,
  });

  final Widget child;
  final Widget? topOverlay;
  final Widget? bottomOverlay;
  final bool autoHideOverlays;
  final Duration overlayVisibleDuration;
  final Duration overlayAnimationDuration;
  final TurnableOverlayAnimationBuilder? overlayAnimationBuilder;
  final Curve overlayAnimationCurve;

  @override
  State<_TurnableOverlayContainer> createState() =>
      _TurnableOverlayContainerState();
}

class _TurnableOverlayContainerState extends State<_TurnableOverlayContainer> {
  bool _overlaysVisible = true;
  Timer? _hideTimer;

  bool get _hasAnyOverlay =>
      widget.topOverlay != null || widget.bottomOverlay != null;

  @override
  void initState() {
    super.initState();
    if (_hasAnyOverlay && widget.autoHideOverlays) {
      _scheduleHide();
    }
  }

  @override
  void didUpdateWidget(covariant _TurnableOverlayContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_hasAnyOverlay) {
      _hideTimer?.cancel();
      _hideTimer = null;
      _overlaysVisible = true;
      return;
    }

    if (!widget.autoHideOverlays) {
      _hideTimer?.cancel();
      _hideTimer = null;
      return;
    }

    if (!oldWidget.autoHideOverlays && widget.autoHideOverlays) {
      _toggleOverlays();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(widget.overlayVisibleDuration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _overlaysVisible = false;
      });
    });
  }

  void _toggleOverlays() {
    if (!_hasAnyOverlay) {
      return;
    }

    if (_overlaysVisible) {
      setState(() {
        _overlaysVisible = false;
      });
      _hideTimer?.cancel();
      _hideTimer = null;
      return;
    }

    setState(() {
      _overlaysVisible = true;
    });

    if (widget.autoHideOverlays) {
      _scheduleHide();
    }
  }

  Widget _defaultAnimationBuilder(Animation<double> animation, Widget child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: widget.overlayAnimationCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.06),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  Widget _buildAnimatedOverlay({required Widget child, required bool top}) {
    final visibleChild = _overlaysVisible
        ? child
        : const SizedBox(key: ValueKey('overlay-hidden'));

    return IgnorePointer(
      ignoring: !_overlaysVisible,
      child: AnimatedSwitcher(
        duration: widget.overlayAnimationDuration,
        transitionBuilder: (switchChild, animation) {
          final builder =
              widget.overlayAnimationBuilder ??
              (context, anim, target) => _defaultAnimationBuilder(anim, target);
          return builder(context, animation, switchChild);
        },
        child: KeyedSubtree(
          key: ValueKey('overlay-${top ? 'top' : 'bottom'}-$_overlaysVisible'),
          child: visibleChild,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _toggleOverlays,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          if (widget.topOverlay != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: _buildAnimatedOverlay(
                  child: widget.topOverlay!,
                  top: true,
                ),
              ),
            ),
          if (widget.bottomOverlay != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _buildAnimatedOverlay(
                  child: widget.bottomOverlay!,
                  top: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Builds the widget for a given page index.
///
/// The [constraints] parameter is the layout constraints of the book and
/// can be used to size page content adaptively.
typedef TurnableBuilder =
    Widget Function(
      BuildContext context,
      int pageIndex,
      BoxConstraints constraints,
    );

/// Called when the current visible page spread changes.
typedef TurnablePageCallback =
    void Function(int leftPageIndex, int rightPageIndex);

/// Builds overlay show/hide animation for [TurnablePage] top/bottom overlays.
typedef TurnableOverlayAnimationBuilder =
    Widget Function(
      BuildContext context,
      Animation<double> animation,
      Widget child,
    );

/// Internal builder type used by [TurnablePageView].
typedef PageWidgetBuilder = Widget Function(BuildContext context, int index);
