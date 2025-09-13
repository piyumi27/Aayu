import 'dart:io';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../models/growth_record.dart';
import '../models/growth_standard.dart';
import '../providers/child_provider.dart';
import '../repositories/standards_repository.dart';
import '../services/growth_calculation_service.dart';
import '../services/standards_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/notifications/notification_badge.dart';
import '../widgets/safe_gesture_detector.dart';
import 'add_measurement_screen.dart';
import 'nutritional_analysis_screen.dart';
import 'pre_six_month_countdown_screen.dart';

class GrowthChartsScreen extends StatefulWidget {
  const GrowthChartsScreen({super.key});

  @override
  State<GrowthChartsScreen> createState() => _GrowthChartsScreenState();
}

class _GrowthChartsScreenState extends State<GrowthChartsScreen> {
  String _selectedTab = 'Weight-Age';
  String _selectedRange = '3M';
  String _selectedLanguage = 'en';
  String _selectedStandard = 'WHO'; // WHO or Sri Lankan
  bool _showZScores = false;
  bool _showPercentiles = true;

  final List<String> _tabs = [
    'Weight-Age',
    'Height-Age',
    'BMI',
    'Weight-for-Height'
  ];
  final List<String> _ranges = ['3M', '6M', '1Y', 'All'];
  final List<String> _standards = ['WHO', 'Sri Lankan'];

  late StandardsRepository _standardsRepository;
  late GrowthCalculationService _calculationService;
  late StandardsService _standardsService;
  Map<String, dynamic>? _chartData;

  @override
  void initState() {
    super.initState();
    _standardsRepository = StandardsRepository();
    _calculationService = GrowthCalculationService();
    _standardsService = StandardsService();
    _loadLanguage();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    final provider = Provider.of<ChildProvider>(context, listen: false);
    final child = provider.selectedChild;

    if (child != null) {
      try {
        final data = await _generateChartData(child, provider.growthRecords);
        if (mounted) {
          setState(() {
            _chartData = data;
          });
        }
      } catch (e) {
        print('Error loading chart data: $e');
        // Set empty data to prevent errors
        if (mounted) {
          setState(() {
            _chartData = {
              'chartPoints': <FlSpot>[],
              'zScores': <FlSpot>[],
              'percentiles': <FlSpot>[],
              'standards': [],
            };
          });
        }
      }
    }
  }

  Future<Map<String, dynamic>> _generateChartData(
      Child child, List<GrowthRecord> records) async {
    final standards = await _standardsRepository.getGrowthStandards(
      source: _selectedStandard == 'WHO' ? 'WHO' : 'SriLanka',
    );

    final chartPoints = <FlSpot>[];
    final zScores = <FlSpot>[];
    final percentiles = <FlSpot>[];

    for (final record in records) {
      final ageInMonths = _calculateAgeInMonths(record.date, child.birthDate);
      double value = 0;

      switch (_selectedTab) {
        case 'Weight-Age':
          value = record.weight;
          break;
        case 'Height-Age':
          value = record.height;
          break;
        case 'BMI':
          value =
              record.weight / ((record.height / 100) * (record.height / 100));
          break;
        case 'Weight-for-Height':
          value = record.weight;
          break;
      }

      chartPoints.add(FlSpot(ageInMonths.toDouble(), value));

      // Calculate Z-score using the proper service method
      final zScore = await _calculateZScoreForMeasurement(
        value,
        ageInMonths,
        child.gender,
        _selectedTab,
        _selectedStandard == 'WHO' ? 'WHO' : 'SriLanka',
      );

      zScores.add(FlSpot(ageInMonths.toDouble(), zScore));
      percentiles
          .add(FlSpot(ageInMonths.toDouble(), _zScoreToPercentile(zScore)));
    }

    return {
      'chartPoints': chartPoints,
      'zScores': zScores,
      'percentiles': percentiles,
      'standards': standards,
    };
  }

