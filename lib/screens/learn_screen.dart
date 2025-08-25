import 'package:flutter/material.dart';

import 'nutrition_guide_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly show the comprehensive Nutrition Guide
    return const NutritionGuideScreen();
  }
}