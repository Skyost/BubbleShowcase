import 'package:bubble_showcase/bubble_showcase.dart';
import 'package:flutter/material.dart';

import 'speech_bubble.dart';

/// First plugin test method.
void main() => runApp(_BubbleShowcaseDemoApp());

/// The demo material app.
class _BubbleShowcaseDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bubble Showcase Demo',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Bubble Showcase Demo'),
          ),
          body: _BubbleShowcaseDemoWidget(),
        ),
      );
}

/// The main demo widget.
class _BubbleShowcaseDemoWidget extends StatelessWidget {
  /// The title text global key.
  final GlobalKey _firstSlideKey = GlobalKey();

  /// The first button global key.
  final GlobalKey _secondSlideKey = GlobalKey();

  /// The second button global key.
  final GlobalKey _thirdSlideKey = GlobalKey();
  final GlobalKey _fourthSlideKey = GlobalKey();
  final GlobalKey _fifthSlideKey = GlobalKey();
  final GlobalKey _sixthSlideKey = GlobalKey();
  final GlobalKey _seventhSlideKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
          color: Colors.white,
        );
    return BubbleShowcase(
      bubbleShowcaseId: 'my_bubble_showcase',
      bubbleShowcaseVersion: 1,
      bubbleSlides: [
        _firstSlide(textStyle),
        _secondSlide(textStyle),
        _thirdSlide(textStyle),
        _fourthSlide(textStyle),
        _fifthSlide(textStyle),
        _sixthSlide(textStyle),
        _seventhSlide(textStyle),
        _absoluteSlide(textStyle),
      ],
      child: _BubbleShowcaseDemoChild(
        _firstSlideKey,
        _secondSlideKey,
        _thirdSlideKey,
        _fourthSlideKey,
        _fifthSlideKey,
        _sixthSlideKey,
        _seventhSlideKey,
      ),
    );
  }

  /// Creates the first slide.
  BubbleSlide _firstSlide(TextStyle textStyle) => RelativeBubbleSlide(
        onEnter: () {
          print("OnEnter function!");
        },
        onExit: () {
          print("OnExit function!");
        },
        widgetKey: _firstSlideKey,
        child: RelativeBubbleSlideChild(
          widget: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SpeechBubble(
              nipLocation: NipLocation.TOP,
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hello World!',
                      style: textStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'BubbleShowcase lets you create step by step showcase of your features',
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  /// Creates the second slide.
  BubbleSlide _absoluteSlide(TextStyle textStyle) => AbsoluteBubbleSlide(
        onEnter: () {
          print("OnEnter function!");
        },
        onExit: () {
          print("OnExit function!");
        },
        positionCalculator: (size) => Position(
          top: 0,
          right: 0,
          left: 0,
          bottom: size.height,
        ),
        child: RelativeBubbleSlideChild(
          widget: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SpeechBubble(
              nipLocation: NipLocation.LEFT,
              color: Colors.teal,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Look at me pointing absolutely nothing.\n(Or maybe that\'s a hidden navigation bar!)',
                  style: textStyle,
                ),
              ),
            ),
          ),
          direction: AxisDirection.left,
        ),
      );

  /// Creates the third slide.
  BubbleSlide _secondSlide(TextStyle textStyle) => RelativeBubbleSlide(
        widgetKey: _secondSlideKey,
        child: RelativeBubbleSlideChild(
          direction: AxisDirection.down,
          widget: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SpeechBubble(
              nipLocation: NipLocation.TOP,
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Second slide!',
                      style: textStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This slide uses the default positioning which will center the container\'s content within the dimensions of the highlighted box.',
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  /// Creates the fourth slide.
  BubbleSlide _thirdSlide(TextStyle textStyle) => RelativeBubbleSlide(
        highlightPadding: 4,
        passThroughMode: PassthroughMode.INSIDE_WITH_NOTIFICATION,
        widgetKey: _thirdSlideKey,
        child: RelativeBubbleSlideChild(
          enableExtraSpace: true,
          direction: AxisDirection.down,
          widget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SpeechBubble(
              nipLocation: NipLocation.TOP_LEFT,
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Click me to continue!',
                      style: textStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This slide is on the top left with `enableExtraSpace = true`\nWhen this is enabled it will automatically expand to the side with the most space, to expand further than the highlighted area\'s dimentions.\nThere is also some highlight padding on this one.\n\nAlso passthrough mode is on so you can now interact with the button.\nTo continue the tutorial, you need to click this button.',
                      style: textStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  BubbleSlide _fourthSlide(TextStyle textStyle) => RelativeBubbleSlide(
        widgetKey: _fourthSlideKey,
        child: RelativeBubbleSlideChild(
          enableExtraSpace: true,
          direction: AxisDirection.down,
          widget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SpeechBubble(
              color: Colors.blue,
              nipLocation: NipLocation.TOP_RIGHT,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Fourth Slide!',
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
                        Text(
                          'Another example of the automatic resizing.\n\nThis one is on the top right and it will expand to the bottom left if needed!\n\nNote that the positioning is assisted by an `Alignment.topRight`',
                          style: textStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  BubbleSlide _fifthSlide(TextStyle textStyle) => RelativeBubbleSlide(
        widgetKey: _fifthSlideKey,
        child: RelativeBubbleSlideChild(
          enableExtraSpace: true,
          direction: AxisDirection.up,
          widget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SpeechBubble(
              nipLocation: NipLocation.BOTTOM_RIGHT,
              color: Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Fifth Slide!',
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
                        Text(
                          'Another example of the automatic resizing.\n\nThis is one is on bottom right and it will expand to the top left if needed!\n Note the MainAxisSize.min on both the column and row to shrinkwrap the content',
                          style: textStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  BubbleSlide _sixthSlide(TextStyle textStyle) => RelativeBubbleSlide(
        widgetKey: _sixthSlideKey,
        shape: const Oval(
          spreadRadius: 15,
        ),
        child: RelativeBubbleSlideChild(
          enableExtraSpace: true,
          direction: AxisDirection.up,
          widget: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SpeechBubble(
              nipLocation: NipLocation.BOTTOM_LEFT,
              color: Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sixth slide!',
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
                        Text(
                          'Another example of the automatic resizing.\n\nOh, and this one is oval by the way.',
                          style: textStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  BubbleSlide _seventhSlide(TextStyle textStyle) => RelativeBubbleSlide(
        widgetKey: _seventhSlideKey,
        child: RelativeBubbleSlideChild(
          enableExtraSpace: true,
          direction: AxisDirection.left,
          widget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SpeechBubble(
              color: Colors.blue,
              nipLocation: NipLocation.RIGHT,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Center positioned!',
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
                            'Another example of the automatic resizing. This one will try to expand to the left, top and bottom, it still is limited vertically, but it is bigger than its highlighted area',
                            style: textStyle,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// The main demo widget child.
class _BubbleShowcaseDemoChild extends StatelessWidget {
  /// The title text global key.
  final GlobalKey _firstSlideKey;

  /// The first button global key.
  final GlobalKey _secondSlideKey;
  final GlobalKey _thirdSlideKey;
  final GlobalKey _fourthSlideKey;
  final GlobalKey _fifthSlideKey;
  final GlobalKey _sixthSlideKey;
  final GlobalKey _seventhSlideKey;

  /// Creates a new bubble showcase demo child instance.
  _BubbleShowcaseDemoChild(
    this._firstSlideKey,
    this._secondSlideKey,
    this._thirdSlideKey,
    this._fourthSlideKey,
    this._fifthSlideKey,
    this._sixthSlideKey,
    this._seventhSlideKey,
  );

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 40,
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Text(
                'Bubble Showcase',
                key: _firstSlideKey,
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 5),
              child: ElevatedButton(
                key: _secondSlideKey,
                onPressed: () {},
                child: const Text('This button is NEW !'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  key: _thirdSlideKey,
                  onPressed: () {
                    const BubbleShowcaseNotification()..dispatch(context);
                  },
                  child: const Text(
                    'This button is to the left',
                  ),
                ),
                ElevatedButton(
                  key: _fourthSlideKey,
                  onPressed: () {},
                  child: const Text(
                    'This button is to the right',
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  key: _seventhSlideKey,
                  onPressed: () {},
                  child: const Text(
                    'This button is on the center',
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  key: _sixthSlideKey,
                  child: const Text('This text is to the left'),
                ),
                Container(
                  key: _fifthSlideKey,
                  child: const Text('This text is to the right'),
                )
              ],
            )
          ],
        ),
      );
}
