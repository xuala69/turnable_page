import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  /// Whether the top overlay auto-hides after a delay.
  final bool? topOverlayAutoHide;

  /// Whether the bottom overlay auto-hides after a delay.
  final bool? bottomOverlayAutoHide;

  /// How long controls stay visible before auto-hide starts.
  final Duration? controlsAutoHideDelay;

  /// How long the top overlay stays visible before auto-hide starts.
  final Duration? topControlsAutoHideDelay;

  /// How long the bottom overlay stays visible before auto-hide starts.
  final Duration? bottomControlsAutoHideDelay;

  /// Legacy alias for [controlsAutoHideDelay].
  @Deprecated('Use controlsAutoHideDelay')
  final Duration? overlayVisibleDuration;

  /// Duration of the overlay show/hide animation.
  final Duration overlayAnimationDuration;

  /// Duration of the top overlay show/hide animation.
  final Duration? topOverlayAnimationDuration;

  /// Duration of the bottom overlay show/hide animation.
  final Duration? bottomOverlayAnimationDuration;

  /// Custom animation builder for overlay transitions.
  final TurnableOverlayAnimationBuilder? overlayAnimationBuilder;

  /// Custom animation builder for the top overlay transition.
  final TurnableOverlayAnimationBuilder? topOverlayAnimationBuilder;

  /// Custom animation builder for the bottom overlay transition.
  final TurnableOverlayAnimationBuilder? bottomOverlayAnimationBuilder;

  /// Curve used by the default overlay animation.
  final Curve overlayAnimationCurve;

  /// Curve used by the default top overlay animation.
  final Curve? topOverlayAnimationCurve;

  /// Curve used by the default bottom overlay animation.
  final Curve? bottomOverlayAnimationCurve;

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

  /// Where double-tap zoom should anchor.
  final DoubleTapZoomAnchor doubleTapZoomAnchor;

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
    this.topOverlayAutoHide,
    this.bottomOverlayAutoHide,
    this.controlsAutoHideDelay,
    this.topControlsAutoHideDelay,
    this.bottomControlsAutoHideDelay,
    @Deprecated('Use controlsAutoHideDelay') this.overlayVisibleDuration,
    this.overlayAnimationDuration = const Duration(milliseconds: 260),
    this.topOverlayAnimationDuration,
    this.bottomOverlayAnimationDuration,
    this.overlayAnimationBuilder,
    this.topOverlayAnimationBuilder,
    this.bottomOverlayAnimationBuilder,
    this.overlayAnimationCurve = Curves.easeOutCubic,
    this.topOverlayAnimationCurve,
    this.bottomOverlayAnimationCurve,
    this.enablePinchZoom = false,
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.zoomThreshold = 1.01,
    this.zoomNormalizeThreshold = 1.04,
    this.doubleTapZoomScale = 2.0,
    this.doubleTapZoomAnchor = DoubleTapZoomAnchor.tapPoint,
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
          doubleTapZoomAnchor: doubleTapZoomAnchor,
          paperBoundaryDecoration: paperBoundaryDecoration,
        );

        if (topOverlay == null && bottomOverlay == null) {
          return pageView;
        }

        return _TurnableOverlayContainer(
          topOverlay: topOverlay,
          bottomOverlay: bottomOverlay,
          topOverlayAutoHide: _resolveTopOverlayAutoHide(),
          bottomOverlayAutoHide: _resolveBottomOverlayAutoHide(),
          topControlsAutoHideDelay: _resolveTopControlsAutoHideDelay(),
          bottomControlsAutoHideDelay: _resolveBottomControlsAutoHideDelay(),
          topOverlayAnimationDuration:
              topOverlayAnimationDuration ?? overlayAnimationDuration,
          bottomOverlayAnimationDuration:
              bottomOverlayAnimationDuration ?? overlayAnimationDuration,
          topOverlayAnimationBuilder: topOverlayAnimationBuilder,
          bottomOverlayAnimationBuilder: bottomOverlayAnimationBuilder,
          topOverlayAnimationCurve:
              topOverlayAnimationCurve ?? overlayAnimationCurve,
          bottomOverlayAnimationCurve:
              bottomOverlayAnimationCurve ?? overlayAnimationCurve,
          child: pageView,
        );
      },
    );
  }

  bool _resolveTopOverlayAutoHide() {
    return topOverlayAutoHide ?? autoHideOverlays;
  }

  bool _resolveBottomOverlayAutoHide() {
    return bottomOverlayAutoHide ?? autoHideOverlays;
  }

  Duration _resolveTopControlsAutoHideDelay() {
    return topControlsAutoHideDelay ??
        controlsAutoHideDelay ??
        overlayVisibleDuration ??
        const Duration(seconds: 2);
  }

  Duration _resolveBottomControlsAutoHideDelay() {
    return bottomControlsAutoHideDelay ??
        controlsAutoHideDelay ??
        overlayVisibleDuration ??
        const Duration(seconds: 2);
  }
}

