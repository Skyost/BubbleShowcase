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
  final GlobalKey _titleKey = GlobalKey();

  /// The first button global key.
  final GlobalKey _firstButtonKey = GlobalKey();

  /// The second button global key.
  final GlobalKey _secondButtonKey = GlobalKey();

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
      ],
      child: _BubbleShowcaseDemoChild(
        _titleKey,
        _firstButtonKey,
        _secondButtonKey,
      ),
    );
  }

  /// Creates the first slide.
  BubbleSlide _firstSlide(TextStyle textStyle) => RelativeBubbleSlide(
        widgetKey: _titleKey,
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
                      'That\'s cool !',
                      style: textStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'This is my brand new title !',
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
  BubbleSlide _secondSlide(TextStyle textStyle) => AbsoluteBubbleSlide(
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
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Look at me pointing absolutely nothing.\n(Or maybe that\'s an hidden navigation bar !)',
                  style: textStyle,
                ),
              ),
            ),
          ),
          direction: AxisDirection.left,
        ),
      );

  /// Creates the third slide.
  BubbleSlide _thirdSlide(TextStyle textStyle) => RelativeBubbleSlide(
        widgetKey: _firstButtonKey,
        shape: const Oval(
          spreadRadius: 15,
        ),
        child: RelativeBubbleSlideChild(
          widget: Padding(
            padding: const EdgeInsets.only(top: 23),
            child: SpeechBubble(
              nipLocation: NipLocation.TOP,
              color: Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'As said, this button is new.\nOh, and this one is oval by the way.',
                        style: textStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  /// Creates the fourth slide.
  BubbleSlide _fourthSlide(TextStyle textStyle) => RelativeBubbleSlide(
        highlightPadding: 4,
        passThroughMode: PassthroughMode.INSIDE_WITH_NOTIFICATION,
        widgetKey: _secondButtonKey,
        shape: const Oval(
          spreadRadius: 15,
        ),
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
                      'Going through!',
                      style: textStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Passthrough is on!\nTo finish the tutorial, you need to click this button',
                      style: textStyle,
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
  final GlobalKey _titleKey;

  /// The first button global key.
  final GlobalKey _firstButtonKey;
  final GlobalKey _secondButtonKey;

  /// Creates a new bubble showcase demo child instance.
  _BubbleShowcaseDemoChild(
      this._titleKey, this._firstButtonKey, this._secondButtonKey);

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
                key: _titleKey,
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 5),
              child: ElevatedButton(
                key: _firstButtonKey,
                onPressed: () {},
                child: const Text('This button is NEW !'),
              ),
            ),
            ElevatedButton(
              key: _secondButtonKey,
              onPressed: () {
                const BubbleShowcaseNotification()..dispatch(context);
              },
              child: const Text(
                'This button is old, please don\'t pay attention.',
              ),
            )
          ],
        ),
      );
}
