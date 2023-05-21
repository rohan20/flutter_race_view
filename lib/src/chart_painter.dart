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
  })  : _currentData = currentData,
        _chartWidth = chartWidth;

  final List<Rectangle> _currentData;
  final double _chartWidth;

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

  final _valueTextPainter = TextPainter(
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // (0, 0) is the center of the UI. We want the canvas to start on the left.
    canvas.translate((_chartWidth * -1) / 2, 0);

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

    _drawValue(canvas, value: rectangle.value, x2: x2, y1: y1);
  }

  void _drawValue(
    Canvas canvas, {
    required double value,
    required double x2,
    required double y1,
  }) {
    var valueString = value.round().toString();

    if (valueString.length > 5) {
      valueString = '${valueString.substring(0, 5)}..';
    }

    _valueTextPainter.text = TextSpan(
      text: valueString,
      style: const TextStyle(color: Colors.black, fontSize: 12),
    );

    canvas.save();

    _valueTextPainter.layout();

    canvas.translate(x2, y1 + 3);

    _valueTextPainter.paint(canvas, const Offset(5, 0));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
