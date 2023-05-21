import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_race_view/src/rectangle.dart';

// TODO(rohan20): Add docs
/// ...
class ChartPainter extends CustomPainter {
  // TODO(rohan20): Add docs
  /// ...
  ChartPainter({
    required List<Rectangle> currentData,
    required double chartWidth,
    required String currentStateName,
    required TextStyle currentStateNameTextStyle,
  })  : _currentData = currentData,
        _chartWidth = chartWidth,
        _currentStateName = currentStateName,
        _currentStateNameTextStyle = currentStateNameTextStyle;

  final List<Rectangle> _currentData;
  final double _chartWidth;
  final String _currentStateName;
  final TextStyle _currentStateNameTextStyle;

  final double _rectHeight = 75;
  final double _numberOfRects = 4;
  final double _verticalSpaceBetweenTwoRects = 8;

  final Paint _linePaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _rectPaint = Paint()
    ..strokeWidth = 0
    ..style = PaintingStyle.fill
    ..strokeCap = StrokeCap.round;

  final _textPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // (0, 0) is the top-center of the canvas.

    // Paint the state name at the top-center of the canvas.
    _drawStateName(canvas, name: _currentStateName, chartWidth: _chartWidth);

    // Move the canvas's center to the left edge and add some vertical space
    // between the state name and the rest of the canvas.
    final verticalSpaceBetweenStateNameAndChart = _textPainter.height + 16.0;

    canvas.translate(
      (_chartWidth * -1) / 2,
      verticalSpaceBetweenStateNameAndChart,
    );

    // Paint the chart axes on the left edge of the canvas.
    _drawChartAxes(canvas);

    for (var i = 0; i < _currentData.length; i++) {
      _drawRectangle(canvas, rectangle: _currentData[i]);
    }
  }

  void _drawChartAxes(Canvas canvas) {
    _drawLine(canvas, posX: 0);
  }

  void _drawLine(Canvas canvas, {required double posX}) {
    final path = Path();

    final x1 = posX;
    const y1 = 0.0;

    final x2 = posX;
    final totalVerticalSpaceBetweenRects =
        _verticalSpaceBetweenTwoRects * (_numberOfRects - 1);
    final y2 = (_rectHeight * _numberOfRects) + totalVerticalSpaceBetweenRects;

    path
      ..moveTo(x1, y1)
      ..lineTo(x2, y2);

    canvas.drawPath(path, _linePaint);
  }

  void _drawRectangle(Canvas canvas, {required Rectangle rectangle}) {
    final path = Path();

    final chartHeight = _rectHeight * _numberOfRects +
        _verticalSpaceBetweenTwoRects * (_numberOfRects - 1);

    const x1 = 0.0;
    final y1 = rectangle.rank * (_rectHeight + _verticalSpaceBetweenTwoRects);

    final x2 = rectangle.width * _chartWidth;
    final y2 = min(y1 + _rectHeight, chartHeight);
    // min(...) ^so that the rectangle's top doesn't go out of the chart.

    path
      ..moveTo(x1, y1)
      ..lineTo(x2, y1)
      ..lineTo(x2, y2)
      ..lineTo(x1, y2);

    _rectPaint.color = rectangle.color;
    canvas.drawPath(path, _rectPaint);

    _drawTitleAndValue(
      canvas,
      title: rectangle.title,
      value: rectangle.value,
      rectTopRightX: x2,
      rectTopRightY: y1,
    );
  }

  void _drawTitleAndValue(
    Canvas canvas, {
    required String title,
    required double value,
    required double rectTopRightX,
    required double rectTopRightY,
  }) {
    var titleString = title;
    var valueString = value.round().toString();

    if (title.length > 15) {
      titleString = '${titleString.substring(0, 15)}..';
    }

    if (valueString.length > 5) {
      valueString = '${valueString.substring(0, 5)}..';
    }

    _textPainter.text = TextSpan(
      text: titleString,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    _paintText(canvas, x: rectTopRightX, y: rectTopRightY);

    final titleHeight = _textPainter.height;

    _textPainter.text = TextSpan(
      text: valueString,
      style: const TextStyle(color: Colors.black, fontSize: 16),
    );

    _paintText(
      canvas,
      x: rectTopRightX,
      y: rectTopRightY + titleHeight,
    );
  }

  void _paintText(
    Canvas canvas, {
    required double x,
    required double y,
  }) {
    canvas.save();

    _textPainter.layout();

    // Take the canvas to the top-right vertex of the rectangle
    canvas.translate(x, y);

    // Paint the value inside the rectangle having a vertical padding of 8px
    // from the right and 8px from the top.
    final textWidth = _textPainter.width;
    _textPainter.paint(canvas, Offset((textWidth + 8) * -1.0, 8));

    canvas.restore();
  }

  void _drawStateName(
    Canvas canvas, {
    required String name,
    required double chartWidth,
  }) {
    _textPainter
      ..text = TextSpan(text: name, style: _currentStateNameTextStyle)
      ..layout()
      ..paint(
        canvas,
        Offset(
          // This x-offset helps center the text instead of the text starting
          // from the center of the x-axis of canvas. This will display:
          // |          HelloWorld          |
          // |                              |
          // |                              |
          //
          // instead of:
          //
          // |               HelloWorld     |
          // |                              |
          // |                              |
          (_textPainter.width / 2) / -1.0,
          0,
        ),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
