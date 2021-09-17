library bubble_showcase;

import 'package:bubble_showcase/src/slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String? counterText;

  /// Whether to show a close button.
  final bool showCloseButton;

  // Duration by which delay showcase initialization.
   final Duration initialDelay;

  /// Creates a new bubble showcase instance.
  BubbleShowcase({
    required this.bubbleShowcaseId,
    required this.bubbleShowcaseVersion,
    this.doNotReopenOnClose = false,
    required this.bubbleSlides,
    required this.child,
    this.counterText = ':i/:n',
    this.showCloseButton = true,
    this.initialDelay = Duration.zero,
  }) : assert(bubbleSlides.isNotEmpty);

  @override
  State<StatefulWidget> createState() => _BubbleShowcaseState();

  /// Whether this showcase should be opened.
  Future<bool> get shouldOpenShowcase async {
    if (!doNotReopenOnClose) {
      return true;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool? result = preferences.getBool('$bubbleShowcaseId.$bubbleShowcaseVersion');
    return result == null || result;
  }
}

/// The BubbleShowcase state.
class _BubbleShowcaseState extends State<BubbleShowcase> with WidgetsBindingObserver {
  /// The current slide index.
  int currentSlideIndex = -1;

  /// The current slide entry.
  OverlayEntry? currentSlideEntry;

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      if (await widget.shouldOpenShowcase) {
        await Future.delayed(widget.initialDelay);
        if (mounted) {
          goToNextEntryOrClose(0);
        }
      }
    });
    WidgetsBinding.instance?.addObserver(this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    currentSlideEntry?.remove();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (currentSlideEntry != null) {
        currentSlideEntry!.remove();
        Overlay.of(context)?.insert(currentSlideEntry!);
      }
    });
  }

  /// Returns whether the showcasing is finished.
  bool get isFinished => currentSlideIndex == -1 || currentSlideIndex == widget.bubbleSlides.length;

  /// Allows to go to the next entry (or to close the showcase if needed).
  void goToNextEntryOrClose(int position) {
    currentSlideIndex = position;
    currentSlideEntry?.remove();
    triggerOnExit();

    if (isFinished) {
      currentSlideEntry = null;
      if (widget.doNotReopenOnClose) {
        SharedPreferences.getInstance().then((preferences) {
          preferences.setBool('${widget.bubbleShowcaseId}.${widget.bubbleShowcaseVersion}', false);
        });
      }
    } else {
      currentSlideEntry = createCurrentSlideEntry();
      Overlay.of(context)?.insert(currentSlideEntry!);
      triggerOnEnter();
    }
  }

  /// Creates the current slide entry.
  OverlayEntry createCurrentSlideEntry() => OverlayEntry(
        builder: (context) => widget.bubbleSlides[currentSlideIndex].build(
          context,
          widget,
          currentSlideIndex,
          (position) {
            setState(() => goToNextEntryOrClose(position));
          },
        ),
      );

  /// Allows to trigger enter callbacks.
  void triggerOnEnter() {
    if (currentSlideIndex >= 0 && currentSlideIndex < widget.bubbleSlides.length) {
      VoidCallback? callback = widget.bubbleSlides[currentSlideIndex].onEnter;
      if (callback != null) {
        callback();
      }
    }
  }

  /// Allows to trigger exit callbacks.
  void triggerOnExit() {
    if (currentSlideIndex >= 0 && currentSlideIndex < widget.bubbleSlides.length) {
      VoidCallback? callback = widget.bubbleSlides[currentSlideIndex].onExit;
      if (callback != null) {
        callback();
      }
    }
  }
}
