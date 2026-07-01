# Example App

This example shows how to pair `turnable_page` with `pdfrx` so PDF pages can
be turned like a book.

## What it demonstrates

- Explicit `pdfrx` document loading in the example app
- Rendering each page with `PdfPageView`
- Using `TurnablePage` built-in pinch zoom support
- Programmatic navigation with `PageFlipController`
- Smooth page flip with package-level gesture/animation handling
- Package-level `topOverlay` / `bottomOverlay` with auto-hide

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
- Overlay auto-hide is handled by `TurnablePage(autoHideOverlays: true)`.
