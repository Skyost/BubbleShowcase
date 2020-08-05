# BubbleShowcase

**BubbleShowcase** is a small but powerful flutter package that allows you to highlight
specific parts of your app (to explain them to the user for instance) or to showcase your app new features.

![Preview](https://github.com/Skyost/BubbleShowcase/blob/master/screenshots/preview.gif)

## Getting Started

This package is easy to use.
Take a look at the following snippet (which is using [speech_bubble](https://pub.dev/packages/speech_bubble)) :

```dart
BubbleShowcase(
  bubbleShowcaseId: 'my_bubble_showcase',
  bubbleShowcaseVersion: 1,
  bubbleSlides: [
    RelativeBubbleSlide(
      widgetKey: widgetToHighlightKey,
      child: RelativeBubbleSlideChild(
        direction: AxisDirection.right,
        widget: SpeechBubble(
          nipLocation: NipLocation.LEFT,
          color: Colors.blue,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'This is a new cool feature !',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  ],
  child: MyMainWidget(),
);
```

It creates a `BubbleShowcase` widget with only one `BubbleSlide`.
This slide will highlight the widget that holds the key `widgetToHighlightKey`.
The speech bubble will be placed on the right of the widget.

BubbleShowcase is not limited to highlight a specific widget. You can also highlight a specific part of your app by its coordinates :

```dart
BubbleShowcase(
  bubbleShowcaseId: 'my_bubble_showcase',
  bubbleShowcaseVersion: 1,
  bubbleSlides: [
    AbsoluteBubbleSlide(
      positionCalculator: (size) => Position(
        top: 0,
        right: 0,
        bottom: 0,
        left: 0,
      ),
      child: AbsoluteBubbleSlideChild(
        positionCalculator: (size) => Position(
          top: 0,
          left: 0,
        ),
        widget: SpeechBubble(
          nipLocation: NipLocation.LEFT,
          color: Colors.blue,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'This is the top left corner of your app.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  ],
  child: MyMainWidget(),
);
```

This will display the speech bubble on the top left corner of your app.

## Options

### The showcase

The showcase is where everything begins. Let's see the available options :

* `bubbleShowcaseId` The showcase identifier. Must be unique across the app as it is used as a saving mean; for instance when the showcase should not be reopened (**required**).
* `bubbleShowcaseVersion` The showcase version. Increase it when you update the showcase, this allows to redisplay the it to the user if `doNotReopenOnClose` is set to `true` (**required**).
* `doNotReopenOnClose` Whether this showcase should be reopened once closed.
* `bubbleSlides` The slides to display (**required** & **must not be empty**).
* `child` The widget to display below the slides. It should be your app main widget.
* `counterText` The current slide counter text. `:i` targets the current slide number and `:n` targets the maximum slide number.
* `showCloseButton` Whether to show a little close button on the top left of the slide.

### The slides

The slides is what is highlighting a specific part of your app.
There are two main categories of positioning : _Absolute_ and _Relative_. Here is a little summary :

| Position | Class name            | Use case                                                                                                  | Specific options                                                                    |
|----------|-----------------------|-----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| Absolute | `AbsoluteBubbleSlide` | You want to position your slide according to a _x_, _y_ position on the screen and not a specific widget. | `positionCalculator` The function that calculates the slide position on the screen. |
| Relative | `RelativeBubbleSlide` | You want to position your slide according to a specific widget.                                           | `widgetKey` The global key that the target widget is holding.                       |

All slides have these options in common :

* `shape` The slide shape (available are `Rectangle`, `RoundedRectangle`, `Oval` and `Circle` but you can add a custom one by extending the `Shape` class).
* `boxShadow` The slide box shadow (containing the color, the blur radius, the spread radius, ...).
* `child` The slide child, see below (**required**).

### The slides children

Slides children are what are displayed according to what you are highlighting (it can be a speech bubble for example).
The same positioning system is also available for children :

| Position | Class name                 | Use case                                                                                                                  | Specific options                                                                    |
|----------|----------------------------|---------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| Absolute | `AbsoluteBubbleSlideChild` | You want to position the child according to a _x_, _y_ position on the screen and not the highlighted part of the screen. | `positionCalculator` The function that calculates the child position on the screen. |
| Relative | `RelativeBubbleSlideChild` | You want to position the child according to the highlighted zone.                                                         | `direction` Where to position the child compared to the highlighted zone.           |

All children have these options in common :

* `widget` The widget to display (**required**).

But you have a lot of other options !
Don't hesitate to check the [API Reference](https://pub.dev/documentation/bubble_showcase/latest/) or the [Github repo](https://github.com/Skyost/BubbleShowcase).

## Contributions

You have a lot of options to contribute to this project ! You can :

* [Fork it](https://github.com/Skyost/BubbleShowcase/fork) on Github.
* [Submit](https://github.com/Skyost/BubbleShowcase/issues/new/choose) a feature request or a bug report.
* [Donate](https://paypal.me/Skyost) to the developer.
* [Watch a little ad](https://www.clipeee.com/creator/skyost) on Clipeee.
