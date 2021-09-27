import 'package:bubble_showcase/src/shape.dart';
import 'package:bubble_showcase/src/showcase.dart';
import 'package:bubble_showcase/src/utils.dart';
import 'package:flutter/cupertino.dart';
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

/// A simple bubble slide that allows to highlight a specific screen zone.
abstract class BubbleSlide {
  /// The slide shape.
  final Shape shape;

  /// The box shadow.
  final BoxShadow boxShadow;

  /// Triggered when this slide has been entered.
  final VoidCallback? onEnter;

  /// Triggered when this slide has been exited.
  final VoidCallback? onExit;

  final PassthroughMode passthroughMode;

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
    this.passthroughMode = PassthroughMode.NONE,
  });

  /// Builds the whole slide widget.
  Widget build(
    BuildContext context,
    BubbleShowcase bubbleShowcase,
    int currentSlideIndex,
    void Function(int) goToSlide,
  ) {
    Position highlightPosition = getHighlightPosition(
      context,
      bubbleShowcase,
      currentSlideIndex,
    );

    List<Widget> children;

    switch (passthroughMode) {
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
          bottom: 5,
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
        top: MediaQuery.of(context).padding.top,
        left: 0,
        child: GestureDetector(
          onTap: () => goToSlide(slidesCount),
          child: Icon(
            Icons.close,
            color: writeColor,
          ),
        ),
      ));
    }

    if (passthroughMode == PassthroughMode.INSIDE_WITH_NOTIFICATION) {
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

  /// Creates a new relative bubble slide instance.
  const RelativeBubbleSlide({
    Shape shape = const Rectangle(),
    BoxShadow boxShadow = const BoxShadow(
      color: Colors.black54,
      blurRadius: 0,
      spreadRadius: 0,
    ),
    passThroughMode = PassthroughMode.NONE,
    required BubbleSlideChild child,
    required this.widgetKey,
    this.highlightPadding = 0,
  }) : super(
          shape: shape,
          boxShadow: boxShadow,
          child: child,
          passthroughMode: passThroughMode,
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
  }) : super(
          shape: shape,
          boxShadow: boxShadow,
          child: child,
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
    return Positioned(
      top: position.top,
      right: position.right,
      bottom: position.bottom,
      left: position.left,
      child: widget,
    );
  }

  /// Returns child position according to the highlight position and parent size.
  Position getPosition(
    BuildContext context,
    Position highlightPosition,
    Size parentSize,
  );
}

/// A bubble slide with a position that depends on the highlight zone.
class RelativeBubbleSlideChild extends BubbleSlideChild {
  /// The child direction.
  final AxisDirection direction;

  /// Creates a new relative bubble slide child instance.
  const RelativeBubbleSlideChild({
    required Widget widget,
    this.direction = AxisDirection.down,
  }) : super(
          widget: widget,
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
}
