import 'package:flutter/material.dart';

/// Represents a highlight shape.
abstract class Shape {
  /// Creates a new shape instance.
  const Shape();

  /// Draw the shape on the specified canvas.
  void drawOnCanvas(Canvas canvas, Rect rectangle, Paint paint);

  void makePath(Path path, Rect rectangle);
}

/// A rectangle shape.
class Rectangle extends Shape {
  /// The spread radius.
  final double spreadRadius;

  /// Creates a new rectangle shape instance.
  const Rectangle({
    this.spreadRadius = 0,
  });

  @override
  void drawOnCanvas(Canvas canvas, Rect rectangle, Paint paint) {
    canvas.drawRect(rectangle.inflate(spreadRadius), paint);
  }

  @override
  void makePath(Path path, Rect rectangle) {
    path.addRect(rectangle);
  }
}

/// A rounded rectangle shape.
class RoundedRectangle extends Shape {
  /// The spread radius.
  final double spreadRadius;

  /// The border radius.
  final Radius radius;

  /// Creates a new rounded rectangle shape instance.
  const RoundedRectangle({
    this.spreadRadius = 0,
    required this.radius,
  });

  @override
  void drawOnCanvas(Canvas canvas, Rect rectangle, Paint paint) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(rectangle.inflate(spreadRadius), radius),
        paint);
  }

  @override
  void makePath(Path path, Rect rectangle) {
    path.addRRect(RRect.fromRectAndRadius(rectangle, radius));
  }
}

/// An oval shape.
class Oval extends Shape {
  /// The spread radius.
  final double spreadRadius;

  /// Creates a oval shape instance.
  const Oval({
    this.spreadRadius = 0,
  });

  @override
  void drawOnCanvas(Canvas canvas, Rect rectangle, Paint paint) {
    canvas.drawOval(rectangle.inflate(spreadRadius), paint);
  }

  @override
  void makePath(Path path, Rect rectangle) {
    path.addOval(rectangle.inflate(spreadRadius));
  }
}

/// A circle shape.
class Circle extends Shape {
  /// The spread radius.
  final double spreadRadius;

  /// Creates a circle shape instance.
  const Circle({
    this.spreadRadius = 0,
  });

  @override
  void drawOnCanvas(Canvas canvas, Rect rectangle, Paint paint) {
    Rect circle = rectangle.inflate(spreadRadius);
    canvas.drawCircle(circle.center, circle.longestSide / 2, paint);
  }

  @override
  void makePath(Path path, Rect rectangle) {
    path.addOval(
      Rect.fromCircle(center: rectangle.center, radius: rectangle.width / 2),
    );
  }
}
