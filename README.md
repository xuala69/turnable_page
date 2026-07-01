# Turnable Page

Turnable Page is a Flutter widget for realistic, book-style page turning.

It is a page-turn engine, not a PDF parser. For PDF readers, pair it with a renderer such as `pdfrx`, then pass each rendered page widget into `TurnablePage.builder`.

## Installation

```yaml
dependencies:
  turnable_page: ^1.0.6
```

Then run:

```bash
flutter pub get
```

## Required Setup

If you open `PdfDocument` directly (instead of using `PdfDocumentViewBuilder`), initialize pdfrx before opening the document:

```dart
await pdfrxFlutterInitialize();
final document = await PdfDocument.openAsset('assets/PDF32000_2008.pdf');
```

Also dispose the document when your widget is disposed:

```dart
document.dispose();
```

## Core Usage (PDF)

This package works best when you:

- load a `PdfDocument` once,
- render each page with `PdfPageView`,
- provide the page widget from `TurnablePage.builder`.

```dart
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:turnable_page/turnable_page.dart';

class PdfBookViewer extends StatefulWidget {
  const PdfBookViewer({super.key});

  @override
  State<PdfBookViewer> createState() => _PdfBookViewerState();
}

class _PdfBookViewerState extends State<PdfBookViewer> {
  static const pdfAsset = 'assets/PDF32000_2008.pdf';
  final controller = PageFlipController();

  late final Future<PdfDocument> _future = _load();
  PdfDocument? _document;

  Future<PdfDocument> _load() async {
    await pdfrxFlutterInitialize();
    final doc = await PdfDocument.openAsset(pdfAsset);
    _document = doc;
    return doc;
  }

  @override
  void dispose() {
    _document?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PdfDocument>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final document = snapshot.data!;
        return TurnablePage(
          controller: controller,
          pageCount: document.pages.length,
          pageViewMode: PageViewMode.single,
          enablePinchZoom: true,
          minScale: 1.0,
          maxScale: 4.0,
          zoomThreshold: 1.01,
          zoomNormalizeThreshold: 1.04,
          settings: FlipSettings(
            drawShadow: true,
            flippingTime: 700,
            swipeDistance: 70,
            cornerTriggerAreaSize: 0.14,
          ),
          builder: (context, pageIndex, constraints) {
            return PdfPageView(
              document: document,
              pageNumber: pageIndex + 1,
              alignment: Alignment.center,
            );
          },
        );
      },
    );
  }
}
```

## Public API

- `TurnablePage`: main page-turn widget.
- `PageFlipController`: programmatic navigation (`nextPage`, `previousPage`, `goToPage`).
- `FlipSettings`: gesture, animation duration, shadows, and sizing behavior.
- `PageViewMode`: `single` or `double` spread.
- `FlipCorner`, `SizeType`, `PaperBoundaryDecoration`: visual and interaction tuning.

### Overlay API

`TurnablePage` also supports package-level overlay slots and optional auto-hide:

- `topOverlay` and `bottomOverlay`
- `autoHideOverlays`
- `overlayVisibleDuration`
- `overlayAnimationDuration`
- `overlayAnimationBuilder` (optional custom transition)

If `overlayAnimationBuilder` is not provided, a smooth fade + slide animation is used by default.

## Notes for PDF Apps

- Keep PDF decoding/rendering outside this package.
- Provide stable keys when needed so expensive page widgets keep their state.
- Use `PageFlipController` for external UI controls (next/prev/jump).
- Built-in zoom (`enablePinchZoom`) automatically locks page-turn while zoomed and unlocks after scale normalizes.

## Gesture Model (Recommended)

- Horizontal drag: page turn.
- Pinch/scale: PDF zoom.
- While zoomed in: lock page turn to avoid gesture conflict.
- When zoom returns close to identity: unlock page turn.

This separation gives predictable behavior for PDF readers.

## Platform Notes (pdfrx)

- Windows: enable Developer Mode before building pdfrx-based apps.
- iOS/macOS/Android/Web: supported by pdfrx; follow pdfrx platform setup docs when needed.

## Supported Platforms

- Android
- iOS
- macOS
- Windows
- Web

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
