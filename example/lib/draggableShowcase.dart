import 'package:bubble_showcase/bubble_showcase.dart';
import 'package:flutter/material.dart';

import 'speech_bubble.dart';

final middlePointHeight = 0.20;
final middlePointWidth = 0.20;

final buttonHeight = 80.00;
final buttonWidth = 220.00;

/// The draggable demo widget
class BubbleShowcaseDraggableWidget extends StatefulWidget {
  @override
  BubbleShowcaseDraggableWidgetState createState() =>
      BubbleShowcaseDraggableWidgetState();
}

class BubbleShowcaseDraggableWidgetState
    extends State<BubbleShowcaseDraggableWidget> {
  int tapAmount = 0;
  bool enabled = false;
  final GlobalKey _draggableSlideKey = GlobalKey();

  callback() {
    setState(() {
      enabled = !enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
          color: Colors.white,
        );
    return BubbleShowcase(
      enabled: enabled,
      initialDelay: const Duration(milliseconds: 500),
      onDismiss: () {
        print('I got dismissed!');
      },
      onEnd: () {
        callback();
      },
      bubbleShowcaseId: 'my_bubble_showcase_2',
      bubbleShowcaseVersion: 1,
      bubbleSlides: [
        _draggableSlide(textStyle),
      ],
      child: _BubbleShowcaseDraggableChild(
        _draggableSlideKey,
        callback,
        enabled,
      ),
    );
  }

  BubbleSlide _draggableSlide(TextStyle textStyle) => RelativeBubbleSlide(
        widgetKey: _draggableSlideKey,
        child: RelativeBubbleSlideChildBuilder(
          middlePointHeight: middlePointHeight,
          middlePointWidth: middlePointWidth,
          direction: AxisDirection.down,
          builder: (
            ctx,
            highlightPosition,
            slidePosition,
            parentSize,
            slideAlignment,
            slideDirection,
          ) {
            NipLocation getNipLocation(
              Alignment alignment,
              AxisDirection direction,
            ) {
              if (alignment == Alignment.topLeft) {
                return NipLocation.TOP_LEFT;
              } else if (alignment == Alignment.topRight) {
                return NipLocation.TOP_RIGHT;
              } else if (alignment == Alignment.bottomLeft) {
                return NipLocation.BOTTOM_LEFT;
              } else if (alignment == Alignment.bottomRight) {
                return NipLocation.BOTTOM_RIGHT;
              } else {
                switch (direction) {
                  case AxisDirection.up:
                    return NipLocation.TOP;
                  case AxisDirection.right:
                    return NipLocation.RIGHT;
                  case AxisDirection.down:
                    return NipLocation.BOTTOM;
                  case AxisDirection.left:
                    return NipLocation.LEFT;
                }
              }
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SpeechBubble(
                color: Colors.blue,
                nipLocation: getNipLocation(slideAlignment, slideDirection),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Example Slide',
                        style: textStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 5),
                            child: Icon(
                              Icons.info_outline,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Example of advanced positioning system.',
                              style: textStyle,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
}

class _BubbleShowcaseDraggableChild extends StatefulWidget {
  /// The first button global key.
  final GlobalKey _draggableSlideKey;
  final VoidCallback callback;
  final bool enabled;

  /// Creates a new bubble showcase demo child instance.
  _BubbleShowcaseDraggableChild(
    this._draggableSlideKey,
    this.callback,
    this.enabled,
  );

  @override
  _BubbleShowcaseDraggableChildState createState() =>
      _BubbleShowcaseDraggableChildState();
}

class _BubbleShowcaseDraggableChildState
    extends State<_BubbleShowcaseDraggableChild> {
  Offset? _position;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final debugLines = [
          // Extreme zone Left (Vertical)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            top: 0,
            bottom: MediaQuery.of(context).size.height * 0.055,
            child: const VerticalDivider(
              thickness: 5,
              color: Colors.red,
            ),
          ),
          // Extreme zone Right (Vertical)
          Positioned(
            right: MediaQuery.of(context).size.width * 0.05,
            top: 0,
            bottom: MediaQuery.of(context).size.height * 0.055,
            child: const VerticalDivider(
              thickness: 5,
              color: Colors.red,
            ),
          ),
          // Extreme zone Bottom (Horizontal)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.05,
            left: MediaQuery.of(context).size.width * 0.055,
            right: MediaQuery.of(context).size.width * 0.055,
            child: const Divider(
              thickness: 5,
              color: Colors.red,
            ),
          ),
          // Center zone left (Vertical)
          Positioned(
            top: 0,
            bottom: MediaQuery.of(context).size.height * 0.055,
            right: MediaQuery.of(context).size.width * (middlePointWidth + 0.5),
            child: const VerticalDivider(
              color: Colors.blue,
              thickness: 5,
            ),
          ),
          // Center zone right (Vertical)
          Positioned(
            top: 0,
            bottom: MediaQuery.of(context).size.height * 0.055,
            left: MediaQuery.of(context).size.width * (middlePointWidth + 0.5),
            child: const VerticalDivider(
              color: Colors.blue,
              thickness: 5,
            ),
          ),
          // Center zone bottom (Horizontal)
          Positioned(
            bottom: MediaQuery.of(context).size.height * (middlePointHeight),
            left: MediaQuery.of(context).size.width * 0.055,
            right: MediaQuery.of(context).size.width * 0.055,
            child: const Divider(
              color: Colors.blue,
              thickness: 5,
            ),
          ),
          // Center zone top (Horizontal)
          Positioned(
            bottom:
                MediaQuery.of(context).size.height * (middlePointHeight + 0.5),
            left: MediaQuery.of(context).size.width * 0.055,
            right: MediaQuery.of(context).size.width * 0.055,
            child: const Divider(
              color: Colors.blue,
              thickness: 5,
            ),
          )
        ];

        final button = Container(
          width: buttonWidth,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () {
              widget.callback();
            },
            child: const Text(
              'Drag this button to position it\nClick to see the showcase slide',
            ),
          ),
        );
        return Stack(
          children: [
            ...debugLines,
            Positioned(
              left: MediaQuery.of(context).size.width / 2 - 80,
              child: Text('Tutorial enabled? ${widget.enabled}'),
            ),
            Positioned(
              left: _position != null
                  ? _position!.dx
                  : constraints.maxWidth / 2 - buttonWidth / 2,
              top: _position != null
                  ? _position!.dy
                  : constraints.maxHeight / 2 - buttonHeight / 2,
              child: Draggable(
                key: widget._draggableSlideKey,
                feedback: button,
                onDraggableCanceled: (velocity, offset) => {
                  setState(() {
                    _position = Offset(offset.dx, offset.dy - 104);
                  })
                },
                child: button,
              ),
            ),
          ],
        );
      },
    );
  }
}
