# Turnable Page

A Flutter package that provides a realistic page-flipping effect for digital books, magazines, catalogs, and other multi-page content in Flutter applications.

## Migration Guide (v0.x → v1.0.0)


### ✨ What's New

- **Interactive content now works** - buttons, inputs, and other widgets inside pages are fully functional
- **Smart gesture detection** - automatic differentiation between widget interaction and page flipping
- **Better performance** - migrated from CustomPainter to Flutter's native RenderBox system


## Features

✅ **Realistic Physics**: Advanced flip animations with proper physics and shadows  
✅ **Interactive Content**: Full support for interactive widgets (buttons, inputs, etc.) within pages  
✅ **Smart Gestures**: Automatic differentiation between drag (page flip) and tap (widget interaction)  
✅ **Touch Support**: Full touch and gesture support for mobile devices  
✅ **Multiple Orientations**: Automatic portrait/landscape orientation handling  
✅ **Widget Support**: Use any Flutter widget as page content with full interactivity  
✅ **Customizable**: Extensive configuration options for gestures and animations  
✅ **Performance**: Hardware-accelerated rendering using Flutter's native RenderBox system  
✅ **Events**: Rich event system for interaction handling  
✅ **Responsive**: Auto-sizing and responsive layout support  
✅ **Cross-Platform**: Supports Mobile, Web, and Windows

> **NEW**: Widgets inside book pages are now fully interactive! The smart gesture system automatically detects when you're interacting with buttons or other widgets vs. when you want to flip pages.

## Demo

### Desktop flipping

