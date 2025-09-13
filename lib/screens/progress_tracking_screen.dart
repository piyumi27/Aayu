import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../providers/child_provider.dart';
import '../utils/responsive_utils.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('selected_language') ?? 'en';
      });
    }
  }

  int _calculateDaysSinceBirth(Child child) {
    final now = DateTime.now();
    final difference = now.difference(child.birthDate);
    return difference.inDays;
  }

  double _calculateProgress(int daysSinceBirth) {
    return math.min(daysSinceBirth / 180.0, 1.0);
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Growth Progress',
        'subtitle': 'Track your child\'s development journey',
        'overview': 'Overview',
        'weeklyProgress': 'Weekly Progress',
        'monthlyProgress': 'Monthly Progress',
        'milestones': 'Milestones',
        'achievements': 'Recent Achievements',
        'nextGoal': 'Next Goal',
        'daysCompleted': 'Days Completed',
        'averageGrowth': 'Average Growth',
        'consistency': 'Consistency Score',
        'week': 'Week',
        'month': 'Month',
        '3months': '3 Months',
        '6months': '6 Months',
        'excellent': 'Excellent',
        'good': 'Good',
        'needsImprovement': 'Needs Improvement',
        'onTrack': 'On Track',
        'ahead': 'Ahead of Schedule',
        'behind': 'Needs Attention',
        'milestone1': 'First Smile',
        'milestone2': 'Rolling Over',
        'milestone3': 'Sitting Up',
        'milestone4': 'Crawling',
        'milestone5': 'First Steps',
        'milestone6': '6 Month Goal',
        'completed': 'Completed',
        'inProgress': 'In Progress',
        'upcoming': 'Upcoming',
        'daysPassed': 'days passed',
        'target': 'Target',
        'actual': 'Actual',
        'projectedCompletion': 'Projected Completion',
      },
      'si': {
        'title': 'වර්ධන ප්‍රගතිය',
        'subtitle': 'ඔබේ දරුවාගේ වර්ධන ගමන් මග නිරීක්ෂණය කරන්න',
        'overview': 'සමස්ත දැක්ම',
        'weeklyProgress': 'සතිපතා ප්‍රගතිය',
        'monthlyProgress': 'මාසික ප්‍රගතිය',
        'milestones': 'සන්ධිස්ථාන',
        'achievements': 'මෑත කාලීන ජයග්‍රහණ',
        'nextGoal': 'ඊළඟ ඉලක්කය',
        'daysCompleted': 'සම්පූර්ණ වූ දින',
        'averageGrowth': 'සාමාන්‍ය වර්ධනය',
        'consistency': 'ස්ථාවරත්ව ලකුණු',
        'excellent': 'විශිෂ්ට',
        'good': 'හොඳයි',
        'needsImprovement': 'වැඩිදියුණු කිරීම අවශ්‍යයි',
        'onTrack': 'නිවැරදි මාර්ගයේ',
        'ahead': 'කාලසටහනට වඩා ඉදිරියෙන්',
        'behind': 'අවධානය අවශ්‍යයි',
        'completed': 'සම්පූර්ණයි',
        'inProgress': 'ක්‍රියාත්මකයි',
        'upcoming': 'ඉදිරියේ',
        'daysPassed': 'දින ගතවී ඇත',
      },
      'ta': {
        'title': 'வளர்ச்சி முன்னேற்றம்',
        'subtitle': 'உங்கள் குழந்தையின் வளர்ச்சி பயணத்தைக் கண்காணிக்கவும்',
        'overview': 'முழுமையான பார்வை',
        'weeklyProgress': 'வாராந்திர முன்னேற்றம்',
        'monthlyProgress': 'மாதாந்திர முன்னேற்றம்',
        'milestones': 'மைல்கற்கள்',
        'achievements': 'சமீபத்திய சாதனைகள்',
        'nextGoal': 'அடுத்த இலக்கு',
        'daysCompleted': 'நிறைவு செய்யப்பட்ட நாட்கள்',
        'averageGrowth': 'சராசரி வளர்ச்சி',
        'consistency': 'நிலையான மதிப்பெண்',
        'excellent': 'சிறந்தது',
        'good': 'நல்லது',
        'needsImprovement': 'முன்னேற்றம் தேவை',
        'onTrack': 'சரியான பாதையில்',
        'ahead': 'அட்டவணையை விட முன்னதாக',
        'behind': 'கவனம் தேவை',
        'completed': 'நிறைவு',
        'inProgress': 'முன்னேற்றத்தில்',
        'upcoming': 'வரவிருக்கும்',
        'daysPassed': 'நாட்கள் கடந்துவிட்டன',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }

  List<MilestoneData> _getMilestones(
      int daysSinceBirth, Map<String, String> texts) {
    return [
      MilestoneData(
        title: texts['milestone1'] ?? 'First Smile',
        targetDay: 30,
        currentDay: daysSinceBirth,
        icon: Icons.sentiment_very_satisfied_outlined,
        color: const Color(0xFF10B981),
      ),
      MilestoneData(
        title: texts['milestone2'] ?? 'Rolling Over',
        targetDay: 60,
        currentDay: daysSinceBirth,
        icon: Icons.rotate_right_outlined,
        color: const Color(0xFF0086FF),
      ),
      MilestoneData(
        title: texts['milestone3'] ?? 'Sitting Up',
        targetDay: 90,
        currentDay: daysSinceBirth,
        icon: Icons.event_seat_outlined,
        color: const Color(0xFF8B5CF6),
      ),
      MilestoneData(
        title: texts['milestone4'] ?? 'Crawling',
        targetDay: 120,
        currentDay: daysSinceBirth,
        icon: Icons.directions_run,
        color: const Color(0xFFF59E0B),
      ),
      MilestoneData(
        title: texts['milestone5'] ?? 'First Steps',
        targetDay: 150,
        currentDay: daysSinceBirth,
        icon: Icons.directions_walk,
        color: const Color(0xFFEF4444),
      ),
      MilestoneData(
        title: texts['milestone6'] ?? '6 Month Goal',
        targetDay: 180,
        currentDay: daysSinceBirth,
        icon: Icons.emoji_events_outlined,
        color: const Color(0xFFEC4899),
      ),
    ];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();

    return Consumer<ChildProvider>(
      builder: (context, childProvider, child) {
        final selectedChild = childProvider.selectedChild;

        if (selectedChild == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final daysSinceBirth = _calculateDaysSinceBirth(selectedChild);
        final progress = _calculateProgress(daysSinceBirth);
        final milestones = _getMilestones(daysSinceBirth, texts);

        return Scaffold(
          backgroundColor: const Color(0xFFFAFBFC),
          appBar: _buildIndustrialAppBar(context, texts),
          body: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Overview Card
                        _buildProgressOverviewCard(
                            selectedChild, daysSinceBirth, progress, texts),

                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context, 24)),

                        // Growth Metrics Grid
                        _buildGrowthMetricsGrid(
                            selectedChild, daysSinceBirth, texts),

                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context, 24)),

                        // Milestones Progress
                        _buildMilestonesProgressCard(milestones, texts),

                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context, 32)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildIndustrialAppBar(
      BuildContext context, Map<String, String> texts) {
    return AppBar(
      title: Text(
        texts['title'] ?? 'Growth Progress',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111827),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF111827),
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () {
            _showOptionsMenu(context);
          },
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Progress'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Detailed Analytics'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverviewCard(Child child, int daysSinceBirth,
      double progress, Map<String, String> texts) {
    final progressPercentage = (progress * 100).toInt();
    final daysRemaining = math.max(0, 180 - daysSinceBirth);
    final ageInMonths = (daysSinceBirth / 30.44).round();
    final weeksSinceBirth = (daysSinceBirth / 7).round();

    // Calculate growth velocity and health score
    final growthVelocity = _calculateGrowthVelocity(child);
    final healthScore = _calculateHealthScore(child, daysSinceBirth);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0086FF).withValues(alpha: 0.05),
            const Color(0xFF10B981).withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0086FF).withValues(alpha: 0.03),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF0086FF),
                            const Color(0xFF0073E6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${child.name}\'s Growth Journey',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$ageInMonths months • $weeksSinceBirth weeks old',
                            style: TextStyle(
                              fontSize: 15,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Advanced Progress Visualization
                Row(
                  children: [
                    // Circular Progress
                    Expanded(
                      flex: 2,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: progress,
                              backgroundColor: const Color(0xFFF3F4F6),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF0086FF),
                              ),
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$progressPercentage%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0086FF),
                                ),
                              ),
                              Text(
                                'Complete',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF6B7280),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Progress Details
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProgressStat(
                            'Days Completed',
                            '$daysSinceBirth',
                            Icons.calendar_today_rounded,
                            const Color(0xFF0086FF),
                          ),
                          const SizedBox(height: 16),
                          _buildProgressStat(
                            'Growth Velocity',
                            growthVelocity,
                            Icons.speed_rounded,
                            const Color(0xFF10B981),
                          ),
                          const SizedBox(height: 16),
                          _buildProgressStat(
                            'Health Score',
                            '$healthScore/100',
                            Icons.favorite_rounded,
                            const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Smart Insights Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: const Color(0xFFFBBF24),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getSmartInsight(
                              child, daysSinceBirth, daysRemaining),
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF92400E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateGrowthVelocity(Child child) {
    // Mock calculation - in real app, this would analyze historical data
    final random = math.Random(child.name.hashCode);
    final velocity = 85 + random.nextInt(15);
    return '$velocity%';
  }

  int _calculateHealthScore(Child child, int daysSinceBirth) {
    // Mock calculation - in real app, this would analyze various health metrics
    final baseScore = 75;
    final ageBonus = math.min(20, daysSinceBirth ~/ 10);
    final random = math.Random(child.name.hashCode);
    return math.min(100, baseScore + ageBonus + random.nextInt(10));
  }

  String _getSmartInsight(Child child, int daysSinceBirth, int daysRemaining) {
    if (daysRemaining <= 0) {
      return "Excellent! ${child.name} has reached the 6-month milestone. Consider scheduling advanced developmental assessments.";
    } else if (daysRemaining <= 30) {
      return "Approaching 6-month milestone! Prepare for solid foods introduction and enhanced motor skills development.";
    } else if (daysSinceBirth >= 90) {
      return "Great progress! Focus on tummy time and social interactions to support optimal development.";
    } else {
      return "Early development phase. Maintain consistent feeding schedules and ensure adequate sleep for healthy growth.";
    }
  }

  Widget _buildGrowthMetricsGrid(
      Child child, int daysSinceBirth, Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Expanded(
              child: Text(
                'Growth Analytics Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 14,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'On Track',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Primary Metrics Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildAdvancedMetricCard(
                'Weight Progression',
                child.birthWeight?.toStringAsFixed(1) ?? 'N/A',
                'kg',
                Icons.monitor_weight_outlined,
                const Color(0xFF10B981),
                _generateWeightTrend(),
                '+2.3kg from birth',
                'Healthy growth rate',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildAdvancedMetricCard(
                'Height Development',
                child.birthHeight?.toStringAsFixed(0) ?? 'N/A',
                'cm',
                Icons.height_rounded,
                const Color(0xFF0086FF),
                _generateHeightTrend(),
                '+18cm from birth',
                '95th percentile',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Secondary Metrics Grid
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildCompactMetricCard(
              'BMI Status',
              '18.2',
              Icons.favorite_rounded,
              const Color(0xFFEF4444),
              'Normal range',
              0.85, // Progress indicator
            ),
            _buildCompactMetricCard(
              'Sleep Quality',
              '87%',
              Icons.nightlight_round,
              const Color(0xFF8B5CF6),
              'Excellent',
              0.87,
            ),
            _buildCompactMetricCard(
              'Activity Level',
              '92%',
              Icons.directions_walk_rounded,
              const Color(0xFF06B6D4),
              'Very Active',
              0.92,
            ),
            _buildCompactMetricCard(
              'Nutrition',
              '78%',
              Icons.restaurant_rounded,
              const Color(0xFF10B981),
              'Good intake',
              0.78,
            ),
            _buildCompactMetricCard(
              'Milestones',
              '5/6',
              Icons.emoji_events_outlined,
              const Color(0xFFF59E0B),
              'On schedule',
              0.83,
            ),
            _buildCompactMetricCard(
              'Checkups',
              '100%',
              Icons.medical_services_rounded,
              const Color(0xFF0086FF),
              'Up to date',
              1.0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedMetricCard(
      String title,
      String value,
      String unit,
      IconData icon,
      Color color,
      List<double> trendData,
      String changeText,
      String statusText) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Value and unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Mini trend chart
          SizedBox(
            height: 40,
            child: _buildMiniChart(trendData, color),
          ),

          const SizedBox(height: 16),

          // Change and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      changeText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.trending_up_rounded,
                color: color,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetricCard(String title, String value, IconData icon,
      Color color, String subtitle, double progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFF3F4F6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 2,
            borderRadius: BorderRadius.circular(1),
          ),
          const SizedBox(height: 3),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 8,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChart(List<double> data, Color color) {
    return CustomPaint(
      size: Size.infinite,
      painter: MiniChartPainter(data, color),
    );
  }

  List<double> _generateWeightTrend() {
    // Mock trend data - in real app, this would come from actual measurements
    return [2.8, 3.2, 3.8, 4.3, 4.9, 5.4, 5.9, 6.2];
  }

  List<double> _generateHeightTrend() {
    // Mock trend data - in real app, this would come from actual measurements
    return [48, 52, 57, 62, 66, 69, 72, 74];
  }

  Widget _buildMilestonesProgressCard(
      List<MilestoneData> milestones, Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Development Timeline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '5/6 Complete',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Timeline Container
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B5CF6).withValues(alpha: 0.03),
                const Color(0xFF06B6D4).withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Visual Timeline
                _buildVisualTimeline(milestones),

                const SizedBox(height: 24),

                // Milestone Cards Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: math.min(milestones.length, 6),
                  itemBuilder: (context, index) {
                    return _buildModernMilestoneCard(milestones[index]);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualTimeline(List<MilestoneData> milestones) {
    return SizedBox(
      height: 80,
      child: Row(
        children: List.generate(milestones.length, (index) {
          final milestone = milestones[index];
          final isCompleted = milestone.currentDay >= milestone.targetDay;
          final isActive = index <= 4; // Mock: first 5 are active/completed

          return Expanded(
            child: Row(
              children: [
                // Timeline Node
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : isActive
                            ? const Color(0xFF0086FF)
                            : const Color(0xFFE5E7EB),
                    boxShadow: isCompleted || isActive
                        ? [
                            BoxShadow(
                              color: (isCompleted
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF0086FF))
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : milestone.icon,
                    color: isCompleted || isActive
                        ? Colors.white
                        : const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),

                // Connection Line
                if (index < milestones.length - 1)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF0086FF).withValues(alpha: 0.3)
                            : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildModernMilestoneCard(MilestoneData milestone) {
    final isCompleted = milestone.currentDay >= milestone.targetDay;
    final progress = math.min(1.0, milestone.currentDay / milestone.targetDay);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF10B981).withValues(alpha: 0.2)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: milestone.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    milestone.icon,
                    color: milestone.color,
                    size: 16,
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            // Title
            Flexible(
              child: Text(
                milestone.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // Progress
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? const Color(0xFF10B981) : milestone.color,
              ),
              minHeight: 2,
              borderRadius: BorderRadius.circular(1),
            ),

            const SizedBox(height: 2),

            Text(
              isCompleted
                  ? 'Completed'
                  : 'Day ${milestone.currentDay}/${milestone.targetDay}',
              style: TextStyle(
                fontSize: 8,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  // MOCK DATA METHODS FOR COMPREHENSIVE TESTING
  Map<String, String> _getMockNutritionData(Child child) {
    final random = math.Random(child.name.hashCode);
    return {
      'dailyCalories': '${850 + random.nextInt(200)}',
      'proteinIntake': '${15 + random.nextInt(10)}g',
      'calciumLevel': '${700 + random.nextInt(300)}mg',
      'ironLevel': '${8 + random.nextInt(4)}mg',
      'vitaminD': '${400 + random.nextInt(200)}IU',
    };
  }

  Map<String, double> _getMockSleepData(Child child) {
    final random = math.Random(child.name.hashCode + 1);
    return {
      'nightSleep': 10.5 + random.nextDouble() * 2,
      'daytimeNaps': 1.5 + random.nextDouble(),
      'sleepEfficiency': 0.80 + random.nextDouble() * 0.15,
      'bedtimeConsistency': 0.75 + random.nextDouble() * 0.2,
    };
  }

  Map<String, int> _getMockActivityData(Child child) {
    final random = math.Random(child.name.hashCode + 2);
    return {
      'tummyTimeMinutes': 45 + random.nextInt(30),
      'playTimeHours': 3 + random.nextInt(2),
      'motorSkillActivities': 5 + random.nextInt(5),
      'socialInteractionMinutes': 120 + random.nextInt(60),
    };
  }

  List<Map<String, dynamic>> _getMockGrowthHistory(Child child) {
    final history = <Map<String, dynamic>>[];
    final baseWeight = child.birthWeight ?? 3.2;
    final baseHeight = child.birthHeight ?? 50;

    for (int week = 0; week < 24; week += 2) {
      history.add({
        'week': week,
        'weight': baseWeight + (week * 0.15) + math.Random().nextDouble() * 0.3,
        'height': baseHeight + (week * 0.8) + math.Random().nextDouble() * 1.5,
        'headCircumference': 34 + (week * 0.3),
      });
    }
    return history;
  }
}

class MilestoneData {
  final String title;
  final int targetDay;
  final int currentDay;
  final IconData icon;
  final Color color;

  MilestoneData({
    required this.title,
    required this.targetDay,
    required this.currentDay,
    required this.icon,
    required this.color,
  });
}

class EnhancedCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  EnhancedCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Gradient progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        colors: [
          const Color(0xFF10B981),
          const Color(0xFF0086FF),
          const Color(0xFF8B5CF6),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(EnhancedCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class MiniChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  MiniChartPainter(this.data, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final gradientPath = Path();

    // Normalize data
    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = maxValue - minValue;

    if (range == 0) return;

    final stepX = size.width / (data.length - 1);

    // Create line path
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        gradientPath.moveTo(x, size.height);
        gradientPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        gradientPath.lineTo(x, y);
      }
    }

    // Complete gradient path
    gradientPath.lineTo(size.width, size.height);
    gradientPath.close();

    // Draw gradient fill
    canvas.drawPath(gradientPath, gradientPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      canvas.drawCircle(Offset(x, y), 2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(MiniChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
