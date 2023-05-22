import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Hello World')),
      body: const SizedBox(),
    );
  }
}
