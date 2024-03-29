import 'package:bubble_showcase/src/slide.dart';
import 'package:flutter/material.dart';

/// Contains some useful methods.
class Utils {
  /// Returns whether a specified color is dark.
  static bool isColorDark(Color color) => color.computeLuminance() <= 0.5;
}

/// Represents a position on the screen.
class Position {
  /// The top coordinate.
  final double top;

  /// The right coordinate.
  final double right;

  /// The bottom coordinate.
  final double bottom;

  /// The left coordinate.
  final double left;

  /// Creates a new position instance.
  const Position({
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.left = 0,
  });

  @override
  String toString() =>
      'Position(top: $top, right: $right, bottom: $bottom, left: $left)';

  @override
  bool operator ==(Object other) =>
      other is Position &&
      top == other.top &&
      right == other.right &&
      bottom == other.bottom &&
      left == other.left;

  @override
  int get hashCode {
    int result = 17;
    result = result * 31 + top.truncate();
    result = result * 31 + right.truncate();
    result = result * 31 + bottom.truncate();
    result = result * 31 + left.truncate();
    return result;
  }
}

/// A simple painter that allows to highlight a specific zone on the screen by darkening the whole screen (apart the specified zone).
class OverlayPainter extends CustomPainter {
  /// The bubble slide.
  final BubbleSlide _slide;

  /// The position to highlight.
  final Position _position;

  /// Creates a new overlay painter instance.
  const OverlayPainter(this._slide, this._position);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(
      Offset.zero & size,
      Paint(),
    ); // Thanks to https://stackoverflow.com/a/51548959.
    canvas.drawColor(_slide.boxShadow.color, BlendMode.dstATop);
    _slide.shape.drawOnCanvas(
      canvas,
      Rect.fromLTRB(
        _position.left,
        _position.top,
        _position.right,
        _position.bottom,
      ),
      _slide.boxShadow.toPaint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(OverlayPainter oldOverlay) =>
      oldOverlay._position != _position;
}

class OverlayClipper extends CustomClipper<Path> {
  final BubbleSlide _slide;
  final Position _position;

  const OverlayClipper(this._slide, this._position);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    _slide.shape.makePath(
      path,
      Rect.fromLTRB(
        _position.left,
        _position.top,
        _position.right,
        _position.bottom,
      ),
    );
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) => false;
}