class _TurnableOverlayContainer extends StatefulWidget {
  const _TurnableOverlayContainer({
    required this.child,
    required this.topOverlay,
    required this.bottomOverlay,
    required this.topOverlayAutoHide,
    required this.bottomOverlayAutoHide,
    required this.topControlsAutoHideDelay,
    required this.bottomControlsAutoHideDelay,
    required this.topOverlayAnimationDuration,
    required this.bottomOverlayAnimationDuration,
    required this.topOverlayAnimationBuilder,
    required this.bottomOverlayAnimationBuilder,
    required this.topOverlayAnimationCurve,
    required this.bottomOverlayAnimationCurve,
  });

  final Widget child;
  final Widget? topOverlay;
  final Widget? bottomOverlay;
  final bool topOverlayAutoHide;
  final bool bottomOverlayAutoHide;
  final Duration topControlsAutoHideDelay;
  final Duration bottomControlsAutoHideDelay;
  final Duration topOverlayAnimationDuration;
  final Duration bottomOverlayAnimationDuration;
  final TurnableOverlayAnimationBuilder? topOverlayAnimationBuilder;
  final TurnableOverlayAnimationBuilder? bottomOverlayAnimationBuilder;
  final Curve topOverlayAnimationCurve;
  final Curve bottomOverlayAnimationCurve;

  @override
  State<_TurnableOverlayContainer> createState() =>
      _TurnableOverlayContainerState();
}

class _TurnableOverlayContainerState extends State<_TurnableOverlayContainer> {
  bool _topOverlayVisible = true;
  bool _bottomOverlayVisible = true;
  Timer? _topHideTimer;
  Timer? _bottomHideTimer;

  bool get _hasTopOverlay => widget.topOverlay != null;

  bool get _hasBottomOverlay => widget.bottomOverlay != null;

  @override
  void initState() {
    super.initState();
    if (_hasTopOverlay && widget.topOverlayAutoHide) {
      _scheduleTopHide();
    }
    if (_hasBottomOverlay && widget.bottomOverlayAutoHide) {
      _scheduleBottomHide();
    }
  }

  @override
  void didUpdateWidget(covariant _TurnableOverlayContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_hasTopOverlay) {
      _topHideTimer?.cancel();
      _topHideTimer = null;
      _topOverlayVisible = true;
    }

    if (!_hasBottomOverlay) {
      _bottomHideTimer?.cancel();
      _bottomHideTimer = null;
      _bottomOverlayVisible = true;
    }

    if (oldWidget.topOverlayAutoHide != widget.topOverlayAutoHide) {
      _topHideTimer?.cancel();
      _topHideTimer = null;
      if (widget.topOverlayAutoHide && _hasTopOverlay && _topOverlayVisible) {
        _scheduleTopHide();
      }
    }

