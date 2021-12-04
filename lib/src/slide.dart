import 'package:bubble_showcase/src/shape.dart';
import 'package:bubble_showcase/src/showcase.dart';
import 'package:bubble_showcase/src/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A function that allows to calculate a position according to a provided size.
typedef PositionCalculator = Position Function(Size size);

/// Pointer passthrough mode for the BubbleSlide
enum PassthroughMode {
  /// Passes through pointer events inside the highlighted area, interaction events will pass down to children.
  ///
  /// You will need to dispatch a [BubbleShowcaseNotification] from the children to continue
  /// the showcase. Interaction events will NOT continue the showcase.
  INSIDE_WITH_NOTIFICATION,

  /// Does not pass through any pointer events (default)
  NONE,
}

enum Quadrant {
  TOP_LEFT,
  TOP_RIGHT,
  CENTER,
  BOTTOM_LEFT,
  BOTTOM_RIGHT,
}

/// A simple bubble slide that allows to highlight a specific screen zone.
abstract class BubbleSlide {
  /// The slide shape.
  final Shape shape;

  /// The box shadow.
  final BoxShadow boxShadow;

  /// Triggered when this slide has been entered.
  final VoidCallback? onEnter;

  /// Triggered when this slide has been exited.
  ///
  /// Also triggered when onDismissed is called on the BubbleShowcase
  final VoidCallback? onExit;

  final PassthroughMode passThroughMode;

  /// The slide child.
  final BubbleSlideChild? child;

  /// Creates a new bubble slide instance.
  const BubbleSlide({
    this.shape = const Rectangle(),
    this.boxShadow = const BoxShadow(
      color: Colors.black54,
      blurRadius: 0,
      spreadRadius: 0,
    ),
    this.onEnter,
    this.onExit,
    this.child,
    this.passThroughMode = PassthroughMode.NONE,
  });

