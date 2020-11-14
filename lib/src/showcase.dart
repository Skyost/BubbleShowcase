library bubble_showcase;

import 'dart:async';
import 'package:bubble_showcase/src/slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SlideControllerAction {
  next,
  previous,
  close,
}

/// The BubbleShowcase main widget.
class BubbleShowcase extends StatefulWidget {
  /// This showcase identifier. Must be unique across the app.
  final String bubbleShowcaseId;

  /// This showcase version.
  final int bubbleShowcaseVersion;

  /// Whether this showcase should reopen once closed.
  final bool doNotReopenOnClose;

  /// All slides.
  final List<BubbleSlide> bubbleSlides;

  /// The child widget (displayed below the showcase).
  final Widget child;

  /// The counter text (:i is the current slide, :n is the slides count). You can pass null to disable this.
  final String counterText;

  /// Whether to show a close button.
  final bool showCloseButton;

  /// Whether to enable click on overlay to go to next slide
  final bool enabledClickOnOverlayToNextSlide;

  /// Trigger this stream to change slide by position number
  final Stream<int> slideNumberStream;

  /// Trigger to control slide
  final Stream<SlideControllerAction> slideActionStream;

  /// Creates a new bubble showcase instance.
  BubbleShowcase({
    @required this.bubbleShowcaseId,
    @required this.bubbleShowcaseVersion,
    this.doNotReopenOnClose = false,
    @required this.bubbleSlides,
    this.child,
    this.counterText = ':i/:n',
    this.showCloseButton = true,
    this.enabledClickOnOverlayToNextSlide = true,
    this.slideNumberStream,
    this.slideActionStream,
  }) : assert(bubbleSlides.isNotEmpty);

  @override
  State<StatefulWidget> createState() => _BubbleShowcaseState();

  /// Whether this showcase should be opened.
  Future<bool> get shouldOpenShowcase async {
    if (!doNotReopenOnClose) {
      return true;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool result =
        preferences.getBool('$bubbleShowcaseId.$bubbleShowcaseVersion');
    return result == null || result;
  }
}

/// The BubbleShowcase state.
class _BubbleShowcaseState extends State<BubbleShowcase>
    with WidgetsBindingObserver {
  /// The current slide index.
  int _currentSlideIndex = -1;

  /// The current slide entry.
  OverlayEntry _currentSlideEntry;

  // StreamSubscription slideNumberSubscription;
  // StreamSubscription slideActionSubscription;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await widget.shouldOpenShowcase) {
        _currentSlideIndex++;
        _currentSlideEntry = _createCurrentSlideEntry();
        Overlay.of(context).insert(_currentSlideEntry);
      }
    });
    WidgetsBinding.instance.addObserver(this);

    super.initState();
    if (widget.slideNumberStream != null) {
      widget.slideNumberStream.listen(
        (position) {
          _goToNextEntryOrClose(position);
        },
      );
    }
    if (widget.slideActionStream != null) {
      widget.slideActionStream.listen((action) {
        _slideActionHandler(action);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _currentSlideEntry?.remove();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    // if (slideNumberSubscription != null) {
    //   slideNumberSubscription.cancel();
    // }
    // if (slideActionSubscription != null) {
    //   slideActionSubscription.cancel();
    // }
  }

  @override
  void didChangeMetrics() {
    if (_currentSlideEntry == null) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _currentSlideEntry.remove();
      Overlay.of(context).insert(_currentSlideEntry);
    });
  }

  @override
  void didUpdateWidget(BubbleShowcase old) {
    super.didUpdateWidget(old);
    // in case the stream instance changed, subscribe to the new one
    if (widget.slideNumberStream != null) {
      if (widget.slideNumberStream != old.slideNumberStream) {
        // if (slideNumberSubscription != null) {
        //   slideNumberSubscription.cancel();
        // }
        widget.slideNumberStream.listen((position) {
          _goToNextEntryOrClose(position);
        });
      }
    }
    if (widget.slideActionStream != null) {
      if (widget.slideActionStream != old.slideActionStream) {
        // if (slideActionSubscription != null) {
        //   slideActionSubscription.cancel();
        // }
        widget.slideActionStream.listen((action) {
          _slideActionHandler(action);
        });
      }
    }
  }

  /// Returns whether the showcasing is finished.
  bool get _isFinished =>
      _currentSlideIndex == -1 ||
      _currentSlideIndex >= widget.bubbleSlides.length;

  /// Allows to go to the next entry (or to close the showcase if needed).
  void _goToNextEntryOrClose(int position) {
    if (position < -1) {
      return;
    }

    _currentSlideIndex = position;
    _currentSlideEntry.remove();

    if (_isFinished) {
      _currentSlideEntry = null;
      if (widget.doNotReopenOnClose) {
        SharedPreferences.getInstance().then((preferences) {
          preferences.setBool(
              '${widget.bubbleShowcaseId}.${widget.bubbleShowcaseVersion}',
              false);
        });
      }
    } else {
      _currentSlideEntry = _createCurrentSlideEntry();
      Overlay.of(context).insert(_currentSlideEntry);
    }
  }

  void _slideActionHandler(SlideControllerAction action) {
    switch (action) {
      case SlideControllerAction.next:
        _goToNextEntryOrClose(_currentSlideIndex + 1);
        break;
      case SlideControllerAction.previous:

        /// Prevent close when invoke previous on first slide
        if (_currentSlideIndex != 0) {
          _goToNextEntryOrClose(_currentSlideIndex - 1);
        }
        break;
      case SlideControllerAction.close:
        _goToNextEntryOrClose(-1);
        break;
    }
  }

  /// Creates the current slide entry.
  OverlayEntry _createCurrentSlideEntry() {
    return OverlayEntry(
      builder: (context) => widget.bubbleSlides[_currentSlideIndex].build(
        context,
        widget,
        _currentSlideIndex,
        (position) {
          setState(() => _goToNextEntryOrClose(position));
        },
      ),
    );
  }
}
