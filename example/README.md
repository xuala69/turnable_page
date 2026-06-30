# Example App

This example shows how to pair `turnable_page` with `pdfrx` so PDF pages can
be turned like a book.

## What it demonstrates

- Loading a PDF from app assets via `PdfDocumentViewBuilder.asset`
- Rendering each page with `PdfPageView`
- Feeding those page widgets into `TurnablePage.builder`
- Programmatic navigation with `PageFlipController`

## Sample PDF

The demo uses:

- `assets/PDF32000_2008.pdf`
- Source: https://opensource.adobe.com/dc-acrobat-sdk-docs/pdfstandards/PDF32000_2008.pdf

## Run

```bash
flutter pub get
flutter run
```
