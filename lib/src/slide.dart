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
    if (child?.widget != null || child?.builder != null) {
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
  /// The direction of the slide
  final AxisDirection direction;

  /// The held widget.
  final Widget? widget;

  /// Builder function
  final Widget Function(
    BuildContext ctx,
    Position highlightPosition,
    Position slidePosition,
    Size parentSize,
    Alignment slideAlignment,
    AxisDirection slideDirection,
  )? builder;

  /// Creates a new bubble slide child instance.
  const BubbleSlideChild({
    required this.widget,
    required this.builder,
    required this.direction,
  });

  /// Builds the bubble slide child widget.
  Widget build(BuildContext context, Position targetPosition, Size parentSize) {
    print("DEBUG => Hello world");
    Widget childWidget;
    Position slidePosition = getPosition(context, targetPosition, parentSize);
    Alignment alignment =
        getAlignment(context, targetPosition, parentSize, direction);

    print(
      "DEBUG => alignment: $alignment, direction: $direction, slidePosition: $slidePosition",
    );

    if (builder != null) {
      print("DEBUG => Building off the builder");
      childWidget = builder!(
        context,
        targetPosition,
        slidePosition,
        parentSize,
        alignment,
        direction,
      );
    } else {
      print("DEBUG => Using the widget passed in props");
      childWidget = widget!;
    }

    return Positioned(
      top: slidePosition.top,
      right: slidePosition.right,
      bottom: slidePosition.bottom,
      left: slidePosition.left,
      child: Container(
        color: Colors.black,
        child: Align(
          alignment: alignment,
          child: childWidget,
        ),
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
    AxisDirection direction,
  );
}

/// A bubble slide with a position that depends on the highlight zone.
class RelativeBubbleSlideChild extends BubbleSlideChild {
  /// The child direction.
  final AxisDirection direction;

  /// Creates a new relative bubble slide child instance.
  const RelativeBubbleSlideChild({
    required Widget? widget,
    this.direction = AxisDirection.down,
  }) : super(
          direction: direction,
          widget: widget,
          builder: null,
        );

  @override
  Position getPosition(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  ) {
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

  @override
  Alignment getAlignment(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
    AxisDirection direction,
  ) {
    return Alignment.center;
  }
}

class RelativeBubbleSlideChildBuilder extends BubbleSlideChild {
  /// The child direction.
  final AxisDirection direction;

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

  final Widget Function(
    BuildContext ctx,
    Position highlightPosition,
    Position slidePosition,
    Size parentSize,
    Alignment slideAlignment,
    AxisDirection slideDirection,
  ) builder;

  RelativeBubbleSlideChildBuilder({
    required this.builder,
    this.direction = AxisDirection.down,
    this.middlePointWidth = 0.15,
    this.middlePointHeight = 0.15,
  })  : assert(middlePointHeight >= 0 && middlePointHeight < 0.45),
        assert(middlePointWidth >= 0 && middlePointWidth < 0.45),
        super(
          direction: direction,
          widget: null,
          builder: builder,
        );

  @override
  Alignment getAlignment(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
    AxisDirection direction,
  ) {
    Quadrant quadrant =
        AdvancedPositioningUtils.getQuadrantFromRelativePosition(
      highlightPosition: highlightPosition,
      parentSize: parentSize,
      direction: direction,
      middlePointHeight: middlePointHeight,
      middlePointWidth: middlePointWidth,
    );

    switch (quadrant) {
      case Quadrant.TOP_RIGHT:
        switch (direction) {
          case AxisDirection.down:
            return Alignment.topRight;
          case AxisDirection.up:
            return Alignment.bottomRight;
          case AxisDirection.right:
            return Alignment.topLeft;
          case AxisDirection.left:
            return Alignment.topRight;
        }
      case Quadrant.TOP_LEFT:
        switch (direction) {
          case AxisDirection.down:
            return Alignment.topLeft;
          case AxisDirection.up:
            return Alignment.bottomLeft;
          case AxisDirection.right:
            return Alignment.topLeft;
          case AxisDirection.left:
            return Alignment.topRight;
        }
      case Quadrant.BOTTOM_LEFT:
        switch (direction) {
          case AxisDirection.down:
            return Alignment.topLeft;
          case AxisDirection.up:
            return Alignment.bottomLeft;
          case AxisDirection.right:
            return Alignment.bottomLeft;
          case AxisDirection.left:
            return Alignment.bottomRight;
        }
      case Quadrant.BOTTOM_RIGHT:
        switch (direction) {
          case AxisDirection.down:
            return Alignment.topRight;
          case AxisDirection.up:
            return Alignment.bottomRight;
          case AxisDirection.right:
            return Alignment.bottomLeft;
          case AxisDirection.left:
            return Alignment.bottomRight;
        }
      case Quadrant.CENTER:
        switch (direction) {
          case AxisDirection.down:
            return Alignment.topCenter;
          case AxisDirection.up:
            return Alignment.bottomCenter;
          case AxisDirection.left:
            return Alignment.centerRight;
          case AxisDirection.right:
            return Alignment.centerLeft;
        }
    }
  }

  @override
  Position getPosition(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  ) {
    Quadrant quadrant =
        AdvancedPositioningUtils.getQuadrantFromRelativePosition(
      highlightPosition: highlightPosition,
      parentSize: parentSize,
      direction: direction,
      middlePointHeight: middlePointHeight,
      middlePointWidth: middlePointWidth,
    );

    print('DEBUG => quadrant $quadrant');

    switch (direction) {
      case AxisDirection.up:
        return AdvancedPositioningUtils.getUpPositionFromQuadrant(
          quadrant,
          parentSize,
          highlightPosition,
        );
      case AxisDirection.right:
        return AdvancedPositioningUtils.getRightPositionFromQuadrant(
          quadrant,
          parentSize,
          highlightPosition,
        );
      case AxisDirection.left:
        return AdvancedPositioningUtils.getLeftPositionFromQuadrant(
          quadrant,
          parentSize,
          highlightPosition,
        );
      default:
        return AdvancedPositioningUtils.getDownPositionFromQuadrant(
            quadrant, parentSize, highlightPosition);
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
  }) : super(
          widget: widget,
          builder: null,
          direction: AxisDirection.down,
        );

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
    AxisDirection direction,
  ) {
    return Alignment.center;
  }
}
