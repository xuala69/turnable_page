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

        return TurnablePageView(
          builder: (context, index) => builder(context, index, constraints),
          bookSize: bookSize,
          settings: adjustedSettings,
          pageCount: pageCount,
          controller: controller,
          aspectRatio: aspectRatio,
          onPageChanged: onPageChanged,
          pagesBoundaryIsEnabled: pagesBoundaryIsEnabled,
          paperBoundaryDecoration: paperBoundaryDecoration,
        );
      },
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

/// Internal builder type used by [TurnablePageView].
typedef PageWidgetBuilder = Widget Function(BuildContext context, int index);
