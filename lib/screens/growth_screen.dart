import 'package:flutter/material.dart';

class GrowthScreen extends StatelessWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth Tracking'),
      ),
      body: const Center(
        child: Text('Growth Screen'),
      ),
    );
  }
}