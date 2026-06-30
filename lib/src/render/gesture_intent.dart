enum TurnableGestureIntent {
  idle,
  pending,
  horizontalDrag,
  verticalDrag,
  scaleGesture,
  tap,
}

class TurnableGestureIntentClassifier {
  static TurnableGestureIntent classify({
    required double deltaX,
    required double deltaY,
    required double threshold,
    required bool hasMultiplePointers,
  }) {
    if (hasMultiplePointers) {
      return TurnableGestureIntent.scaleGesture;
    }

    if (deltaX.abs() <= threshold && deltaY.abs() <= threshold) {
      return TurnableGestureIntent.tap;
    }

    if (deltaX.abs() > deltaY.abs() && deltaX.abs() > threshold) {
      return TurnableGestureIntent.horizontalDrag;
    }

    if (deltaY.abs() > deltaX.abs() && deltaY.abs() > threshold) {
      return TurnableGestureIntent.verticalDrag;
    }

    return TurnableGestureIntent.pending;
  }
}
