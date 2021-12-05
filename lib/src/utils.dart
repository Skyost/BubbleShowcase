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

class AdvancedPositioningUtils {
  static Quadrant getQuadrantFromRelativePosition({
    required Position highlightPosition,
    required Size parentSize,
    required AxisDirection direction,
    required double middlePointWidth,
    required double middlePointHeight,
  }) {
    // Distance of the right point from the left edge
    final r = highlightPosition.right;
    // Distance of the left point from the left edge
    final l = highlightPosition.left;
    // Ditsance from the top point from the top
    final t = highlightPosition.top;
    // Distance from the bottom point from the top
    final b = highlightPosition.bottom;

    // Distance of the right point from the right edge
    final dr = parentSize.width - r;
    // Distance of the left point from the left edge
    final dl = l;
    // Distance of the top point from the top
    final dt = t;
    // Distance of the bottom point from the bottom;
    final db = parentSize.height - b;

    final w = parentSize.width;
    final h = parentSize.height;
    // Represents the boundaries x1 & y1 represent the positive axes from the middle of the parent
    // While x2 & y2 represent the negative axes from the middle of the parent

    final middlePointWidthConverted = 0.5 + middlePointWidth;
    final middlePointHeightConverted = 0.5 + middlePointHeight;

    final x1 = w * middlePointWidthConverted;
    final x2 = w - (w * middlePointWidthConverted);

    final y1 = h - (h * middlePointHeightConverted);
    final y2 = h * middlePointHeightConverted;

    // Mx & My represent the middle points of the axes of the highlighted item
    final highlightAreaSize = Size(r - l, b - t);
    final mx = l + highlightAreaSize.width / 2;
    final my = t + highlightAreaSize.height / 2;

    // It leans to the right side if the distance from the right edge is less than from the right edge
    final leansToRightSide = dr < dl;

    // It leans to the bottom side if the distance from the bottom edge is less than from the top edge
    final leansToBottomSide = db < dt;
    print('===================================');
    print('leansToBottomSide: $leansToBottomSide');
    print(
      'highlightPosition.bottom: ${highlightPosition.bottom}, highlightPosition.top: ${highlightPosition.top}',
    );
    print('===================================');
    print('leansToRightSide: $leansToRightSide');
    print(
      'highlightPosition.right: ${highlightPosition.right}, highlightPosition.left: ${highlightPosition.left}',
    );

    final isHorizontal =
        direction == AxisDirection.left || direction == AxisDirection.right;

    final isVertical =
        direction == AxisDirection.up || direction == AxisDirection.down;

    // Calculate extremes first, cases where
    // it might be in quadrant 5, but we cannot center due to possible
    // collitions with the screen edges.
    if (dr <= w * 0.05 && isVertical) {
      // Extreme right (slide on top or bottom of highlighted area)
      print('1st');
      if (leansToBottomSide) {
        return Quadrant.BOTTOM_RIGHT;
      } else {
        return Quadrant.TOP_RIGHT;
      }
    } else if (dl <= w * 0.05 && isVertical) {
      // Extreme left (slide on top or bottom of highlighted area)
      print('2nd');
      if (leansToBottomSide) {
        return Quadrant.BOTTOM_LEFT;
      } else {
        return Quadrant.TOP_LEFT;
      }
    } else if (db <= h * 0.05 && isHorizontal) {
      // Extreme bottom (slide on left or right of highlighted area)
      print('3rd');
      if (leansToRightSide) {
        return Quadrant.BOTTOM_RIGHT;
      } else {
        return Quadrant.BOTTOM_LEFT;
      }
    } else if (dt <= h * 0.05 && isHorizontal) {
      // Extreme top (slide on left or right of highlighted area)
      print('4th');
      if (leansToRightSide) {
        return Quadrant.TOP_RIGHT;
      } else {
        return Quadrant.TOP_LEFT;
      }
    }

    print("Quadrant calculated normally");

    // Calculate quadrants normally
    if (mx >= x1 && my <= y1) {
      print("DEBUG => Top_right");
      return Quadrant.TOP_RIGHT;
    } else if (mx <= x2 && my <= y1) {
      print("DEBUG => Top_left");
      return Quadrant.TOP_LEFT;
    } else if (mx <= x2 && my >= y2) {
      print("DEBUG => Bottom_left");
      return Quadrant.BOTTOM_LEFT;
    } else if (mx >= x1 && my >= y2) {
      print("DEBUG => Bottom_right");
      return Quadrant.BOTTOM_RIGHT;
    } else {
      return Quadrant.CENTER; // center (Not totally within any other quadrant)
    }
  }

