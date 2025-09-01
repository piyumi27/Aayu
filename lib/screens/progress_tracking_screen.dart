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
  String _selectedPeriod = 'week'; // week, month, 3months, 6months

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
                                context, 24)),

                        // Quick Actions
                        _buildQuickActions(context, texts),

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

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0086FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: const Color(0xFF0086FF),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                ),
              ),
              SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Growth Progress Overview',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Tracking ${child.name}\'s development journey',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$daysSinceBirth days completed',
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    '$progressPercentage%',
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0086FF),
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF0086FF)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Text(
                daysRemaining > 0
                    ? '$daysRemaining days remaining to 6-month milestone'
                    : 'Milestone achieved!',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthMetricsGrid(
      Child child, int daysSinceBirth, Map<String, String> texts) {
    return GridView.count(
      crossAxisCount: ResponsiveUtils.isSmallWidth(context) ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
      mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
      childAspectRatio: ResponsiveUtils.isSmallWidth(context) ? 1.2 : 1.1,
      children: [
        _buildMetricCard(
          'Weight Progress',
          '${child.birthWeight?.toStringAsFixed(1) ?? 'N/A'} kg',
          Icons.monitor_weight_outlined,
          const Color(0xFF10B981),
          'Last: 3 days ago',
        ),
        _buildMetricCard(
          'Height Progress',
          '${child.birthHeight?.toStringAsFixed(0) ?? 'N/A'} cm',
          Icons.height_rounded,
          const Color(0xFF0086FF),
          'Last: 3 days ago',
        ),
        _buildMetricCard(
          'Days Active',
          '$daysSinceBirth',
          Icons.calendar_today_outlined,
          const Color(0xFFF59E0B),
          'Since birth',
        ),
        _buildMetricCard(
          'Milestones',
          '4 / 6',
          Icons.emoji_events_outlined,
          const Color(0xFFEF4444),
          'Completed',
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context, 16),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 6)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 9),
                color: const Color(0xFF6B7280).withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesProgressCard(
      List<MilestoneData> milestones, Map<String, String> texts) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flag_outlined,
                  color: const Color(0xFF10B981),
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                ),
              ),
              SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Development Milestones',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Key developmental achievements',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

          // Milestones List
          ...milestones
              .take(4)
              .map((milestone) => _buildMilestoneRow(milestone))
              .toList(),

          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),

          // View All Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to detailed milestones view
              },
              style: OutlinedButton.styleFrom(
                side:
                    BorderSide(color: const Color(0xFF0086FF).withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View All Milestones',
                style: TextStyle(
                  color: const Color(0xFF0086FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(MilestoneData milestone) {
    final isCompleted = milestone.currentDay >= milestone.targetDay;
    final isInProgress =
        milestone.currentDay >= milestone.targetDay - 15 && !isCompleted;
    final progress =
        (milestone.currentDay / milestone.targetDay).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : isInProgress
                      ? const Color(0xFFF59E0B).withOpacity(0.1)
                      : const Color(0xFF6B7280).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_outline
                  : isInProgress
                      ? Icons.hourglass_empty_rounded
                      : Icons.radio_button_unchecked,
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : isInProgress
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF6B7280),
              size: 20,
            ),
          ),

          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),

          // Milestone Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  'Target: Day ${milestone.targetDay}',
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Progress Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : isInProgress
                      ? const Color(0xFFF59E0B).withOpacity(0.1)
                      : const Color(0xFF6B7280).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCompleted
                  ? 'Done'
                  : isInProgress
                      ? '${(progress * 100).toInt()}%'
                      : 'Pending',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : isInProgress
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Map<String, String> texts) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Add Measurement',
                  Icons.straighten_rounded,
                  const Color(0xFF0086FF),
                  () {
                    // Navigate to add measurement
                  },
                ),
              ),
              SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
              Expanded(
                child: _buildActionButton(
                  'View Charts',
                  Icons.analytics_outlined,
                  const Color(0xFF10B981),
                  () {
                    // Navigate to detailed charts
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context, 24),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
