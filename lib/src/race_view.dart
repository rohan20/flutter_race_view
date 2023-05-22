import 'package:flutter/material.dart';
import 'package:flutter_race_view/src/chart_painter.dart';
import 'package:flutter_race_view/src/rectangle.dart';

/// An animated bar chart depicting a race over time between the columns of
/// [data] where each column represents a participant in the race and each row
/// represents a single state of the chart.
class RaceView extends StatefulWidget {
  /// Basic constructor for [RaceView].
  const RaceView({
    required this.data,
    required this.dataColumnNames,
    required this.dataColumnColors,
    TextStyle? dataColumnNameTextStyle,
    TextStyle? dataColumnValueTextStyle,
    required this.dataRowNames,
    TextStyle? dataRowNameTextStyle,
    double? rectHeight,
    double? verticalSpaceBetweenTwoRects,
    super.key,
  })  : _dataRowNameTextStyle = dataRowNameTextStyle,
        _dataColumnNameTextStyle = dataColumnNameTextStyle,
        _dataColumnValueTextStyle = dataColumnValueTextStyle,
        _rectHeight = rectHeight ?? 50.0,
        _verticalSpaceBetweenTwoRects = verticalSpaceBetweenTwoRects ?? 8.0,
        assert(
          dataColumnNames.length == dataColumnColors.length,
          'The length of dataColumnNames and dataColumnColors must be the same',
        );

  /// A 2D array of data. Each row represents a single state of the chart.
  ///
  /// For example: If the length of [data] is 5, there will be 5 different
  /// states of the chart that it will animate between.
  final List<List<double>> data;

  /// The names of the columns in [data]. These end up being displayed on the
  /// y-axis of the chart where each rectangle represents one of these names.
  ///
  /// For example: If you were building a chart representing stocks of companies
  /// A, B, C and D, then [dataColumnNames] would be ['A', 'B', 'C', 'D'].
  final List<String> dataColumnNames;

  /// The colors of the columns in [data]. These end up being the colors of the
  /// rectangles in the chart.
  final List<Color> dataColumnColors;

  /// The names of the rows in [data].
  ///
  /// For example: If the length of [dataRowNames] is 5, there will be 5
  /// different states of the chart that it will animate between.
  ///
  /// Each entry in the list represents the name of that chart state.
  ///
  /// For example: If you were building a chart representing stocks of companies
  /// A, B, C and D, then [dataRowNames] could be the name of the year
  /// representing the value of the stock in each chart state. If the chart was
  /// displaying data over 6 years, where each chart state representing 1 year,
  /// then this would be a List of 6 strings:
  /// ['2017', '2018', '2019', '2020', '2021', '2022'].
  ///
  /// Only one entry from the list is displayed at a time at the bottom-right of
  /// the chart.
  final List<String> dataRowNames;

  final TextStyle? _dataRowNameTextStyle;

  final TextStyle? _dataColumnNameTextStyle;

  final TextStyle? _dataColumnValueTextStyle;

  final double _rectHeight;

  final double _verticalSpaceBetweenTwoRects;

  @override
  State<RaceView> createState() => _RaceViewState();
}

class _RaceViewState extends State<RaceView> {
  late final List<List<Rectangle>> _allStatesRectData;
  late final int statesCount;
  late final int rectsCount;
  late List<Rectangle> _currentStateRectData;
  late String _currentStateName;

  @override
  void initState() {
    super.initState();
    _allStatesRectData = _mapDataToAllStatesRectData();
    statesCount = _allStatesRectData.length;
    rectsCount = _allStatesRectData[0].length;
    _currentStateRectData = _allStatesRectData[0];
    _currentStateName = widget.dataRowNames[0];

    play();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (_, constraints) {
          return CustomPaint(
            painter: ChartPainter(
              currentData: _currentStateRectData,
              currentStateName: _currentStateName,
              currentStateNameTextStyle: widget._dataRowNameTextStyle,
              chartWidth: constraints.maxWidth * 0.9,
              rectTitleTextStyle: widget._dataColumnNameTextStyle,
              rectValueTextStyle: widget._dataColumnValueTextStyle,
              rectHeight: widget._rectHeight,
              verticalSpaceBetweenTwoRects:
                  widget._verticalSpaceBetweenTwoRects,
            ),
          );
        },
      ),
    );
  }

  Future<void> play() async {
    // Added this delay so that the user sees the initial state of the chart
    // before it starts autoplaying.
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    for (var i = 1; i < statesCount; i++) {
      _currentStateName = widget.dataRowNames[i];

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
    const fps = 90;

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

        if (!mounted) {
          return;
        }

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

      for (var j = 0; j < currentStateRectData.length; j++) {
        // Using this index ensures the rectangle with the highest value appears
        // at the top of the chart.
        final indexBasedOnSort = rectIndexesSortedByDataInDecreasingOrdered[j];

        final currentValue = currentStateRectData[indexBasedOnSort];
        final currentTitle = widget.dataColumnNames[indexBasedOnSort];

        final backgroundColor = widget.dataColumnColors[indexBasedOnSort];

        final rect = Rectangle(
          // rank of highest value rect is 0, rank of second highest value rect
          // is 1, etc.
          rank: j.toDouble(),
          width: currentValue / maxValue,
          color: backgroundColor,
          value: currentValue,
          title: currentTitle,
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