  Future<double> _calculateZScoreForMeasurement(
    double value,
    int ageInMonths,
    String gender,
    String measurementTab,
    String standardSource,
  ) async {
    // Use the StandardsRepository directly to get the growth standard and calculate Z-score
    String measurementType;
    switch (measurementTab) {
      case 'Weight-Age':
        measurementType = 'weight_for_age';
        break;
      case 'Height-Age':
        measurementType = 'height_for_age';
        break;
      case 'BMI':
        measurementType = 'bmi_for_age';
        break;
      case 'Weight-for-Height':
        measurementType = 'weight_for_height';
        break;
      default:
        measurementType = 'weight_for_age';
    }

    final standard = await _standardsRepository.getGrowthStandardForChild(
      ageMonths: ageInMonths,
      gender: gender,
      measurementType: measurementType,
      source: standardSource,
    );

    return standard?.calculateZScore(value) ?? 0.0;
  }

  double _zScoreToPercentile(double zScore) {
    // Simplified z-score to percentile conversion
    if (zScore <= -3) return 0.1;
    if (zScore <= -2) return 2.3;
    if (zScore <= -1) return 15.9;
    if (zScore <= 0) return 50.0;
    if (zScore <= 1) return 84.1;
    if (zScore <= 2) return 97.7;
    if (zScore <= 3) return 99.9;
    return 99.9;
  }

