import 'package:bubble_showcase/src/shape.dart';
import 'package:bubble_showcase/src/showcase.dart';
import 'package:bubble_showcase/src/util.dart';
import 'package:flutter/material.dart';

/// A simple bubble slide that allows to highlight a specific screen zone.
abstract class BubbleSlide {
  /// The slide shape.
  final Shape shape;

  /// The box shadow.
  final BoxShadow boxShadow;

  /// The slide child.
  final BubbleSlideChild child;

  /// Creates a new bubble slide instance.
  const BubbleSlide({
    this.shape = const Rectangle(),
    this.boxShadow = const BoxShadow(
      color: Colors.black54,
      blurRadius: 0,
      spreadRadius: 0,
    ),
    this.child,
  });

  /// Builds the whole slide widget.
  Widget build(BuildContext context, BubbleShowcase bubbleShowcase, int currentSlideIndex, void Function(int) goToSlide) {
    Position highlightPosition = getHighlightPosition(context, bubbleShowcase, currentSlideIndex);
    List<Widget> children = [
      Positioned.fill(
        child: CustomPaint(
          painter: OverlayPainter(this, highlightPosition),
        ),
      ),
    ];

    if (child != null && child.widget != null) {
      children.add(child.build(context, highlightPosition, MediaQuery.of(context).size));
    }

    int slidesCount = bubbleShowcase.bubbleSlides.length;
    Color writeColor = Util.isColorDark(boxShadow.color) ? Colors.white : Colors.black;
    if (bubbleShowcase.counterText != null) {
      children.add(
        Positioned(
          bottom: 5,
          left: 0,
          right: 0,
          child: Text(
            bubbleShowcase.counterText.replaceAll(':i', (currentSlideIndex + 1).toString()).replaceAll(':n', slidesCount.toString()),
            style: Theme.of(context).textTheme.body1.copyWith(color: writeColor),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (bubbleShowcase.showCloseButton) {
      children.add(Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        child: GestureDetector(
          child: Icon(
            Icons.close,
            color: writeColor,
          ),
          onTap: () => goToSlide(slidesCount),
        ),
      ));
    }

    return GestureDetector(
      onTap: () => goToSlide(currentSlideIndex + 1),
      child: Stack(
        children: children,
      ),
    );
  }

  /// Returns the position to highlight.
  Position getHighlightPosition(BuildContext context, BubbleShowcase bubbleShowcase, int currentSlideIndex);
}

/// A bubble slide with a position that depends on another widget.
class RelativeBubbleSlide extends BubbleSlide {
  /// The widget key.
  final GlobalKey widgetKey;

  /// Creates a new relative bubble slide instance.
  const RelativeBubbleSlide({
    Shape shape = const Rectangle(),
    BoxShadow boxShadow = const BoxShadow(
      color: Colors.black54,
      blurRadius: 0,
      spreadRadius: 0,
    ),
    BubbleSlideChild child,
    @required this.widgetKey,
  }) : super(
          shape: shape,
          boxShadow: boxShadow,
          child: child,
        );

  @override
  Position getHighlightPosition(BuildContext context, BubbleShowcase bubbleShowcase, int currentSlideIndex) {
    RenderBox renderBox = widgetKey.currentContext.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return Position(
      top: offset.dy,
      right: offset.dx + renderBox.size.width,
      bottom: offset.dy + renderBox.size.height,
      left: offset.dx,
    );
  }
}

/// A bubble slide with an absolute position on the screen.
class AbsoluteBubbleSlide extends BubbleSlide {
  /// The function that allows to compute the highlight position according to the parent size.
  final Position Function(Size) calculateHighlightPosition;

  /// Creates a new absolute bubble slide instance.
  const AbsoluteBubbleSlide({
    Shape shape = const Rectangle(),
    BoxShadow boxShadow = const BoxShadow(
      color: Colors.black54,
      blurRadius: 0,
      spreadRadius: 0,
    ),
    BubbleSlideChild child,
    @required this.calculateHighlightPosition,
  }) : super(
          shape: shape,
          boxShadow: boxShadow,
          child: child,
        );

  @override
  Position getHighlightPosition(BuildContext context, BubbleShowcase bubbleShowcase, int currentSlideIndex) => calculateHighlightPosition(MediaQuery.of(context).size);
}

/// A bubble slide child, holding a widget.
abstract class BubbleSlideChild {
  /// The held widget.
  final Widget widget;

  /// Creates a new bubble slide child instance.
  const BubbleSlideChild({
    this.widget,
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
  Position getPosition(BuildContext context, Position highlightPosition, Size parentSize);
}

/// A bubble slide with a position that depends on the highlight zone.
class RelativeBubbleSlideChild extends BubbleSlideChild {
  /// The child direction.
  final AxisDirection direction;

  /// Creates a new relative bubble slide child instance.
  const RelativeBubbleSlideChild({
    Widget widget,
    this.direction = AxisDirection.down,
  }) : super(
          widget: widget,
        );

  @override
  Position getPosition(BuildContext context, Position highlightPosition, Size parentSize) {
    switch (direction) {
      case AxisDirection.up:
        return Position(
          right: parentSize.width - highlightPosition.right,
          bottom: highlightPosition.top,
          left: highlightPosition.left,
        );
      case AxisDirection.right:
        return Position(
          top: highlightPosition.top,
          bottom: parentSize.height - highlightPosition.bottom,
          left: highlightPosition.right,
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
  final Position Function(Size) calculatePosition;

  /// Creates a new absolute bubble slide child instance.
  const AbsoluteBubbleSlideChild({
    Widget widget,
    @required this.calculatePosition,
  }) : super(
          widget: widget,
        );

  @override
  Position getPosition(BuildContext context, Position highlightPosition, Size parentSize) => calculatePosition(parentSize);
}