    if (oldWidget.bottomOverlayAutoHide != widget.bottomOverlayAutoHide) {
      _bottomHideTimer?.cancel();
      _bottomHideTimer = null;
      if (widget.bottomOverlayAutoHide &&
          _hasBottomOverlay &&
          _bottomOverlayVisible) {
        _scheduleBottomHide();
      }
    }
  }

  @override
  void dispose() {
    _topHideTimer?.cancel();
    _bottomHideTimer?.cancel();
    super.dispose();
  }

  void _scheduleTopHide() {
    _topHideTimer?.cancel();
    _topHideTimer = Timer(widget.topControlsAutoHideDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _topOverlayVisible = false;
      });
    });
  }

  void _scheduleBottomHide() {
    _bottomHideTimer?.cancel();
    _bottomHideTimer = Timer(widget.bottomControlsAutoHideDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _bottomOverlayVisible = false;
      });
    });
  }

  void _toggleOverlays() {
    if (!_hasTopOverlay && !_hasBottomOverlay) {
      return;
    }

    final shouldHide = _topOverlayVisible || _bottomOverlayVisible;

    if (shouldHide) {
      setState(() {
        _topOverlayVisible = false;
        _bottomOverlayVisible = false;
      });
      _topHideTimer?.cancel();
      _topHideTimer = null;
      _bottomHideTimer?.cancel();
      _bottomHideTimer = null;
      return;
    }

    setState(() {
      _topOverlayVisible = _hasTopOverlay;
      _bottomOverlayVisible = _hasBottomOverlay;
    });

    if (widget.topOverlayAutoHide && _hasTopOverlay) {
      _scheduleTopHide();
    }
    if (widget.bottomOverlayAutoHide && _hasBottomOverlay) {
      _scheduleBottomHide();
    }
  }

  Widget _defaultTopAnimationBuilder(
    Animation<double> animation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: widget.topOverlayAnimationCurve,
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

  Widget _defaultBottomAnimationBuilder(
    Animation<double> animation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: widget.bottomOverlayAnimationCurve,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }

  Widget _buildAnimatedTopOverlay({required Widget child}) {
    final visibleChild = _topOverlayVisible
        ? child
        : const SizedBox(key: ValueKey('overlay-hidden'));

    return IgnorePointer(
      ignoring: !_topOverlayVisible,
      child: AnimatedSwitcher(
        duration: widget.topOverlayAnimationDuration,
        transitionBuilder: (switchChild, animation) {
          final builder =
              widget.topOverlayAnimationBuilder ??
              (context, anim, target) =>
                  _defaultTopAnimationBuilder(anim, target);
          return builder(context, animation, switchChild);
        },
        child: KeyedSubtree(
          key: ValueKey('overlay-top-$_topOverlayVisible'),
          child: visibleChild,
        ),
      ),
    );
  }

  Widget _buildAnimatedBottomOverlay({required Widget child}) {
    final visibleChild = _bottomOverlayVisible
        ? child
        : const SizedBox(key: ValueKey('overlay-hidden'));

    return IgnorePointer(
      ignoring: !_bottomOverlayVisible,
      child: AnimatedSwitcher(
        duration: widget.bottomOverlayAnimationDuration,
        transitionBuilder: (switchChild, animation) {
          final builder =
              widget.bottomOverlayAnimationBuilder ??
              (context, anim, target) =>
                  _defaultBottomAnimationBuilder(anim, target);
          return builder(context, animation, switchChild);
        },
        child: KeyedSubtree(
          key: ValueKey('overlay-bottom-$_bottomOverlayVisible'),
          child: visibleChild,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            _toggleOverlays();
            return null;
          },
        ),
      },
      child: Semantics(
        container: true,
        button: true,
        label: (_topOverlayVisible || _bottomOverlayVisible)
            ? 'Hide controls'
            : 'Show controls',
        onTap: _toggleOverlays,
        child: GestureDetector(
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
                    child: _buildAnimatedTopOverlay(child: widget.topOverlay!),
                  ),
                ),
              if (widget.bottomOverlay != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: _buildAnimatedBottomOverlay(
                      child: widget.bottomOverlay!,
                    ),
                  ),
                ),
            ],
          ),
        ),
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

/// Controls how a double-tap zoom is anchored.
enum DoubleTapZoomAnchor {
  /// Zoom around the tapped position.
  tapPoint,

  /// Zoom around the center of the page.
  pageCenter,
}
