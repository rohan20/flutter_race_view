import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_race_view/src/chart_painter.dart';
import 'package:flutter_race_view/src/rectangle.dart';

// TODO(rohan20): Add docs.
/// ...
class RaceView extends StatefulWidget {
  /// ...
  const RaceView({
    required this.data,
    super.key,
  });

  /// A 2D array of data. Each row represents a single state of the chart.
  ///
  /// For example: If the length of [data] is 5, there will be 5 different
  /// states of the chart that it will animate between.
  final List<List<double>> data;

  @override
  State<RaceView> createState() => _RaceViewState();
}

class _RaceViewState extends State<RaceView> {
  late final List<List<Rectangle>> _allStatesRectData;
  late final int statesCount;
  late final int rectsCount;
  late List<Rectangle> _currentStateRectData;

  @override
  void initState() {
    super.initState();
    _allStatesRectData = _mapDataToAllStatesRectData();
    statesCount = _allStatesRectData.length;
    rectsCount = _allStatesRectData[0].length;
    _currentStateRectData = _allStatesRectData[0];

    play();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return CustomPaint(
          painter: ChartPainter(
            currentData: _currentStateRectData,
            chartWidth: constraints.maxWidth * 0.75,
          ),
        );
      },
    );
  }

  Future<void> play() async {
    for (var i = 1; i < statesCount; i++) {
      await _animateBetweenStates(
        fromStateRectData: _allStatesRectData[i - 1],
        toStateRectData: _allStatesRectData[i],
      );
    }
  }

  Future<void> _animateBetweenStates({
    required List<Rectangle> fromStateRectData,
    required List<Rectangle> toStateRectData,
  }) async {
    const framesCount = 30;
    const fps = 60;

    for (var currentFrame = 1; currentFrame <= framesCount; currentFrame++) {
      // for each frame, update the current state of the chart
      for (var currentRect = 0; currentRect < rectsCount; currentRect++) {
        // find the difference between the two chart states

        final toStateRect = toStateRectData[currentRect];
        final fromStateRect = fromStateRectData[currentRect];

        final positionDifferencePerFrame =
            (toStateRect.rank - fromStateRect.rank) / framesCount;
        final widthDifferencePerFrame =
            (toStateRectData[currentRect].width - fromStateRect.width) /
                framesCount;
        final valueDifferencePerFrame =
            (toStateRectData[currentRect].value - fromStateRect.value) /
                framesCount;

        setState(() {
          _currentStateRectData[currentRect].rank =
              fromStateRectData[currentRect].rank +
                  (positionDifferencePerFrame * currentFrame);

          _currentStateRectData[currentRect].width =
              fromStateRectData[currentRect].width +
                  (widthDifferencePerFrame * currentFrame);

          _currentStateRectData[currentRect].value =
              fromStateRectData[currentRect].value +
                  (valueDifferencePerFrame * currentFrame);

          /*
            We intentionally do not update the color of
            _currentStateRectData[currentRect] here because we want to keep the
            same colors as those assigned to each rect in the first frame, i.e.
            when i=0 and j=0 in _mapDataToAllStatesRectData().
           */
        });

        await Future<void>.delayed(const Duration(milliseconds: 1000 ~/ fps));
      }
    }
  }

  List<List<Rectangle>> _mapDataToAllStatesRectData() {
    final allStatesRectData = <List<Rectangle>>[];

    for (var i = 0; i < widget.data.length; i++) {
      final currentStateRectData = widget.data[i];

      final stateRectData = List.filled(
        currentStateRectData.length,
        Rectangle.dummy(),
        growable: true,
      );

      final rectIndexesSortedByDataInDecreasingOrdered = List<int>.generate(
        currentStateRectData.length,
        (index) => index,
      )..sort((a, b) {
          return currentStateRectData[b].compareTo(currentStateRectData[a]);
        });

      final maxValue = currentStateRectData[
          rectIndexesSortedByDataInDecreasingOrdered.first];

      // TODO(rohan20): Sort in decreasing order
      for (var j = 0; j < currentStateRectData.length; j++) {
        final indexBasedOnSort = rectIndexesSortedByDataInDecreasingOrdered[j];

        final currentValue = currentStateRectData[indexBasedOnSort];

        final randomColor = Color((Random().nextDouble() * 0xFFFFFF).toInt());

        final rect = Rectangle(
          rank: j * 1.0,
          width: currentValue / maxValue,
          color: randomColor.withOpacity(1),
          value: currentValue,
        );

        // Replace previous rect with new rect
        stateRectData
          ..removeAt(indexBasedOnSort)
          ..insert(indexBasedOnSort, rect);
      }

      allStatesRectData.add(stateRectData);
    }

    return allStatesRectData;
  }
}
