import '../enums/flip_corner.dart';
import '../event/event_object.dart';
import '../page/page_flip.dart';

/// Controller for programmatic navigation of a [TurnablePage].
///
/// Initialize the controller by passing it to [TurnablePage.controller]. The
/// package will bind the controller to the internal [PageFlip] instance when
/// the page view is created.
class PageFlipController {
  late PageFlip _pageFlip;

  /// Bind the active [PageFlip] instance to this controller.
  void initializeController({required PageFlip pageFlip}) {
    _pageFlip = pageFlip;
  }

  /// Internal setter for the active [PageFlip] instance.
  set pageFlip(PageFlip pageFlip) => _pageFlip = pageFlip;

  /// The current visible page index (0-based).
  int get currentPageIndex => _pageFlip.getCurrentPageIndex();

  /// Total number of pages managed by the book.
  int get pageCount => _pageFlip.getPageCount();

  /// Whether the book can flip to the next page.
  bool get hasNextPage =>
      currentPageIndex + (_pageFlip.getSettings.usePortrait ? 0 : 1) <
      (pageCount - 1);

  /// Whether the book can flip to the previous page.
  bool get hasPreviousPage => currentPageIndex > 0;

  /// Flip to the next page with animation.
  ///
  /// Returns `true` if the flip is valid and started successfully.
  bool nextPage([FlipCorner corner = FlipCorner.top]) {
    if (!hasNextPage) return false;
    _pageFlip.flipNext(corner);
    return true;
  }

  /// Flip to the previous page with animation.
  bool previousPage([FlipCorner corner = FlipCorner.top]) {
    if (!hasPreviousPage) return false;
    _pageFlip.flipPrev(corner);
    return true;
  }

  /// Flip to a specific page with animation.
  ///
  /// [pageIndex] is zero-based.
  bool goToPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= pageCount) return false;
    _pageFlip.flip(pageIndex, FlipCorner.top);
    return true;
  }

  /// Go to the first page.
  bool goToFirstPage() => goToPage(0);

  /// Go to the last page.
  bool goToLastPage() => goToPage(pageCount - 1);

  /// Register an event listener on the underlying [PageFlip] instance.
  ///
  /// Common events include `flip` and `changeState`.
  void addEventListener(String event, EventCallback callback) {
    _pageFlip.on(event, callback);
  }

  /// Remove all listeners for the specified event.
  void removeEventListener(String event) {
    _pageFlip.off(event);
  }

  /// Access the underlying [PageFlip] instance for advanced usage.
  ///
  /// Prefer controller methods for normal use.
  PageFlip? get pageFlipInstance => _pageFlip;
}
