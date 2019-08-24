library bubble_showcase;

import 'package:bubble_showcase/src/slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The BubbleShowcase main widget.
class BubbleShowcase extends StatefulWidget {
  /// This showcase identifier. Must be unique across the app.
  final String bubbleShowCaseId;

  /// This showcase version.
  final int bubbleShowCaseVersion;

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

  /// Creates a new bubble showcase instance.
  BubbleShowcase({
    @required this.bubbleShowCaseId,
    @required this.bubbleShowCaseVersion,
    this.doNotReopenOnClose = false,
    @required this.bubbleSlides,
    this.child,
    this.counterText = ':i/:n',
    this.showCloseButton = true,
  }) : assert(bubbleSlides.isNotEmpty);

  @override
  State<StatefulWidget> createState() => _BubbleShowcaseState();

  /// Whether this showcase should be opened.
  Future<bool> get shouldOpenShowcase async {
    if (!doNotReopenOnClose) {
      return true;
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool result = preferences.getBool(bubbleShowCaseId + '.' + bubbleShowCaseVersion.toString());
    return result == null || result;
  }
}

/// The BubbleShowcase state.
class _BubbleShowcaseState extends State<BubbleShowcase> with WidgetsBindingObserver {
  /// The current slide index.
  int _currentSlideIndex = -1;

  /// The current slide entry.
  OverlayEntry _currentSlideEntry;

  @override
  void initState() {
    if (_currentSlideEntry != null) {
      _currentSlideEntry.remove();
    }
    _currentSlideEntry = _createCurrentSlideEntry();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await widget.shouldOpenShowcase) {
        _currentSlideIndex++;
      }

      Overlay.of(context).insert(_currentSlideEntry);
    });
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _currentSlideEntry.remove();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _currentSlideEntry.remove();
      Overlay.of(context).insert(_currentSlideEntry);
    });
  }

  /// Returns whether the showcasing is finished.
  bool get _isFinished => _currentSlideIndex == -1 || _currentSlideIndex == widget.bubbleSlides.length;

  /// Closes the showcase if finished.
  void _closeIfFinished() {
    if (!_isFinished) {
      return;
    }

    _currentSlideEntry = null;
    if (widget.doNotReopenOnClose) {
      SharedPreferences.getInstance().then((preferences) {
        preferences.setBool(widget.bubbleShowCaseId + '.' + widget.bubbleShowCaseVersion.toString(), false);
      });
    }
  }

  /// Creates the current slide entry.
  OverlayEntry _createCurrentSlideEntry() => OverlayEntry(
        builder: (context) => widget.bubbleSlides[_currentSlideIndex].build(
          context,
          widget,
          _currentSlideIndex,
          (position) => setState(() {
            _currentSlideIndex = position;
            _currentSlideEntry.remove();
            _closeIfFinished();

            if (!_isFinished) {
              _currentSlideEntry = _createCurrentSlideEntry();
              Overlay.of(context).insert(_currentSlideEntry);
            }
          }),
        ),
      );
}
