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
  
  late AnimationController _mainController;
  late AnimationController _chartController;
  late AnimationController _statsController;
  late AnimationController _milestoneController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _statsAnimation;
  late Animation<Offset> _milestoneSlideAnimation;
  
  String _selectedLanguage = 'en';
  String _selectedPeriod = 'week'; // week, month, 3months, 6months
  
  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Main fade and slide animation
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Chart animation controller
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Stats animation controller
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Milestone animation controller
    _milestoneController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.elasticOut,
    ));

    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: Curves.bounceOut,
    ));

    _milestoneSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _milestoneController,
      curve: Curves.easeOutBack,
    ));

    // Start animations in sequence
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _chartController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _statsController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _milestoneController.forward();
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

  List<MilestoneData> _getMilestones(int daysSinceBirth, Map<String, String> texts) {
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
    _mainController.dispose();
    _chartController.dispose();
    _statsController.dispose();
    _milestoneController.dispose();
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
          backgroundColor: const Color(0xFFF8F9FA),
          body: CustomScrollView(
            slivers: [
              // Animated App Bar
              _buildAnimatedAppBar(texts),
              
              // Main Content
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: ResponsiveUtils.getResponsivePadding(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hero Stats Cards
                              _buildHeroStats(selectedChild, daysSinceBirth, progress, texts),
                              
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                              
                              // Period Selector
                              _buildPeriodSelector(texts),
                              
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                              
                              // Progress Chart
                              _buildProgressChart(daysSinceBirth, progress, texts),
                              
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
                              
                              // Milestones Section
                              _buildMilestonesSection(milestones, texts),
                              
                              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 100)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedAppBar(Map<String, String> texts) {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getResponsiveSpacing(context, 120),
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0086FF).withOpacity(0.9),
              const Color(0xFF10B981).withOpacity(0.8),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Text(
                  texts['title'] ?? 'Growth Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              );
            },
          ),
          titlePadding: ResponsiveUtils.getResponsivePadding(context),
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0086FF).withOpacity(0.9),
                  const Color(0xFF10B981).withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildHeroStats(Child child, int daysSinceBirth, double progress, Map<String, String> texts) {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, _) {
        return Transform.scale(
          scale: _statsAnimation.value,
          child: Container(
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.white.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Main Progress Circle
                SizedBox(
                  width: ResponsiveUtils.getResponsiveIconSize(context, 180),
                  height: ResponsiveUtils.getResponsiveIconSize(context, 180),
                  child: AnimatedBuilder(
                    animation: _chartAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: EnhancedCircularProgressPainter(
                          progress: progress * _chartAnimation.value,
                          strokeWidth: 12,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$daysSinceBirth',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 48),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A1A),
                                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                ),
                              ),
                              Text(
                                texts['daysPassed'] ?? 'days passed',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                                  color: const Color(0xFF6B7280),
                                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                
                // Stats Row
                Row(
                  children: [
                    _buildStatCard(
                      '${(progress * 100).toInt()}%',
                      texts['completed'] ?? 'Completed',
                      const Color(0xFF10B981),
                      Icons.check_circle_outline,
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                    _buildStatCard(
                      '${180 - daysSinceBirth}',
                      texts['daysPassed'] ?? 'Days Left',
                      const Color(0xFF0086FF),
                      Icons.schedule_outlined,
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                    _buildStatCard(
                      texts['onTrack'] ?? 'On Track',
                      texts['target'] ?? 'Status',
                      const Color(0xFF8B5CF6),
                      Icons.trending_up_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
          top: ResponsiveUtils.getResponsiveSpacing(context, 16),
          bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
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
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                color: const Color(0xFF6B7280),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(Map<String, String> texts) {
    final periods = ['week', 'month', '3months', '6months'];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: ResponsiveUtils.getResponsivePadding(context).copyWith(
                  top: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0086FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  texts[period] ?? period,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressChart(int daysSinceBirth, double progress, Map<String, String> texts) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, _) {
        return Container(
          padding: ResponsiveUtils.getResponsivePadding(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texts['weeklyProgress'] ?? 'Weekly Progress',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
              
              // Weekly Progress Bars
              ...List.generate(7, (index) {
                final dayProgress = math.min(1.0, (daysSinceBirth - index * 7) / 7.0);
                final animatedProgress = dayProgress * _chartAnimation.value;
                
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week ${index + 1}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 6)),
                      LinearProgressIndicator(
                        value: animatedProgress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(
                            const Color(0xFF10B981),
                            const Color(0xFF0086FF),
                            index / 6,
                          )!,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestonesSection(List<MilestoneData> milestones, Map<String, String> texts) {
    return SlideTransition(
      position: _milestoneSlideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['milestones'] ?? 'Milestones',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          
          ...milestones.asMap().entries.map((entry) {
            final index = entry.key;
            final milestone = entry.value;
            
            return AnimatedBuilder(
              animation: _milestoneController,
              builder: (context, child) {
                final delay = index * 0.1;
                final animationValue = (_milestoneController.value - delay).clamp(0.0, 1.0);
                
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: _buildMilestoneCard(milestone, texts),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(MilestoneData milestone, Map<String, String> texts) {
    final isCompleted = milestone.currentDay >= milestone.targetDay;
    final isInProgress = milestone.currentDay >= milestone.targetDay - 15 && !isCompleted;
    final progress = (milestone.currentDay / milestone.targetDay).clamp(0.0, 1.0);

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
      ),
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted 
            ? milestone.color.withOpacity(0.3)
            : Colors.grey.withOpacity(0.1),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Milestone Icon
          Container(
            width: ResponsiveUtils.getResponsiveIconSize(context, 60),
            height: ResponsiveUtils.getResponsiveIconSize(context, 60),
            decoration: BoxDecoration(
              color: milestone.color.withOpacity(isCompleted ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : milestone.icon,
              color: milestone.color,
              size: ResponsiveUtils.getResponsiveIconSize(context, 28),
            ),
          ),
          
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          
          // Milestone Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                
                Text(
                  isCompleted
                    ? texts['completed'] ?? 'Completed'
                    : isInProgress
                      ? texts['inProgress'] ?? 'In Progress'
                      : texts['upcoming'] ?? 'Upcoming',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: milestone.color,
                    fontWeight: FontWeight.w500,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                
                // Progress Bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(milestone.color),
                  minHeight: 6,
                ),
                
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                
                Text(
                  'Day ${milestone.targetDay}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: const Color(0xFF9CA3AF),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
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