  static Position getDownPositionFromQuadrant(
    Quadrant quadrant,
    Size parentSize,
    Position highlightPosition,
  ) {
    switch (quadrant) {
      case Quadrant.TOP_RIGHT:
      case Quadrant.BOTTOM_RIGHT:
        // It will expand to the left
        final spacingFromTheRightEdge =
            parentSize.width - highlightPosition.right;
        return Position(
          right: spacingFromTheRightEdge,
          top: highlightPosition.bottom,
        );
      case Quadrant.TOP_LEFT:
      case Quadrant.BOTTOM_LEFT:
        // It will expand to the right
        return Position(
          left: highlightPosition.left,
          top: highlightPosition.bottom,
        );
      case Quadrant.CENTER:
        final widthFromRightEdge = parentSize.width - highlightPosition.right;
        final widthFromLeftEdge = highlightPosition.left;
        final availableWidth = widthFromRightEdge > widthFromLeftEdge
            ? highlightPosition.right
            : highlightPosition.left;

        return Position(
          top: highlightPosition.bottom,
          right: widthFromRightEdge > widthFromLeftEdge
              ? (widthFromRightEdge) - (availableWidth / 2)
              : availableWidth / 2,
          left: widthFromLeftEdge > widthFromRightEdge
              ? (widthFromLeftEdge) + (availableWidth / 2)
              : availableWidth / 2,
        );
      default:
        throw ('Slide is outside the view area');
    }
  }

  static Position getLeftPositionFromQuadrant(
    Quadrant quadrant,
    Size parentSize,
    Position highlightPosition,
  ) {
    switch (quadrant) {
      case Quadrant.TOP_RIGHT:
      case Quadrant.TOP_LEFT:
        // It will expand to the bottom
        return Position(
          top: highlightPosition.top,
          right: parentSize.width - highlightPosition.left,
        );
      case Quadrant.BOTTOM_RIGHT:
      case Quadrant.BOTTOM_LEFT:
        // It will expand to the top
        return Position(
          bottom: parentSize.height - highlightPosition.bottom,
          right: parentSize.width - highlightPosition.left,
        );
      case Quadrant.CENTER:
        // It will be centered
        final topHeightFromEdge = highlightPosition.top;
        final bottomHeightFromEdge =
            parentSize.height - highlightPosition.bottom;
        final availableHeight = topHeightFromEdge > bottomHeightFromEdge
            ? (parentSize.height - highlightPosition.bottom) -
                (parentSize.height - highlightPosition.top)
            : (parentSize.height - highlightPosition.top) -
                (parentSize.height - highlightPosition.bottom);
        final highlightedItemSize = Size(
          highlightPosition.right - highlightPosition.left,
          highlightPosition.bottom - highlightPosition.top,
        );
        double top;
        double bottom;
        if (topHeightFromEdge > bottomHeightFromEdge) {
          top = (topHeightFromEdge) -
              ((availableHeight / 2) +
                  (bottomHeightFromEdge / 2) +
                  highlightedItemSize.height);
          bottom = (bottomHeightFromEdge / 2) - highlightedItemSize.height / 2;
        } else {
          top = (topHeightFromEdge / 2) - highlightedItemSize.height;
          bottom = (bottomHeightFromEdge) -
              ((availableHeight / 2) +
                  (topHeightFromEdge / 2) +
                  highlightedItemSize.height / 2);
        }

        return Position(
          top: top,
          bottom: bottom,
          right: parentSize.width - highlightPosition.left,
        );

      default:
        throw ('Slide is outside the view area');
    }
  }

