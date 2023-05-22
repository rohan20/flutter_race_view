import 'package:flutter/material.dart';

/// Represents a single bar in the chart. Since the shape of the bar is a
/// rectangle, we call it [Rectangle].
class Rectangle {
  /// Basic constructor for [Rectangle].
  Rectangle({
    required this.rank,
    required this.width,
    required this.color,
    required this.value,
    required this.title,
  });

  /// Represents a rectangle with no data yet. Analogous to a null rectangle.
  factory Rectangle.dummy() {
    return Rectangle(
      rank: 0,
      width: 0,
      color: Colors.black,
      value: 0,
      title: '',
    );
  }

  /// Index of this rectangle in the chart on the y-axis.
  ///
  /// For example: A rectangle with [rank] 0 will be the top-most rectangle
  /// in the race view chart.
  double rank;

  /// The value represented by this rectangle. It directly influences the
  /// [width] of the rectangle.
  ///
  /// For example: If there are 3 elements on the chart with values 10, 20 and
  /// 30, then the width of the rectangle representing 30 will be 1, the width
  /// of the rectangle representing 20 will be 0.66 and the width of the
  /// rectangle representing 10 will be 0.33.
  double value;

  /// Width of this rectangle in the chart on the x-axis. Its value ranges
  /// between 0 and 1 (both inclusive).
  ///
  /// For example: If the width of the chart is 1000px and the width of
  /// this rectangle is 0.75, then the width of this rectangle will be 750px.
  double width;

  /// The title text displayed on the rectangle.
  String title;

  /// Background color of this rectangle. It is final because it only needs to
  /// be set once, after which the rectangle should retain the same color so
  /// that its movement can be tracked easily by the human eye.
  final Color color;
}