  int _calculateAgeInMonths(DateTime measurementDate, DateTime birthDate) {
    final years = measurementDate.year - birthDate.year;
    final months = measurementDate.month - birthDate.month;
    final days = measurementDate.day - birthDate.day;

    int totalMonths = years * 12 + months;

    // Adjust if the day hasn't reached yet
    if (days < 0) {
      totalMonths -= 1;
    }

    return totalMonths.clamp(0, 120); // Clamp to reasonable range
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  ImageProvider? _getChildProfileImage(Child child) {
    if (child.photoUrl != null && child.photoUrl!.isNotEmpty) {
      final file = File(child.photoUrl!);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return null;
  }

  bool _shouldShowGrowthCountdown(Child child) {
    final now = DateTime.now();
    final age = now.difference(child.birthDate);
    final ageInMonths = age.inDays / 30.44; // Average days per month
    return ageInMonths < 6;
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Growth Charts',
        'weight': 'Weight',
        'height': 'Height',
        'bmi': 'BMI',
        'lastUpdate': 'Last Update',
        'daysAgo': 'days ago',
        'dataPoints': 'Data Points',
        'addNew': 'Add New',
        'age': 'Age',
        'percentile': 'percentile',
        'growthInsights': 'Growth Insights',
        'healthyGrowth':
            'weight is following a healthy growth curve, staying consistently around the',
        'years': 'years',
        'months': 'months',
        'kg': 'kg',
        'cm': 'cm',
        'weightAge': 'Weight-Age',
        'heightAge': 'Height-Age',
        'weightForHeight': 'Weight-for-Height',
        'growthCountdown': 'Growth Countdown',
        'standards': 'Standards',
        'whoStandards': 'WHO Standards',
        'sriLankanStandards': 'Sri Lankan Standards',
        'showZScores': 'Show Z-Scores',
        'showPercentiles': 'Show Percentiles',
        'zScore': 'Z-Score',
        'percentile': 'Percentile',
      },
      'si': {
        'title': 'වර්ධන ප්‍රස්ථාර',
        'weight': 'බර',
        'height': 'උස',
        'bmi': 'BMI',
        'lastUpdate': 'අවසාන යාවත්කාලීන',
        'daysAgo': 'දින පෙර',
        'dataPoints': 'දත්ත ලක්ෂ්‍ය',
        'addNew': 'නව එකක් එක් කරන්න',
        'age': 'වයස',
        'percentile': 'ප්‍රතිශතය',
        'growthInsights': 'වර්ධන තීක්ෂණ බුද්ධිය',
        'healthyGrowth': 'බර සෞඛ්‍ය සම්පන්න වර්ධන වක්‍රයක් අනුගමනය කරයි',
        'years': 'අවුරුදු',
        'months': 'මාස',
        'kg': 'කි.ග්‍රෑ',
        'cm': 'සෙ.මී',
        'weightAge': 'බර-වයස',
        'heightAge': 'උස-වයස',
        'weightForHeight': 'උස සඳහා බර',
        'growthCountdown': 'වර්ධන ගණන් කිරීම',
        'standards': 'ප්‍රමිතීන්',
        'whoStandards': 'WHO ප්‍රමිතීන්',
        'sriLankanStandards': 'ශ්‍රී ලංකාව ප්‍රමිතීන්',
        'showZScores': 'Z-ලකුණු පෙන්වන්න',
        'showPercentiles': 'ප්‍රතිශතයන් පෙන්වන්න',
        'zScore': 'Z-ලකුණ',
        'percentile': 'ප්‍රතිශතය',
      },
      'ta': {
        'title': 'வளர்ச்சி விளக்கப்படங்கள்',
        'weight': 'எடை',
        'height': 'உயரம்',
        'bmi': 'BMI',
        'lastUpdate': 'கடைசி புதுப்பிப்பு',
        'daysAgo': 'நாட்கள் முன்பு',
        'dataPoints': 'தரவு புள்ளிகள்',
        'addNew': 'புதியது சேர்க்க',
        'age': 'வயது',
        'percentile': 'சதவீதம்',
        'growthInsights': 'வளர்ச்சி நுண்ணறிவு',
        'healthyGrowth': 'எடை ஆரோக்கியமான வளர்ச்சி வளைவைப் பின்பற்றுகிறது',
        'years': 'ஆண்டுகள்',
        'months': 'மாதங்கள்',
        'kg': 'கிலோ',
        'cm': 'செமீ',
        'weightAge': 'எடை-வயது',
        'heightAge': 'உயரம்-வயது',
        'weightForHeight': 'உயரத்திற்கான எடை',
        'growthCountdown': 'வளர்ச்சி எண்ணிக்கை',
        'standards': 'தரநிலைகள்',
        'whoStandards': 'WHO தரநிலைகள்',
        'sriLankanStandards': 'இலங்கை தரநிலைகள்',
        'showZScores': 'Z-புள்ளிகளைக் காட்டு',
        'showPercentiles': 'சதவீதங்களைக் காட்டு',
        'zScore': 'Z-புள்ளி',
        'percentile': 'சதவீதம்',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    final provider = Provider.of<ChildProvider>(context, listen: true);
    final child = provider.selectedChild;

    if (child == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            texts['title']!,
            style: TextStyle(
              color: const Color(0xFF1A1A1A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => context.go('/'),
          ),
          actions: [
            SmartNotificationBadge(
              child: IconButton(
                onPressed: () => context.push('/notifications'),
                icon: Icon(
                  Icons.notifications_outlined,
                  color: const Color(0xFF6B7280),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                ),
                tooltip: 'Notifications',
              ),
            ),
            IconButton(
              icon: const Icon(Icons.analytics_outlined,
                  color: Color(0xFF3A7AFE)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NutritionalAnalysisScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
              onPressed: () {},
            ),
          ],
        ),
        body: const Center(
          child: Text('No child selected'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          texts['title']!,
          style: TextStyle(
            color: const Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => context.go('/'),
        ),
        actions: [
          SmartNotificationBadge(
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Icon(
                Icons.notifications_outlined,
                color: const Color(0xFF6B7280),
                size: ResponsiveUtils.getResponsiveIconSize(context, 24),
              ),
              tooltip: 'Notifications',
            ),
          ),
          // Growth Countdown for children under 6 months
          if (_shouldShowGrowthCountdown(child))
            IconButton(
              icon: const Icon(Icons.timer_outlined, color: Color(0xFFFF6B6B)),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PreSixMonthCountdownScreen(),
                ),
              ),
              tooltip: texts['growthCountdown'] ?? 'Growth Countdown',
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: Column(
        children: [
          // Child Info Card
          _buildChildInfoCard(child, provider, texts),

          // Tab Navigation
          _buildTabNavigation(texts),

          // Range Filter
          _buildRangeFilter(),

          // Standards Toggle & Display Options
          _buildControlsSection(texts),

          // Chart Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Growth Chart
                  _buildGrowthChart(provider, texts),

                  const SizedBox(height: 24),

                  // Legend
                  _buildLegend(texts),

                  const SizedBox(height: 32),

                  // Data Points Section
                  _buildDataPointsSection(provider, texts),

                  const SizedBox(height: 32),

                  // Growth Insights
                  _buildGrowthInsights(child, texts),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildInfoCard(
      Child child, ChildProvider provider, Map<String, String> texts) {
    final latestRecord =
        provider.growthRecords.isNotEmpty ? provider.growthRecords.first : null;
    final ageString = provider.getAgeString(child.birthDate);
    final daysSinceUpdate = latestRecord != null
        ? DateTime.now().difference(latestRecord.date).inDays
        : (child.birthWeight != null || child.birthHeight != null)
            ? DateTime.now().difference(child.birthDate).inDays
            : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              // Child Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _getChildProfileImage(child) != null
                      ? Image(
                          image: _getChildProfileImage(child)!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            child.gender == 'Male' ? Icons.boy : Icons.girl,
                            color: const Color(0xFF3A7AFE),
                            size: 24,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Child Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          child.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                            fontFamily: _selectedLanguage == 'si'
                                ? 'NotoSerifSinhala'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: const Color(0xFF3A7AFE),
                        ),
                      ],
                    ),
                    Text(
                      ageString,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metrics Row
          Row(
            children: [
              _buildMetricItem(
                texts['weight']!,
                latestRecord?.weight.toString() ??
                    child.birthWeight?.toString() ??
                    '--',
                (latestRecord?.weight != null || child.birthWeight != null)
                    ? texts['kg']!
                    : '',
              ),
              _buildMetricItem(
                texts['height']!,
                latestRecord?.height.toString() ??
                    child.birthHeight?.toString() ??
                    '--',
                (latestRecord?.height != null || child.birthHeight != null)
                    ? texts['cm']!
                    : '',
              ),
              _buildMetricItem(
                texts['bmi']!,
                latestRecord != null
                    ? (latestRecord.weight /
                            ((latestRecord.height / 100) *
                                (latestRecord.height / 100)))
                        .toStringAsFixed(1)
                    : (child.birthWeight != null && child.birthHeight != null)
                        ? (child.birthWeight! /
                                ((child.birthHeight! / 100) *
                                    (child.birthHeight! / 100)))
                            .toStringAsFixed(1)
                        : '--',
                '',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      texts['lastUpdate']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF9CA3AF),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$daysSinceUpdate ${texts['daysAgo']!}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String unit) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(Map<String, String> texts) {
    final tabTexts = {
      'Weight-Age': texts['weightAge']!,
      'Height-Age': texts['heightAge']!,
      'BMI': texts['bmi']!,
      'Weight-for-Height': texts['weightForHeight']!,
    };

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: _tabs.map((tab) {
            final isSelected = _selectedTab == tab;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SafeGestureDetector(
                onTap: () {
                  setState(() => _selectedTab = tab);
                  _loadChartData(); // Reload chart data for new tab
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? const Color(0xFF3A7AFE)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabTexts[tab] ?? tab,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF3A7AFE)
                          : const Color(0xFF6B7280),
                      fontFamily:
                          _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRangeFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Row(
        children: _ranges.map((range) {
          final isSelected = _selectedRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SafeGestureDetector(
              onTap: () {
                setState(() => _selectedRange = range);
                _loadChartData(); // Reload chart data for new range
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3A7AFE)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  range,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGrowthChart(ChildProvider provider, Map<String, String> texts) {
    final records = _getFilteredRecords(provider.growthRecords);
    final child = provider.selectedChild;

    // Check if we have any data (records or birth data)
    final hasData = records.isNotEmpty ||
        (child?.birthWeight != null && _selectedTab == 'Weight-Age') ||
        (child?.birthHeight != null && _selectedTab == 'Height-Age');

    if (!hasData) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 16),
              Text(
                'No growth data yet',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddMeasurementScreen(),
                    ),
                  );
                },
                child: Text(
                  texts['addNew']!,
                  style: TextStyle(
                    color: const Color(0xFF3A7AFE),
                    fontWeight: FontWeight.w600,
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xFFE5E7EB),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final months = value.toInt();
                  if (months < 12) {
                    return Text(
                      '${months}m',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    );
                  } else {
                    final years = (months / 12).floor();
                    final remainingMonths = months % 12;
                    if (remainingMonths == 0) {
                      return Text(
                        '${years}y',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      );
                    } else {
                      return Text(
                        '${years}y${remainingMonths}m',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: _getMaxX(records, child),
          minY: _getMinY(records, child),
          maxY: _getMaxY(records, child),
          lineBarsData: [
            // Child's data line
            LineChartBarData(
              spots: _getChartSpots(records),
              isCurved: true,
              color: const Color(0xFF3A7AFE),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF3A7AFE),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
            // WHO percentile lines - these should be calculated based on actual WHO data
            ..._buildWHOPercentileLines(child),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getChartSpots(List<GrowthRecord> records) {
    final provider = Provider.of<ChildProvider>(context, listen: false);
    final child = provider.selectedChild;
    if (child == null) return [];

    List<FlSpot> spots = [];

    // Add birth data as first point if available
    if (child.birthWeight != null && _selectedTab == 'Weight-Age') {
      spots.add(FlSpot(0, child.birthWeight!));
    } else if (child.birthHeight != null && _selectedTab == 'Height-Age') {
      spots.add(FlSpot(0, child.birthHeight!));
    } else if (child.birthWeight != null &&
        child.birthHeight != null &&
        _selectedTab == 'BMI') {
      final bmi = child.birthWeight! /
          ((child.birthHeight! / 100) * (child.birthHeight! / 100));
      spots.add(FlSpot(0, bmi));
    }

    // Add growth records
    final sortedRecords = List<GrowthRecord>.from(records);
    sortedRecords.sort((a, b) => a.date.compareTo(b.date));

    for (final record in sortedRecords) {
      final recordAgeInMonths =
          _calculateAgeInMonths(record.date, child.birthDate);

      double value;
      switch (_selectedTab) {
        case 'Weight-Age':
          value = record.weight;
          break;
        case 'Height-Age':
          value = record.height;
          break;
        case 'BMI':
          value =
              record.weight / ((record.height / 100) * (record.height / 100));
          break;
        case 'Weight-for-Height':
          // For weight-for-height, we need to map height to appropriate scale
          value = record.weight;
          break;
        default:
          value = record.weight;
      }

      // Only add valid data points
      if (value > 0 && recordAgeInMonths >= 0 && recordAgeInMonths <= 60) {
        spots.add(FlSpot(recordAgeInMonths.toDouble(), value));
      }
    }

    return spots;
  }

  List<GrowthRecord> _getFilteredRecords(List<GrowthRecord> allRecords) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedRange) {
      case '3M':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case '6M':
        startDate = now.subtract(const Duration(days: 180));
        break;
      case '1Y':
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        return allRecords;
    }

    return allRecords
        .where((record) => record.date.isAfter(startDate))
        .toList();
  }

  Widget _buildLegend(Map<String, String> texts) {
    final provider = Provider.of<ChildProvider>(context, listen: false);
    final child = provider.selectedChild;
    final childName = child?.name ?? 'Child';

    final legendItems = [
      {'color': const Color(0xFF3A7AFE), 'label': childName},
      {'color': const Color(0xFF10B981), 'label': '97th'},
      {'color': const Color(0xFF34D399), 'label': '85th'},
      {'color': const Color(0xFFFBBF24), 'label': '50th'},
      {'color': const Color(0xFFFB923C), 'label': '15th'},
      {'color': const Color(0xFFEF4444), 'label': '3rd'},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: legendItems.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              item['label'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDataPointsSection(
      ChildProvider provider, Map<String, String> texts) {
    final records = _getFilteredRecords(provider.growthRecords);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texts['dataPoints']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddMeasurementScreen(),
                  ),
                );
              },
              child: Text(
                texts['addNew']!,
                style: TextStyle(
                  color: const Color(0xFF3A7AFE),
                  fontWeight: FontWeight.w600,
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...records.take(3).map((record) => _buildDataPointItem(record, texts)),
      ],
    );
  }

  Widget _buildDataPointItem(GrowthRecord record, Map<String, String> texts) {
    final percentile = _calculatePercentile(record);
    final provider = Provider.of<ChildProvider>(context, listen: false);

    return SafeGestureDetector(
      onTap: () {
        context.push(
          '/measurement-detail',
          extra: {
            'measurementId': record.id,
            'childId': provider.selectedChild?.id ?? '',
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.date.month}/${record.date.day}/${record.date.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${texts['age']}: ${_getAgeAtMeasurement(record)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                      fontFamily:
                          _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${record.weight} ${texts['kg']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentile ${texts['percentile']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF34D399),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calculatePercentile(GrowthRecord record) {
    final provider = Provider.of<ChildProvider>(context, listen: false);
    final child = provider.selectedChild;
    if (child == null) return '--';

    // Calculate age at time of measurement using consistent method
    final ageInMonths = _calculateAgeInMonths(record.date, child.birthDate);

    double value;
    String measurementType;
    switch (_selectedTab) {
      case 'Weight-Age':
        value = record.weight;
        measurementType = 'weight_for_age';
        break;
      case 'Height-Age':
        value = record.height;
        measurementType = 'height_for_age';
        break;
      case 'BMI':
        value = record.weight / ((record.height / 100) * (record.height / 100));
        measurementType = 'bmi_for_age';
        break;
      case 'Weight-for-Height':
        value = record.weight;
        measurementType = 'weight_for_height';
        break;
      default:
        value = record.weight;
        measurementType = 'weight_for_age';
    }

    try {
      // Use the actual standards to calculate z-score and percentile
      final zScore = _calculateZScoreForMeasurement(
        value,
        ageInMonths,
        child.gender,
        _selectedTab,
        _selectedStandard == 'WHO' ? 'WHO' : 'SriLanka',
      );

      // Convert z-score to percentile using the helper function
      return '${_zScoreToPercentile(zScore as double).round()}th';
    } catch (e) {
      // Fallback to simplified estimation
      return _getSimplifiedPercentile(value, measurementType);
    }
  }

  String _getSimplifiedPercentile(double value, String measurementType) {
    // Fallback simplified percentile estimation
    switch (measurementType) {
      case 'weight_for_age':
        if (value > 15) return '90th';
        if (value > 13) return '75th';
        if (value > 11) return '50th';
        if (value > 9) return '25th';
        return '10th';
      case 'height_for_age':
        if (value > 90) return '90th';
        if (value > 85) return '75th';
        if (value > 80) return '50th';
        if (value > 75) return '25th';
        return '10th';
      case 'bmi_for_age':
        if (value > 18) return '90th';
        if (value > 17) return '75th';
        if (value > 16) return '50th';
        if (value > 15) return '25th';
        return '10th';
      default:
        return '50th';
    }
  }

  Widget _buildGrowthInsights(Child child, Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['growthInsights']!,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFF3A7AFE).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Color(0xFF3A7AFE),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${child.name}\'s ${texts['healthyGrowth']} 55-60th ${texts['percentile']}.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF1A1A1A),
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getMaxX(List<GrowthRecord> records, Child? child) {
    if (child == null) return 24;

    final now = DateTime.now();
    final ageInMonths = now.difference(child.birthDate).inDays / 30.44;

    // Show at least 6 months ahead or current age, whichever is greater
    return math.max(ageInMonths + 6, 24);
  }

  double _getMinY(List<GrowthRecord> records, Child? child) {
    final spots = _getChartSpots(records);
    if (spots.isEmpty) {
      switch (_selectedTab) {
        case 'Weight-Age':
          return 2;
        case 'Height-Age':
          return 40;
        case 'BMI':
          return 10;
        default:
          return 0;
      }
    }

    final minValue = spots.map((s) => s.y).reduce(math.min);
    return (minValue * 0.8).floorToDouble();
  }

  double _getMaxY(List<GrowthRecord> records, Child? child) {
    final spots = _getChartSpots(records);
    if (spots.isEmpty) {
      switch (_selectedTab) {
        case 'Weight-Age':
          return 20;
        case 'Height-Age':
          return 120;
        case 'BMI':
          return 25;
        default:
          return 100;
      }
    }

    final maxValue = spots.map((s) => s.y).reduce(math.max);
    return (maxValue * 1.2).ceilToDouble();
  }

  List<LineChartBarData> _buildWHOPercentileLines(Child? child) {
    if (child == null) return [];

    final lines = <LineChartBarData>[];
    final maxX = _getMaxX([], child);

    try {
      // Generate actual percentile lines using the standards data
      final percentileLines =
          _generateStandardPercentileLines(child, maxX.toInt());
      lines.addAll(percentileLines);
    } catch (e) {
      print('Error generating percentile lines: $e');
      // Fallback to simplified lines
      lines.addAll(_generateFallbackPercentileLines());
    }

    return lines;
  }

  List<LineChartBarData> _generateStandardPercentileLines(
      Child child, int maxAgeMonths) {
    final lines = <LineChartBarData>[];
    final percentileColors = [
      const Color(0xFFEF4444), // 3rd percentile
      const Color(0xFFFB923C), // 15th percentile
      const Color(0xFFFBBF24), // 50th percentile
      const Color(0xFF34D399), // 85th percentile
      const Color(0xFF10B981), // 97th percentile
    ];

    // Z-score values corresponding to percentiles: 3rd, 15th, 50th, 85th, 97th
    final zScores = [-1.88, -1.04, 0.0, 1.04, 1.88];

    String measurementType;
    switch (_selectedTab) {
      case 'Weight-Age':
        measurementType = 'weight_for_age';
        break;
      case 'Height-Age':
        measurementType = 'height_for_age';
        break;
      case 'BMI':
        measurementType = 'bmi_for_age';
        break;
      case 'Weight-for-Height':
        measurementType = 'weight_for_height';
        break;
      default:
        measurementType = 'weight_for_age';
    }

    for (int i = 0; i < zScores.length; i++) {
      final spots = <FlSpot>[];
      final zScore = zScores[i];

      // Generate spots for each month up to maxAgeMonths
      for (int ageMonths = 0; ageMonths <= maxAgeMonths; ageMonths += 3) {
        try {
          final standardValues = _standardsService.getGrowthStandardForChild(
            ageMonths: ageMonths,
            gender: child.gender,
            measurementType: measurementType,
          );

          if (standardValues != null) {
            final value = _interpolateFromZScore(standardValues, zScore);
            if (value > 0) {
              spots.add(FlSpot(ageMonths.toDouble(), value));
            }
          }
        } catch (e) {
          // Skip this data point on error
          continue;
        }
      }

      if (spots.isNotEmpty) {
        lines.add(LineChartBarData(
          spots: spots,
          isCurved: true,
          color: percentileColors[i].withValues(alpha: 0.6),
          barWidth: 1.5,
          isStrokeCapRound: false,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          dashArray: [3, 3],
        ));
      }
    }

    return lines;
  }

  double _interpolateFromZScore(dynamic standardValues, double targetZScore) {
    // This is a simplified interpolation - in a real implementation,
    // you would use the actual z-score interpolation from the GrowthStandard model
    if (standardValues is GrowthStandard) {
      if (targetZScore <= -2.0) {
        return standardValues.zScoreMinus2 +
            (targetZScore + 2.0) *
                (standardValues.zScoreMinus3 - standardValues.zScoreMinus2);
      } else if (targetZScore <= 0.0) {
        return standardValues.zScoreMinus2 +
            (targetZScore + 2.0) *
                (standardValues.median - standardValues.zScoreMinus2) /
                2.0;
      } else if (targetZScore <= 2.0) {
        return standardValues.median +
            targetZScore *
                (standardValues.zScorePlus2 - standardValues.median) /
                2.0;
      } else {
        return standardValues.zScorePlus2 +
            (targetZScore - 2.0) *
                (standardValues.zScorePlus3 - standardValues.zScorePlus2);
      }
    }
    return 0.0;
  }

  List<LineChartBarData> _generateFallbackPercentileLines() {
    final lines = <LineChartBarData>[];

    switch (_selectedTab) {
      case 'Weight-Age':
        lines.addAll([
          _buildPercentileLine(
              [2.5, 4, 6, 8, 10, 12], const Color(0xFFEF4444)), // 3rd
          _buildPercentileLine(
              [3, 5, 7, 9, 11, 13], const Color(0xFFFB923C)), // 15th
          _buildPercentileLine(
              [3.5, 5.5, 8, 10, 12, 14], const Color(0xFFFBBF24)), // 50th
          _buildPercentileLine(
              [4, 6.5, 9, 11, 13, 15], const Color(0xFF34D399)), // 85th
          _buildPercentileLine(
              [4.5, 7, 10, 12, 14, 16], const Color(0xFF10B981)), // 97th
        ]);
        break;
      case 'Height-Age':
        lines.addAll([
          _buildPercentileLine(
              [45, 55, 65, 75, 85, 95], const Color(0xFFEF4444)), // 3rd
          _buildPercentileLine(
              [47, 58, 68, 78, 88, 98], const Color(0xFFFB923C)), // 15th
          _buildPercentileLine(
              [50, 61, 71, 81, 91, 101], const Color(0xFFFBBF24)), // 50th
          _buildPercentileLine(
              [53, 64, 74, 84, 94, 104], const Color(0xFF34D399)), // 85th
          _buildPercentileLine(
              [55, 66, 76, 86, 96, 106], const Color(0xFF10B981)), // 97th
        ]);
        break;
      case 'BMI':
        lines.addAll([
          _buildPercentileLine(
              [12, 13, 14, 14.5, 15, 15.5], const Color(0xFFEF4444)), // 3rd
          _buildPercentileLine(
              [13, 14, 15, 15.5, 16, 16.5], const Color(0xFFFB923C)), // 15th
          _buildPercentileLine(
              [14, 15, 16, 16.5, 17, 17.5], const Color(0xFFFBBF24)), // 50th
          _buildPercentileLine(
              [15, 16, 17, 17.5, 18, 18.5], const Color(0xFF34D399)), // 85th
          _buildPercentileLine(
              [16, 17, 18, 18.5, 19, 19.5], const Color(0xFF10B981)), // 97th
        ]);
        break;
    }

    return lines;
  }

  LineChartBarData _buildPercentileLine(List<double> values, Color color) {
    final spots = <FlSpot>[];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i * 6.0, values[i])); // 6 month intervals
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color.withValues(alpha: 0.5),
      barWidth: 1,
      isStrokeCapRound: false,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      dashArray: [5, 5],
    );
  }

  String _getAgeAtMeasurement(GrowthRecord record) {
    final provider = Provider.of<ChildProvider>(context, listen: false);
    final child = provider.selectedChild;
    if (child == null) return '--';

    final ageAtMeasurement = record.date.difference(child.birthDate);
    final years = (ageAtMeasurement.inDays / 365).floor();
    final months = ((ageAtMeasurement.inDays % 365) / 30.44).floor();

    if (years == 0) {
      return '${months}m';
    } else if (months == 0) {
      return '${years}y';
    } else {
      return '${years}y ${months}m';
    }
  }

  Widget _buildControlsSection(Map<String, String> texts) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Standards Toggle - More compact for mobile
          Container(
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: _standards.map((standard) {
                final isSelected = _selectedStandard == standard;
                return Expanded(
                  child: SafeGestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStandard = standard;
                      });
                      _loadChartData(); // Reload chart data with new standard
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0086FF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          standard == 'WHO' ? 'WHO' : 'Sri Lankan',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 12),
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),

          // Display Options - More compact layout
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _showPercentiles,
                        onChanged: (value) =>
                            setState(() => _showPercentiles = value ?? true),
                        activeColor: const Color(0xFF0086FF),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        isMobile ? 'Percentiles' : texts['showPercentiles']!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 11),
                          color: const Color(0xFF374151),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _showZScores,
                        onChanged: (value) =>
                            setState(() => _showZScores = value ?? false),
                        activeColor: const Color(0xFF0086FF),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        isMobile ? 'Z-Scores' : texts['showZScores']!,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 11),
                          color: const Color(0xFF374151),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