![Desktop flipping](https://raw.githubusercontent.com/saeedahmed725/turnable_page/main/demo/desktop-fliping.gif)

### Mobile flipping

![Mobile flipping](https://raw.githubusercontent.com/saeedahmed725/turnable_page/main/demo/mobile-fliping.gif)

### Responsiveness

![Responsiveness](https://raw.githubusercontent.com/saeedahmed725/turnable_page/main/demo/responsiveness.gif)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  turnable_page: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Basic Usage

### Simple Widget-Based Book

```dart
import 'package:flutter/material.dart';
import 'package:turnable_page/turnable_page.dart';

class MyBook extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TurnablePage(
            pageCount: 6,
            builder: (context, index, constraints) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Text(
                    'Page ${index + 1}',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              );
            },
          ),
      ),
    );
  }
}
```

### Page Flip Controller

Controller class for programmatic page manipulation.

#### Methods

- `nextPage()` - Flip to the next page with animation.
- `previousPage()` - Flip to the previous page with animation.
- `goToPage(int pageIndex)` - Flip to a specific page with animation.
- `goToFirstPage()` - Flip to the first page with animation.
- `goToLastPage()` - Flip to the last page with animation.

#### Properties

- `currentPageIndex` - Get current page index (0-based).
- `pageCount` - Get total number of pages.
- `hasNextPage` - Check if the next page is available.
- `hasPreviousPage` - Check if the previous page is available.

#### Usage

```dart
final controller = PageFlipController();

TurnablePage(
  controller: controller,
  pageCount: 6,
  builder: (context, index, constraints) {
    return Center(child: Text('Page ${index + 1}'));
  },
);

// Programmatic navigation
controller.previousPage();
controller.nextPage();
controller.goToPage(5);
controller.goToFirstPage();
controller.goToLastPage();

// Query state
controller.hasPreviousPage;
controller.hasNextPage;
```

> Note: The controller is bound to the internal page renderer automatically when you pass it to `TurnablePage`. No additional initialization is required.

## Public API

### Main entry point

- `TurnablePage` is the top-level widget for page-flip content.
- `PageFlipController` enables programmatic flipping and state inspection.
- `FlipSettings` configures visual behavior, animation timing, and gesture thresholds.
- `PaperBoundaryDecoration` controls the page border style.

### Builder behavior

- `builder` is called only for active pages and nearby cached pages.
- Pages may be rebuilt when they leave and later re-enter the active page window.
- Use `ValueKey` or external state if you need stable identity for page content.

### Controller lifecycle

- Create `PageFlipController` before building `TurnablePage`.
- Pass it to `TurnablePage.controller`.
- The package binds the controller internally when the widget mounts.
- The controller remains valid for the lifetime of the `TurnablePage` widget.

## Gesture Behavior

Page flip initiation is simplified: users flip pages by dragging or tapping near a page corner. Interactions on widgets (buttons, etc.) inside a page are still delivered to those widgets; a flip starts only when the gesture originates in a corner region or becomes a drag exceeding the movement threshold.

Key tunables that remain:
```dart
FlipSettings(
  cornerTriggerAreaSize: 0.15, // fraction of page diagonal for active corners
  swipeDistance: 80.0,         // drag distance threshold
)
```
Removed flags: enableSmartGestures, disableFlipByClick, clickEventForward (behavior now automatic and consistent).


#### Parameters

- `controller` - Optional controller for programmatic page control
- `builder` - Builder function that creates widget content for each page
- `pageCount` - Total number of pages in the book
- `onPageChanged` - Callback fired when page changes
- `pageViewMode` - Display mode: single page or double page spread
- `autoResponseSize` - Whether to automatically adjust size to container
- `aspectRatio` - Custom aspect ratio for the book
- `paperBoundaryDecoration` - Visual style for page boundaries
- `settings` - Detailed flip behavior configuration

### Page builder lifecycle

The `builder` is invoked for active pages only. The internal page cache keeps nearby pages alive while the current spread is visible and evicts pages when they fall outside the active window. This reduces memory cost for large page counts while preserving smooth page turn animation.



### FlipSettings Configuration

Configuration object for customizing flip behavior and appearance.

#### Constructor Parameters

| Parameter             | Type       | Default          | Description                                                |
| --------------------- | ---------- | ---------------- | ---------------------------------------------------------- |
| `startPageIndex`      | `int`      | `0`              | Initial page to display (0-based index)                    |
| `size`                | `SizeType` | `SizeType.fixed` | Size calculation: fixed dimensions or stretch to fit       |
| `width`               | `double`   | `0`              | Width of the book in pixels                                |
| `height`              | `double`   | `0`              | Height of the book in pixels                               |
| `drawShadow`          | `bool`     | `true`           | Whether to draw realistic shadow effects                   |
| `flippingTime`        | `int`      | `700`            | Duration of flip animation in milliseconds                 |
| `usePortrait`         | `bool`     | `true`           | Portrait mode (single page) vs landscape (two-page spread) |
| `maxShadowOpacity`    | `double`   | `1.0`            | Maximum opacity for shadow effects (0.0 to 1.0)            |
| `showCover`           | `bool`     | `false`          | Whether the book has a front/back cover                    |
| `mobileScrollSupport` | `bool`     | `true`           | Enable touch scrolling on mobile devices                   |
| `swipeDistance`       | `double`   | `100.0`          | Minimum distance in pixels for swipe gesture               |
| `showPageCorners`     | `bool`     | `true`           | Show interactive corner highlighting on hover              |

#### PageViewMode

- `PageViewMode.single` - Single page view (portrait orientation)
- `PageViewMode.double` - Double page spread (landscape orientation)

#### SizeType

- `SizeType.fixed` - Fixed dimensions specified by width/height
- `SizeType.stretch` - Stretch to fit parent container

#### FlipCorner

- `FlipCorner.topLeft` - Flip from top-left corner
- `FlipCorner.topRight` - Flip from top-right corner
- `FlipCorner.bottomLeft` - Flip from bottom-left corner
- `FlipCorner.bottomRight` - Flip from bottom-right corner

#### PaperBoundaryDecoration

- `PaperBoundaryDecoration.vintage` - Vintage paper styling
- `PaperBoundaryDecoration.modern` - Modern clean styling
- `PaperBoundaryDecoration.parchment` - Parchment-style textured paper with warm, aged tones


### Responsive Design

```dart
// Automatic responsive behavior
TurnablePage(
  autoResponseSize: true,      // Adapts to device size only in single mode
  pageViewMode: PageViewMode.single, // Switches based on screen size
  // ...
)
```

- [x] Core page flipping logic
- [x] Widget-based pages
- [x] Touch/gesture handling
- [x] Interactive content support
- [x] Smart gesture detection
- [x] Event system and callbacks
- [x] Hardware-accelerated rendering with RenderBox
- [x] Responsive design support
- [x] Portrait/landscape orientation
- [ ] Enhanced accessibility features
- [ ] Advanced animation customization
- [ ] Bookmark and navigation features




## Contributing

Contributions are welcome! Feel free to open issues and PRs to improve the package.

### Development Setup

1. Clone the repository:

```bash
git clone https://github.com/saeedahmed725/turnable_page.git
cd turnable_page
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the example:

```bash
cd example
flutter run
```

### Guidelines

- Keep the public API stable when possible and document any changes
- Follow Flutter development best practices
- Include tests for new features
- Update documentation for any API changes
- Ensure backward compatibility

## License

This project is distributed under the Turnable Page Proprietary License (TPPL). Usage, redistribution, and modification are not permitted except via approved pull requests in the official GitHub repository. See the [LICENSE](LICENSE) file for full terms.

## Credits

- Built with ❤️ for the Flutter community

## Support

If you find this package helpful, please:

- ⭐ Star the repository on GitHub
- 🐛 Report issues on GitHub Issues
- 💡 Suggest features and improvements
- 📖 Contribute to documentation

For support and questions, please use GitHub Issues or start a discussion in the repository.
