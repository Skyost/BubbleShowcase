import 'dart:math';

import 'package:flutter/material.dart';

enum NipLocation { TOP, RIGHT, BOTTOM, LEFT, BOTTOM_RIGHT, BOTTOM_LEFT, TOP_RIGHT, TOP_LEFT }

const defaultNipHeight = 10.0;
var rotatedNip;

class SpeechBubble extends StatelessWidget {
  /// Creates a widget that emulates a speech bubble.
  /// Could be used for a tooltip, or as a pop-up notification, etc.
  SpeechBubble({
    Key? key,
    required this.child,
    this.nipLocation = NipLocation.BOTTOM,
    this.color = Colors.redAccent,
    this.borderRadius = 4.0,
    this.height,
    this.width,
    this.padding,
    this.nipHeight = defaultNipHeight,
    this.offset = Offset.zero,
  }) : super(key: key);

  /// The [child] contained by the [SpeechBubble]
  final Widget child;

  /// The location of the nip of the speech bubble.
  ///
  /// Use [NipLocation] enum, either [TOP], [RIGHT], [BOTTOM], or [LEFT].
  /// The nip will automatically center to the side that it is assigned.
  final NipLocation nipLocation;

  /// The color of the body of the [SpeechBubble] and nip.
  /// Defaultly red.
  final Color color;

  /// The [borderRadius] of the [SpeechBubble].
  /// The [SpeechBubble] is built with a circular border radius on all 4 corners.
  final double borderRadius;

  /// The explicitly defined height of the [SpeechBubble].
  /// The [SpeechBubble] will defaultly enclose its [child].
  final double? height;

  /// The explicitly defined width of the [SpeechBubble].
  /// The [SpeechBubble] will defaultly enclose its [child].
  final double? width;

  /// The padding between the child and the edges of the [SpeechBubble].
  final EdgeInsetsGeometry? padding;

  /// The nip height
  final double nipHeight;

  final Offset offset;

  @override
  Widget build(BuildContext context) {
    Offset? nipOffset;
    AlignmentGeometry? alignment;
    var rotatedNipHalfHeight = getNipHeight(nipHeight) / 2;
    var offset = nipHeight / 2 + rotatedNipHalfHeight;
    switch (nipLocation) {
      case NipLocation.TOP:
        nipOffset = Offset(0.0, -offset + rotatedNipHalfHeight);
        alignment = Alignment.topCenter;
        break;
      case NipLocation.RIGHT:
        nipOffset = Offset(offset - rotatedNipHalfHeight, 0.0);
        alignment = Alignment.centerRight;
        break;
      case NipLocation.BOTTOM:
        nipOffset = Offset(0.0, offset - rotatedNipHalfHeight);
        alignment = Alignment.bottomCenter;
        break;
      case NipLocation.LEFT:
        nipOffset = Offset(-offset + rotatedNipHalfHeight, 0.0);
        alignment = Alignment.centerLeft;
        break;
      case NipLocation.BOTTOM_LEFT:
        nipOffset = this.offset + Offset(offset - rotatedNipHalfHeight, offset - rotatedNipHalfHeight);
        alignment = Alignment.bottomLeft;
        break;
      case NipLocation.BOTTOM_RIGHT:
        nipOffset = this.offset + Offset(-offset + rotatedNipHalfHeight, offset - rotatedNipHalfHeight);
        alignment = Alignment.bottomRight;
        break;
      case NipLocation.TOP_LEFT:
        nipOffset = this.offset + Offset(offset - rotatedNipHalfHeight, -offset + rotatedNipHalfHeight);
        alignment = Alignment.topLeft;
        break;
      case NipLocation.TOP_RIGHT:
        nipOffset = this.offset + Offset(-offset + rotatedNipHalfHeight, -offset + rotatedNipHalfHeight);
        alignment = Alignment.topRight;
        break;
      default:
    }

    return Stack(
      alignment: alignment!,
      children: <Widget>[
        speechBubble(),
        nip(nipOffset!),
      ],
    );
  }

  Widget speechBubble() {
    return Material(
      borderRadius: BorderRadius.all(
        Radius.circular(borderRadius),
      ),
      color: color,
      elevation: 1.0,
      child: Container(
        height: height,
        width: width,
        padding: padding ?? const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  Widget nip(Offset nipOffset) {
    return Transform.translate(
      offset: nipOffset,
      child: RotationTransition(
        turns: const AlwaysStoppedAnimation(45 / 360),
        child: Material(
          borderRadius: const BorderRadius.all(
            Radius.circular(1.5),
          ),
          color: color,
          child: Container(
            height: nipHeight,
            width: nipHeight,
          ),
        ),
      ),
    );
  }

  double getNipHeight(double nipHeight) => sqrt(2 * pow(nipHeight, 2));
}
