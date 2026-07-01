# Example App

This example shows how to pair `turnable_page` with `pdfrx` so PDF pages can
be turned like a book.

## What it demonstrates

- Explicit `pdfrx` document loading in the example app
- Rendering each page with `PdfPageView`
- Using `TurnablePage` built-in pinch zoom support
- Double-tap zoom with configurable target and anchor behavior
- Programmatic navigation with `PageFlipController`
- Smooth page flip with package-level gesture/animation handling
- Package-level `topOverlay` / `bottomOverlay` with independent auto-hide settings

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

- The example initializes pdfrx and opens `PdfDocument` directly.
- The loaded document is disposed in widget `dispose()`.
- Zoom lock/unlock behavior is handled by `TurnablePage(enablePinchZoom: true)`.
- Overlay auto-hide is handled by the package-level overlay settings.