  /// Builds the whole slide widget.
  Widget build(
    BuildContext context,
    BubbleShowcase bubbleShowcase,
    int currentSlideIndex,
    void Function(int) goToSlide,
    VoidCallback close,
  ) {
    Position highlightPosition = getHighlightPosition(
      context,
      bubbleShowcase,
      currentSlideIndex,
    );

    List<Widget> children;

    switch (passThroughMode) {
      case PassthroughMode.NONE:
        children = [
          Positioned.fill(
            child: CustomPaint(
              painter: OverlayPainter(this, highlightPosition),
            ),
          ),
        ];
        break;
      case PassthroughMode.INSIDE_WITH_NOTIFICATION:
        children = [
          Positioned.fill(
            child: ClipPath(
              clipper: OverlayClipper(this, highlightPosition),
              child: Container(
                color: Colors.black54,
              ),
            ),
          ),
        ];
        break;
    }

    // Add BubbleSlide
    if (child?.widget != null) {
      children.add(
        child!.build(
          context,
          highlightPosition,
          MediaQuery.of(context).size,
        ),
      );
    }

    // Add counter text
    int slidesCount = bubbleShowcase.bubbleSlides.length;
    Color writeColor =
        Utils.isColorDark(boxShadow.color) ? Colors.white : Colors.black;
    if (bubbleShowcase.counterText != null) {
      children.add(
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 5,
          left: 0,
          right: 0,
          child: Text(
            bubbleShowcase.counterText!
                .replaceAll(':i', (currentSlideIndex + 1).toString())
                .replaceAll(':n', slidesCount.toString()),
            style: Theme.of(context)
                .textTheme
                .bodyText2!
                .copyWith(color: writeColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Add Close button
    if (bubbleShowcase.showCloseButton) {
      children.add(Positioned(
        top: MediaQuery.of(context).padding.top + 5,
        left: 0,
        child: GestureDetector(
          onTap: () {
            if (bubbleShowcase.onDismiss != null) {
              bubbleShowcase.onDismiss!();
            }
            close();
          },
          child: Icon(
            Icons.close,
            color: writeColor,
          ),
        ),
      ));
    }

    if (passThroughMode == PassthroughMode.INSIDE_WITH_NOTIFICATION) {
      return Stack(
        children: children,
      );
    } else {
      return GestureDetector(
        onTap: () => goToSlide(currentSlideIndex + 1),
        child: Stack(
          children: children,
        ),
      );
    }
  }

  /// Returns the position to highlight.
  Position getHighlightPosition(
    BuildContext context,
    BubbleShowcase bubbleShowcase,
    int currentSlideIndex,
  );
}

/// A bubble slide with a position that depends on another widget.
class RelativeBubbleSlide extends BubbleSlide {
  /// The widget key.
  final GlobalKey widgetKey;

  /// Padding for the highlight area
  final int highlightPadding;

  final PassthroughMode passThroughMode;

  final VoidCallback? onEnter;
  final VoidCallback? onExit;

  /// Creates a new relative bubble slide instance.
  const RelativeBubbleSlide({
    Shape shape = const Rectangle(),
    BoxShadow boxShadow = const BoxShadow(
      color: Colors.black54,
      blurRadius: 0,
      spreadRadius: 0,
    ),
    required BubbleSlideChild child,
    required this.widgetKey,
    this.passThroughMode = PassthroughMode.NONE,
    this.highlightPadding = 0,
    this.onEnter,
    this.onExit,
  }) : super(
          shape: shape,
          boxShadow: boxShadow,
          child: child,
          passThroughMode: passThroughMode,
          onEnter: onEnter,
          onExit: onExit,
        );

  @override
  Position getHighlightPosition(
    BuildContext context,
    BubbleShowcase bubbleShowcase,
    int currentSlideIndex,
  ) {
    RenderBox renderBox =
        widgetKey.currentContext!.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return Position(
      top: offset.dy - highlightPadding,
      right: offset.dx + renderBox.size.width + highlightPadding,
      bottom: offset.dy + renderBox.size.height + highlightPadding,
      left: offset.dx - highlightPadding,
    );
  }
}

/// A bubble slide with an absolute position on the screen.
class AbsoluteBubbleSlide extends BubbleSlide {
  /// The function that allows to compute the highlight position according to the parent size.
  final PositionCalculator positionCalculator;

  final VoidCallback? onEnter;
  final VoidCallback? onExit;

  /// Creates a new absolute bubble slide instance.
  const AbsoluteBubbleSlide({
    Shape shape = const Rectangle(),
    BoxShadow boxShadow = const BoxShadow(
      color: Colors.black54,
      blurRadius: 0,
      spreadRadius: 0,
    ),
    required BubbleSlideChild child,
    required this.positionCalculator,
    this.onEnter,
    this.onExit,
  }) : super(
          shape: shape,
          boxShadow: boxShadow,
          child: child,
          onEnter: onEnter,
          onExit: onExit,
        );

  @override
  Position getHighlightPosition(
    BuildContext context,
    BubbleShowcase bubbleShowcase,
    int currentSlideIndex,
  ) =>
      positionCalculator(MediaQuery.of(context).size);
}

/// A bubble slide child, holding a widget.
abstract class BubbleSlideChild {
  /// The held widget.
  final Widget widget;

  /// Creates a new bubble slide child instance.
  const BubbleSlideChild({
    required this.widget,
  });

  /// Builds the bubble slide child widget.
  Widget build(BuildContext context, Position targetPosition, Size parentSize) {
    Position position = getPosition(context, targetPosition, parentSize);
    Alignment alignment = getAlignment(context, targetPosition, parentSize);

    print("DEBUG => alignment: $alignment, position: $position");

    return Positioned(
      top: position.top,
      right: position.right,
      bottom: position.bottom,
      left: position.left,
      child: Align(
        alignment: alignment,
        child: widget,
      ),
    );
  }

  /// Returns child position according to the highlight position and parent size.
  Position getPosition(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  );

  Alignment getAlignment(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  );
}

/// A bubble slide with a position that depends on the highlight zone.
class RelativeBubbleSlideChild extends BubbleSlideChild {
  /// The child direction.
  final AxisDirection direction;

  /// Enables a new positioning system that will allow the child of the slide to
  /// expand beyond the highlighted area's dimensions.
  ///
  /// Heavily assisted by using an `Align` widget to align it within the expanded space
  final bool enableExtraSpace;

  /// Determines, in size a percentage from  0.15 to 0.45, the height of the parent container that will be
  /// recognized as "Middle" space, starting from the center.
  ///
  /// Used by the automatic positioning system to determine
  /// which positioning strategy to use. Defaults to 15% of the area from the middle to be counted as "center space".
  final double middlePointHeight;

  /// Determines, in size a percentage from 0.15 to 0.45, the width of the parent container that will be
  /// recognized as "Middle" space, starting from the center.
  ///
  /// Used by the automatic positioning system to determine
  /// which positioning strategy to use. Defaults to 15% of the area from the middle to be counted as "center space".
  final double middlePointWidth;

  /// Creates a new relative bubble slide child instance.
  const RelativeBubbleSlideChild({
    required Widget widget,
    this.direction = AxisDirection.down,
    this.enableExtraSpace = false,
    this.middlePointWidth = 0.15,
    this.middlePointHeight = 0.15,
  })  : assert(middlePointHeight >= 0 && middlePointHeight < 0.45),
        assert(middlePointWidth >= 0 && middlePointWidth < 0.45),
        super(
          widget: widget,
        );

  @override
  Position getPosition(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  ) {
    if (enableExtraSpace) {
      Quadrant quadrant = _getQuadrantFromRelativePosition(
          highlightPosition, parentSize, direction);

      print('DEBUG => quadrant $quadrant');

      switch (direction) {
        case AxisDirection.up:
          return _getUpPositionFromQuadrant(
            quadrant,
            parentSize,
            highlightPosition,
          );
        case AxisDirection.right:
          return _getRightPositionFromQuadrant(
            quadrant,
            parentSize,
            highlightPosition,
          );
        case AxisDirection.left:
          return _getLeftPositionFromQuadrant(
            quadrant,
            parentSize,
            highlightPosition,
          );
        default:
          return _getDownPositionFromQuadrant(
              quadrant, parentSize, highlightPosition);
      }
    } else {
      switch (direction) {
        case AxisDirection.up:
          return Position(
            right: parentSize.width - highlightPosition.right,
            bottom: parentSize.height - highlightPosition.top,
            left: highlightPosition.left,
          );
        case AxisDirection.right:
          return Position(
            top: highlightPosition.top,
            bottom: parentSize.height - highlightPosition.bottom,
            right: parentSize.width - highlightPosition.left,
          );
        case AxisDirection.left:
          return Position(
            top: highlightPosition.top,
            bottom: parentSize.height - highlightPosition.bottom,
            left: highlightPosition.right,
          );
        default:
          return Position(
            top: highlightPosition.bottom,
            right: parentSize.width - highlightPosition.right,
            left: highlightPosition.left,
          );
      }
    }
  }

  Quadrant _getQuadrantFromRelativePosition(
    Position highlightPosition,
    Size parentSize,
    AxisDirection direction,
  ) {
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

  Position _getDownPositionFromQuadrant(
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

  Position _getLeftPositionFromQuadrant(
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

  Position _getRightPositionFromQuadrant(
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

  Position _getUpPositionFromQuadrant(
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

  @override
  Alignment getAlignment(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  ) {
    Quadrant quadrant = _getQuadrantFromRelativePosition(
        highlightPosition, parentSize, direction);

    switch (quadrant) {
      case Quadrant.TOP_RIGHT:
        return Alignment.topRight;
      case Quadrant.TOP_LEFT:
        return Alignment.topLeft;
      case Quadrant.BOTTOM_LEFT:
        return Alignment.bottomLeft;
      case Quadrant.BOTTOM_RIGHT:
        return Alignment.bottomRight;
      case Quadrant.CENTER:
        return Alignment.center;
    }
  }
}

/// A bubble slide child with an absolute position on the screen.
class AbsoluteBubbleSlideChild extends BubbleSlideChild {
  /// The function that allows to compute the child position according to the parent size.
  final PositionCalculator positionCalculator;

  /// Creates a new absolute bubble slide child instance.
  const AbsoluteBubbleSlideChild({
    required Widget widget,
    required this.positionCalculator,
  }) : super(widget: widget);

  @override
  Position getPosition(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  ) =>
      positionCalculator(parentSize);

  @override
  Alignment getAlignment(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  ) {
    return Alignment.center;
  }
}
