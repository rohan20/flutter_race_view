import 'package:flutter/material.dart';

// TODO(rohan20): Add docs
/// ...
class Rectangle {
  // TODO(rohan20): Add docs
  /// ...
  Rectangle({
    /// Index of this rectangle in the chart on the y-axis
    required this.rank,

    /// ...
    required this.width,

    /// ...
    required this.color,

    /// ...
    required this.value,

    /// ...
    required this.title,
  });

  /// ...
  factory Rectangle.dummy() {
    return Rectangle(
      rank: 0,
      width: 0,
      color: Colors.black,
      value: 0,
      title: '',
    );
  }

  /// ...
  double rank;

  /// ...
  double value;

  /// ...
  double width;

  /// ...
  String title;

  /// ...
  final Color color;
}
