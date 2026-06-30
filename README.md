# Turnable Page

Turnable Page is a Flutter widget for realistic, book-style page turning.

This package is focused on one job: animate page flips. It does not parse PDFs itself. Instead, you provide page widgets, which makes it a good fit for `pdfrx`-based PDF readers.

## Why this fits `pdfrx`

- Use `pdfrx` to load and render PDF pages.
- Feed each rendered page widget into `TurnablePage.builder`.
- Keep full control over caching, zooming, and document lifecycle in your app.

## Installation

```yaml
dependencies:
  turnable_page: ^1.0.6
```

Then run:

```bash
flutter pub get
```

## Core Usage

```dart
import 'package:flutter/material.dart';
import 'package:turnable_page/turnable_page.dart';

class BookViewer extends StatelessWidget {
  const BookViewer({
    super.key,
    required this.pageCount,
    required this.pageBuilder,
  });

  final int pageCount;
  final Widget Function(BuildContext context, int pageIndex) pageBuilder;

  @override
  Widget build(BuildContext context) {
    return TurnablePage(
      pageCount: pageCount,
      pageViewMode: PageViewMode.double,
      builder: (context, index, constraints) {
        return SizedBox.expand(
          child: pageBuilder(context, index),
        );
      },
    );
  }
}
```

In a PDF reader app, implement `pageBuilder` with your `pdfrx` page widget for `pageIndex`.

## Public API

- `TurnablePage`: main page-turn widget.
- `PageFlipController`: programmatic navigation (`nextPage`, `previousPage`, `goToPage`).
- `FlipSettings`: gesture, animation duration, shadows, and sizing behavior.
- `PageViewMode`: `single` or `double` spread.
- `FlipCorner`, `SizeType`, `PaperBoundaryDecoration`: visual and interaction tuning.

## Notes for PDF Apps

- Keep PDF decoding/rendering outside this package.
- Provide stable keys when needed so expensive page widgets keep their state.
- Use `PageFlipController` for external UI controls (next/prev/jump).

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
