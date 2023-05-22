import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_race_view/src/rectangle.dart';

/// Paints a particular state of the chart that comprises of the chart-title,
/// chart-axes and rectangles formed by currentData.
class ChartPainter extends CustomPainter {
  /// Basic constructor for [ChartPainter].
  ChartPainter({
    required List<Rectangle> currentData,
    required String currentStateName,
    required TextStyle currentStateNameTextStyle,
    required TextStyle rectTitleTextStyle,
    required TextStyle rectValueTextStyle,
    required double rectHeight,
    required double verticalSpaceBetweenTwoRects,
    required double verticalSpaceBetweenStateNameAndChart,
  })  : _currentData = currentData,
        _currentStateName = currentStateName,
        _currentStateNameTextStyle = currentStateNameTextStyle,
        _rectTitleTextStyle = rectTitleTextStyle,
        _rectValueTextStyle = rectValueTextStyle,
        _numberOfRects = currentData.length,
        _rectHeight = rectHeight,
        _verticalSpaceBetweenTwoRects = verticalSpaceBetweenTwoRects,
        _verticalSpaceBetweenStateNameAndChart =
            verticalSpaceBetweenStateNameAndChart;

  final List<Rectangle> _currentData;
  final String _currentStateName;

  final TextStyle _currentStateNameTextStyle;
  final TextStyle _rectTitleTextStyle;
  final TextStyle _rectValueTextStyle;

  late final double _rectHeight;
  late final int _numberOfRects;
  late final double _verticalSpaceBetweenTwoRects;
  late final double _verticalSpaceBetweenStateNameAndChart;

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
    // (0, 0) is the top-left of the canvas.

    // Move the canvas to the top-center
    canvas.translate(size.width / 2, 0);

    final chartWidth = size.width * 0.9;

    // Paint the state name at the top-center of the canvas.
    _drawStateName(canvas, name: _currentStateName, chartWidth: chartWidth);

    // Move the canvas's center to the left edge and add some vertical space
    // between the state name and the rest of the canvas.
    final verticalSpaceBetweenStateNameAndChart =
        _textPainter.height + _verticalSpaceBetweenStateNameAndChart;

    canvas.translate(
      (chartWidth * -1) / 2,
      verticalSpaceBetweenStateNameAndChart,
    );

    // Paint the chart axes on the left edge of the canvas.
    _drawChartAxes(canvas);

    for (var i = 0; i < _currentData.length; i++) {
      _drawRectangle(
        canvas,
        rectangle: _currentData[i],
        chartWidth: chartWidth,
      );
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

  void _drawRectangle(
    Canvas canvas, {
    required Rectangle rectangle,
    required double chartWidth,
  }) {
    final path = Path();

    final chartHeight = _rectHeight * _numberOfRects +
        _verticalSpaceBetweenTwoRects * (_numberOfRects - 1);

    const x1 = 0.0;
    final y1 = rectangle.rank * (_rectHeight + _verticalSpaceBetweenTwoRects);

    final x2 = rectangle.width * chartWidth;
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
    final valueString = value.round().toString();

    if (title.length > 35) {
      titleString = '${titleString.substring(0, 35)}..';
    }

    // paint the title just inside the top-right vertex of the rectangle
    _textPainter.text = TextSpan(text: titleString, style: _rectTitleTextStyle);
    _paintText(canvas, x: rectTopRightX, y: rectTopRightY);

    // paint the value below title
    final titleHeight = _textPainter.height;
    _textPainter.text = TextSpan(text: valueString, style: _rectValueTextStyle);
    _paintText(canvas, x: rectTopRightX, y: rectTopRightY + titleHeight);
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
