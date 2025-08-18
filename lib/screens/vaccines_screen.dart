import 'package:flutter/material.dart';

class VaccinesScreen extends StatelessWidget {
  const VaccinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccines'),
      ),
      body: const Center(
        child: Text('Vaccines Screen'),
      ),
    );
  }
}