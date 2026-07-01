# Example App

This example shows how to pair `turnable_page` with `pdfrx` so PDF pages can
be turned like a book.

## What it demonstrates

- Loading a PDF from app assets via explicit `PdfDocument.openAsset`
- Rendering each page with `PdfPageView`
- Feeding those page widgets into `TurnablePage.builder`
- Programmatic navigation with `PageFlipController`
- Pinch-to-zoom using `InteractiveViewer`
- Locking page-turn gestures while zoomed, then unlocking when zoom resets

## Sample PDF

The demo uses:

- `assets/PDF32000_2008.pdf`
- Source: https://opensource.adobe.com/dc-acrobat-sdk-docs/pdfstandards/PDF32000_2008.pdf

## Run

```bash
flutter pub get
flutter run
```

## Required Notes

- The example manually initializes pdfrx (`pdfrxFlutterInitialize`) because it opens `PdfDocument` directly.
- The loaded `PdfDocument` is disposed in `dispose()`.
- While zoomed in, `TurnablePage.interactionEnabled` is set to `false` to prevent zoom/flip gesture conflicts.