  static Position getRightPositionFromQuadrant(
    Quadrant quadrant,
    Size parentSize,
    Position highlightPosition,
  ) {
    switch (quadrant) {
      case Quadrant.TOP_RIGHT:
      case Quadrant.TOP_LEFT:
        // It will expand to the bottom
        return Position(
          top: highlightPosition.top,
          left: highlightPosition.right,
        );
      case Quadrant.BOTTOM_RIGHT:
      case Quadrant.BOTTOM_LEFT:
        // It will expand to the top
        return Position(
          bottom: parentSize.height - highlightPosition.bottom,
          left: highlightPosition.right,
        );
      case Quadrant.CENTER:
        // It will be centered
        final topHeightFromEdge = highlightPosition.top;
        final bottomHeightFromEdge =
            parentSize.height - highlightPosition.bottom;

        final availableHeight = topHeightFromEdge > bottomHeightFromEdge
            ? (parentSize.height - highlightPosition.bottom) -
                (parentSize.height - highlightPosition.top)
            : (parentSize.height - highlightPosition.top) -
                (parentSize.height - highlightPosition.bottom);
        final highlightedItemSize = Size(
          highlightPosition.right - highlightPosition.left,
          highlightPosition.bottom - highlightPosition.top,
        );
        double top;
        double bottom;
        if (topHeightFromEdge > bottomHeightFromEdge) {
          top = (topHeightFromEdge) -
              ((availableHeight / 2) +
                  (bottomHeightFromEdge / 2) +
                  highlightedItemSize.height);
          bottom = (bottomHeightFromEdge / 2) - highlightedItemSize.height / 2;
        } else {
          top = (topHeightFromEdge / 2) - highlightedItemSize.height;
          bottom = (bottomHeightFromEdge) -
              ((availableHeight / 2) +
                  (topHeightFromEdge / 2) +
                  highlightedItemSize.height / 2);
        }

        return Position(
          top: top,
          bottom: bottom,
          left: highlightPosition.right,
        );
      default:
        throw ('Slide is outside the view area');
    }
  }

  static Position getUpPositionFromQuadrant(
    Quadrant quadrant,
    Size parentSize,
    Position highlightPosition,
  ) {
    switch (quadrant) {
      case Quadrant.TOP_RIGHT:
      case Quadrant.BOTTOM_RIGHT:
        // It will expand to the left
        final spacingFromTheRightEdge =
            parentSize.width - highlightPosition.right;
        return Position(
          right: spacingFromTheRightEdge,
          bottom: parentSize.height - highlightPosition.top,
        );
      case Quadrant.TOP_LEFT:
      case Quadrant.BOTTOM_LEFT:
        // It will expand to the right
        return Position(
          left: highlightPosition.left,
          bottom: parentSize.height - highlightPosition.top,
        );
      case Quadrant.CENTER:
        final widthFromRightEdge = parentSize.width - highlightPosition.right;
        final widthFromLeftEdge = highlightPosition.left;
        final availableWidth = widthFromRightEdge > widthFromLeftEdge
            ? highlightPosition.right
            : highlightPosition.left;

        return Position(
          bottom: parentSize.height - highlightPosition.top,
          right: widthFromRightEdge > widthFromLeftEdge
              ? (widthFromRightEdge) - (availableWidth / 2)
              : availableWidth / 2,
          left: widthFromLeftEdge > widthFromRightEdge
              ? (widthFromLeftEdge) + (availableWidth / 2)
              : availableWidth / 2,
        );
      default:
        throw ('Slide is outside the view area');
    }
  }
}
