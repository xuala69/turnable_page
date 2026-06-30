import 'package:flutter/widgets.dart';

import '../../turnable_page.dart';
import '../page/page_flip.dart';
import '../render/render_turnable_book.dart';

class TurnableBookRenderObjectWidget extends MultiChildRenderObjectWidget {
  final int pageCount;
  final FlipSettings settings;
  final PageFlip pageFlip;
  final bool interactionEnabled;

  const TurnableBookRenderObjectWidget({
    super.key,
    required this.pageCount,
    required super.children,
    required this.settings,
    required this.pageFlip,
    this.interactionEnabled = true,
  });

  @override
  RenderTurnableBook createRenderObject(BuildContext context) {
    final render = RenderTurnableBook(
      settings,
      pageFlip,
      pageCount,
      interactionEnabled: interactionEnabled,
    );

    return render;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTurnableBook renderObject,
  ) {
    renderObject.isInteractionEnabled = interactionEnabled;
    renderObject.updateSettings(settings, pageCount);
  }
}
