import 'package:flutter/material.dart';
import 'package:flutter_race_view/flutter_race_view.dart';

class RaceViewDemoPage extends StatelessWidget {
  const RaceViewDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RaceViewDemoView();
  }
}

class RaceViewDemoView extends StatelessWidget {
  const RaceViewDemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock Prices (USD)')),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: RaceView(
          data: const [
            [10, 20, 30, 40, 50],
            [125, 135, 80, 70, 150],
            [205, 173, 120, 370, 260],
            [325, 483, 620, 570, 460],
            [225, 333, 820, 599, 660],
          ],
          dataColumnNames: const [
            'TSLA',
            'GOOG',
            'AAPL',
            'AMZN',
            'META',
          ],
          dataColumnColors: [
            Colors.red.shade200,
            Colors.green.shade200,
            Colors.blue.shade200,
            Colors.yellow.shade200,
            Colors.purple.shade200,
          ],
          dataRowNames: const [
            'Year 2017',
            'Year 2018',
            'Year 2019',
            'Year 2020',
            'Year 2021',
          ],
        ),
      ),
    );
  }
}
