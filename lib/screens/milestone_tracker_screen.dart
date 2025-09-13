import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../models/development_milestone.dart';
import '../providers/child_provider.dart';
import '../utils/responsive_utils.dart';

class MilestoneTrackerScreen extends StatefulWidget {
  const MilestoneTrackerScreen({super.key});

  @override
  State<MilestoneTrackerScreen> createState() => _MilestoneTrackerScreenState();
}

class _MilestoneTrackerScreenState extends State<MilestoneTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedLanguage = 'en';
  DevelopmentDomain _selectedDomain = DevelopmentDomain.grossMotor;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
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

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Milestone Tracker',
        'subtitle': 'Track developmental progress across all domains',
        'overview': 'Overview',
        'domains': 'Domains',
        'details': 'Details',
        'achieved': 'Achieved',
        'pending': 'Pending',
        'redFlag': 'Red Flag',
        'onTrack': 'On Track',
        'needsAttention': 'Needs Attention',
        'excellent': 'Excellent',
        'good': 'Good',
        'concernLevel': 'Concern Level',
        'totalMilestones': 'Total Milestones',
        'achievedMilestones': 'Achieved',
        'pendingMilestones': 'Pending',
        'redFlagCount': 'Red Flags',
        'percentageComplete': 'Complete',
        'activities': 'Suggested Activities',
        'observations': 'Observation Tips',
        'redFlagSigns': 'Red Flag Signs',
        'interventionGuidance': 'Intervention Guidance',
        'markAchieved': 'Mark as Achieved',
        'addObservation': 'Add Observation',
        'consultSpecialist': 'Consult Specialist',
        'domainProgress': 'Domain Progress',
        'ageRange': 'Age Range',
        'priority': 'Priority',
        'critical': 'Critical',
        'high': 'High',
        'medium': 'Medium',
        'low': 'Low',
        'grossMotor': 'Gross Motor',
        'fineMotor': 'Fine Motor',
        'language': 'Language',
        'cognitive': 'Cognitive',
        'socialEmotional': 'Social-Emotional',
        'adaptive': 'Adaptive',
        'months': 'months',
        'daysSince': 'days since expected',
        'daysUntil': 'days until expected',
        'rightOnTime': 'Right on time',
        'recommendations': 'Recommendations',
        'nextAppointment': 'Next Pediatric Appointment',
        'earlyIntervention': 'Consider Early Intervention',
        'continueMonitoring': 'Continue Monitoring',
      },
      'si': {
        'title': 'සන්ධිස්ථාන නිරීක්ෂකයා',
        'subtitle': 'සියලුම ක්ෂේත්‍රවල වර්ධන ප්‍රගතිය නිරීක්ෂණය කරන්න',
        'overview': 'සමස්ත දැක්ම',
        'domains': 'ක්ෂේත්‍ර',
        'details': 'විස්තර',
        'achieved': 'ජයගත්',
        'pending': 'බලාපොරොත්තුවෙන්',
        'redFlag': 'රතු කොඩිය',
        'onTrack': 'නිවැරදි මාර්ගයේ',
        'needsAttention': 'අවධානය අවශ්‍යයි',
        'excellent': 'විශිෂ්ට',
        'good': 'හොඳයි',
        'concernLevel': 'සැලකිලිමත් මට්ටම',
        'totalMilestones': 'සම්පූර්ණ සන්ධිස්ථාන',
        'achievedMilestones': 'ජයගත්',
        'pendingMilestones': 'බලාපොරොත්තුවෙන්',
        'redFlagCount': 'රතු කොඩි',
        'percentageComplete': 'සම්පූර්ණ',
        'activities': 'යෝජිත ක්‍රියාකාරකම්',
        'observations': 'නිරීක්ෂණ ඉඟි',
        'redFlagSigns': 'රතු කොඩියේ සලකුණු',
        'interventionGuidance': 'මැදිහත්වීමේ මග පෙන්වීම',
        'markAchieved': 'ජයගත් ලෙස සලකුණු කරන්න',
        'addObservation': 'නිරීක්ෂණයක් එකතු කරන්න',
        'consultSpecialist': 'විශේෂඥයෙකු සමග සාකච්ඡා කරන්න',
        'months': 'මාස',
        'grossMotor': 'ප්‍රධාන මෝටර්',
        'fineMotor': 'සියුම් මෝටර්',
        'language': 'භාෂාව',
        'cognitive': 'සංජානන',
        'socialEmotional': 'සමාජ-චිත්තවේගීය',
        'adaptive': 'අනුගත',
      },
      'ta': {
        'title': 'மைல்கல் கண்காணிப்பாளர்',
        'subtitle': 'அனைத்து களங்களிலும் வளர்ச்சி முன்னேற்றத்தைக் கண்காணிக்கவும்',
        'overview': 'கண்ணோட்டம்',
        'domains': 'களங்கள்',
        'details': 'விவரங்கள்',
        'achieved': 'அடைந்தது',
        'pending': 'நிலுவையில்',
        'redFlag': 'சிவப்புக் கொடி',
        'onTrack': 'சரியான பாதையில்',
        'needsAttention': 'கவனம் தேவை',
        'excellent': 'சிறந்தது',
        'good': 'நல்லது',
        'concernLevel': 'கவலை நிலை',
        'totalMilestones': 'மொத்த மைல்கற்கள்',
        'achievedMilestones': 'அடைந்தது',
        'pendingMilestones': 'நிலுவையில்',
        'redFlagCount': 'சிவப்புக் கொடிகள்',
        'percentageComplete': 'முழுமையானது',
        'activities': 'பரிந்துரைக்கப்பட்ட செயல்பாடுகள்',
        'observations': 'கண்காணிப்பு குறிப்புகள்',
        'redFlagSigns': 'சிவப்புக் கொடி அறிகுறிகள்',
        'interventionGuidance': 'தலையீட்டு வழிகாட்டுதல்',
        'markAchieved': 'அடைந்ததாகக் குறிக்கவும்',
        'addObservation': 'கண்காணிப்பு சேர்க்கவும்',
        'consultSpecialist': 'நிபுணரை அணுகவும்',
        'months': 'மாதங்கள்',
        'grossMotor': 'மொத்த மோட்டார்',
        'fineMotor': 'நுண் மோட்டார்',
        'language': 'மொழி',
        'cognitive': 'அறிவாற்றல்',
        'socialEmotional': 'சமூக-உணர்ச்சி',
        'adaptive': 'தகவமைப்பு',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
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

        return Scaffold(
          backgroundColor: const Color(0xFFFAFBFC),
          appBar: _buildAppBar(context, texts),
          body: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildTabBar(texts),
                      Expanded(
                        child: _buildTabContent(selectedChild, texts),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, Map<String, String> texts) {
    return AppBar(
      title: Text(
        texts['title'] ?? 'Milestone Tracker',
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
          icon: const Icon(Icons.filter_list_rounded),
          onPressed: () => _showFilterOptions(context, texts),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () => _showOptionsMenu(context, texts),
        ),
      ],
    );
  }

  Widget _buildTabBar(Map<String, String> texts) {
    return Container(
      color: Colors.white,
      padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(0, texts['overview'] ?? 'Overview', Icons.dashboard_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(1, texts['domains'] ?? 'Domains', Icons.category_rounded),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(2, texts['details'] ?? 'Details', Icons.analytics_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    const Color(0xFF0086FF),
                    const Color(0xFF0073E6),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: ResponsiveUtils.getResponsiveIconSize(context, 16),
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(Child child, Map<String, String> texts) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(child, texts);
      case 1:
        return _buildDomainsTab(child, texts);
      case 2:
        return _buildDetailsTab(child, texts);
      default:
        return _buildOverviewTab(child, texts);
    }
  }

  Widget _buildOverviewTab(Child child, Map<String, String> texts) {
    final milestones = _getMockMilestones(child);
    final stats = _calculateMilestoneStats(milestones);

    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewSummaryCard(child, stats, texts),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          _buildDomainProgressGrid(child, texts),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          _buildRecentAchievements(milestones, texts),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          _buildAlerts(child, texts),
        ],
      ),
    );
  }

  Widget _buildDomainsTab(Child child, Map<String, String> texts) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDomainSelector(texts),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          _buildDomainDetailCard(child, _selectedDomain, texts),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          _buildDomainMilestones(child, _selectedDomain, texts),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Child child, Map<String, String> texts) {
    final milestones = _getMockMilestones(child);
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailedProgressChart(child, texts),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          _buildMilestoneTimeline(milestones, texts),
        ],
      ),
    );
  }

  Widget _buildOverviewSummaryCard(Child child, Map<String, dynamic> stats, Map<String, String> texts) {
    final ageInMonths = _getChildAgeInMonths(child);
    final progressColor = _getProgressColor(stats['percentage'] ?? 0.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            progressColor.withValues(alpha: 0.08),
            progressColor.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) + 8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [progressColor, progressColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${child.name}\'s Development',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '$ageInMonths ${texts['months'] ?? 'months'} old',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(context, 120),
                        height: ResponsiveUtils.getResponsiveSpacing(context, 120),
                        child: CircularProgressIndicator(
                          value: stats['percentage'] / 100,
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${stats['percentage'].round()}%',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
                              fontWeight: FontWeight.w800,
                              color: progressColor,
                            ),
                          ),
                          Text(
                            texts['percentageComplete'] ?? 'Complete',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 24)),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildStatRow(
                        texts['totalMilestones'] ?? 'Total',
                        '${stats['total']}',
                        Icons.flag_rounded,
                        const Color(0xFF0086FF),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                      _buildStatRow(
                        texts['achievedMilestones'] ?? 'Achieved',
                        '${stats['achieved']}',
                        Icons.check_circle_rounded,
                        const Color(0xFF10B981),
                      ),
                      SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                      _buildStatRow(
                        texts['redFlagCount'] ?? 'Red Flags',
                        '${stats['redFlags']}',
                        Icons.warning_rounded,
                        const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (stats['redFlags'] > 0) ...[
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: const Color(0xFFEF4444),
                      size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                    Expanded(
                      child: Text(
                        texts['consultSpecialist'] ?? 'Consider consulting a pediatrician for assessment',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
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
            size: ResponsiveUtils.getResponsiveIconSize(context, 14),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
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

  Widget _buildDomainProgressGrid(Child child, Map<String, String> texts) {
    final domains = DevelopmentDomain.values;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['domainProgress'] ?? 'Domain Progress',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveUtils.getResponsiveColumnCount(context),
            crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
            mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
            childAspectRatio: 1.2,
          ),
          itemCount: domains.length,
          itemBuilder: (context, index) {
            return _buildDomainCard(domains[index], child, texts);
          },
        ),
      ],
    );
  }

  Widget _buildDomainCard(DevelopmentDomain domain, Child child, Map<String, String> texts) {
    final progress = _getMockDomainProgress(domain, child);
    final color = _getDomainColor(domain);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDomain = domain;
          _selectedTab = 1;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDomainIcon(domain),
                  color: color,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Text(
                texts[domain.name] ?? domain.displayName,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 3,
                borderRadius: BorderRadius.circular(2),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
              Text(
                '${progress.round()}%',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(List<DevelopmentMilestone> milestones, Map<String, String> texts) {
    final recentAchievements = milestones.where((m) => _isMilestoneAchieved(m)).take(3).toList();
    
    if (recentAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Achievements',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
        ...recentAchievements.map((milestone) => _buildAchievementCard(milestone, texts)),
      ],
    );
  }

  Widget _buildAchievementCard(DevelopmentMilestone milestone, Map<String, String> texts) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, 12)),
      padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              size: ResponsiveUtils.getResponsiveIconSize(context, 20),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.milestone,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  milestone.getAgeRangeDescription(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              texts['achieved'] ?? 'Achieved',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts(Child child, Map<String, String> texts) {
    final alerts = _getMockAlerts(child);
    
    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts & Recommendations',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
        ...alerts.map((alert) => _buildAlertCard(alert, texts)),
      ],
    );
  }

  Widget _buildAlertCard(DevelopmentAlert alert, Map<String, String> texts) {
    final color = _getAlertColor(alert.severity);
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, 12)),
      padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAlertIcon(alert.severity),
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context, 20),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  alert.description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainSelector(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Domain',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
        Wrap(
          spacing: ResponsiveUtils.getResponsiveSpacing(context, 8),
          runSpacing: ResponsiveUtils.getResponsiveSpacing(context, 8),
          children: DevelopmentDomain.values.map((domain) {
            final isSelected = domain == _selectedDomain;
            final color = _getDomainColor(domain);
            
            return GestureDetector(
              onTap: () => setState(() => _selectedDomain = domain),
              child: Container(
                padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.5),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                  border: Border.all(color: color),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getDomainIcon(domain),
                      color: isSelected ? Colors.white : color,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                    Text(
                      texts[domain.name] ?? domain.displayName,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDomainDetailCard(Child child, DevelopmentDomain domain, Map<String, String> texts) {
    final progress = _getMockDomainProgress(domain, child);
    final color = _getDomainColor(domain);
    final milestones = _getMockMilestonesForDomain(domain, child);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) + 8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                  ),
                  child: Icon(
                    _getDomainIcon(domain),
                    color: Colors.white,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texts[domain.name] ?? domain.displayName,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        domain.description,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            Row(
              children: [
                Expanded(
                  child: _buildDomainStatCard(
                    'Total Milestones',
                    '${milestones.length}',
                    Icons.flag_rounded,
                    color,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                Expanded(
                  child: _buildDomainStatCard(
                    'Achieved',
                    '${milestones.where((m) => _isMilestoneAchieved(m)).length}',
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                Expanded(
                  child: _buildDomainStatCard(
                    'Progress',
                    '${progress.round()}%',
                    Icons.trending_up_rounded,
                    color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveUtils.getResponsiveIconSize(context, 20),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDomainMilestones(Child child, DevelopmentDomain domain, Map<String, String> texts) {
    final milestones = _getMockMilestonesForDomain(domain, child);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
        ...milestones.map((milestone) => _buildMilestoneCard(milestone, texts)),
      ],
    );
  }

  Widget _buildMilestoneCard(DevelopmentMilestone milestone, Map<String, String> texts) {
    final isAchieved = _isMilestoneAchieved(milestone);
    final isRedFlag = milestone.isRedFlag;
    final color = isRedFlag 
        ? const Color(0xFFEF4444)
        : isAchieved 
            ? const Color(0xFF10B981)
            : const Color(0xFF6B7280);

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
        border: Border.all(
          color: isRedFlag 
              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isAchieved 
                ? Icons.check_circle_rounded
                : isRedFlag 
                    ? Icons.warning_rounded
                    : Icons.radio_button_unchecked_rounded,
            color: color,
            size: ResponsiveUtils.getResponsiveIconSize(context, 20),
          ),
        ),
        title: Text(
          milestone.milestone,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          '${milestone.getAgeRangeDescription()} • ${milestone.getPriorityLabel()}',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
            color: const Color(0xFF6B7280),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRedFlag)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  texts['redFlag'] ?? 'Red Flag',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 9),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            Icon(
              Icons.expand_more_rounded,
              color: const Color(0xFF6B7280),
              size: ResponsiveUtils.getResponsiveIconSize(context, 20),
            ),
          ],
        ),
        children: [
          Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: const Color(0xFF374151),
                  ),
                ),
                if (milestone.observationTips.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                  Text(
                    texts['observations'] ?? 'Observation Tips',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                  Text(
                    milestone.observationTips,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
                if (milestone.activities.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                  Text(
                    texts['activities'] ?? 'Suggested Activities',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                  ...milestone.activities.map((activity) => Padding(
                    padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          margin: EdgeInsets.only(
                            top: ResponsiveUtils.getResponsiveSpacing(context, 8),
                            right: ResponsiveUtils.getResponsiveSpacing(context, 8),
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B7280),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            activity,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                if (isRedFlag && milestone.redFlagSigns.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                  Container(
                    padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: const Color(0xFFEF4444),
                              size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                            ),
                            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                            Text(
                              texts['redFlagSigns'] ?? 'Red Flag Signs',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                        ...milestone.redFlagSigns.map((sign) => Text(
                          '• $sign',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                            color: const Color(0xFFDC2626),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                Row(
                  children: [
                    if (!isAchieved)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _markMilestoneAchieved(milestone),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                            ),
                          ),
                          child: Text(
                            texts['markAchieved'] ?? 'Mark Achieved',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (!isAchieved && isRedFlag) ...[
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _consultSpecialist(milestone),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                            ),
                          ),
                          child: Text(
                            texts['consultSpecialist'] ?? 'Consult',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedProgressChart(Child child, Map<String, String> texts) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) + 8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Progress Analysis',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context, 200),
              child: CustomPaint(
                size: Size.infinite,
                painter: ProgressChartPainter(child),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneTimeline(List<DevelopmentMilestone> milestones, Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestone Timeline',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
        ...milestones.map((milestone) => _buildTimelineItem(milestone, texts)),
      ],
    );
  }

  Widget _buildTimelineItem(DevelopmentMilestone milestone, Map<String, String> texts) {
    final isAchieved = _isMilestoneAchieved(milestone);
    final color = isAchieved ? const Color(0xFF10B981) : const Color(0xFF6B7280);
    
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveSpacing(context, 16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: ResponsiveUtils.getResponsiveSpacing(context, 20),
                height: ResponsiveUtils.getResponsiveSpacing(context, 20),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAchieved ? Icons.check_rounded : Icons.circle_outlined,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 12),
                ),
              ),
              Container(
                width: 2,
                height: ResponsiveUtils.getResponsiveSpacing(context, 40),
                color: color.withValues(alpha: 0.3),
              ),
            ],
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Expanded(
            child: Container(
              padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.milestone,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    milestone.getAgeRangeDescription(),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context, Map<String, String> texts) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) + 8),
        ),
      ),
      builder: (context) => Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            ListTile(
              leading: const Icon(Icons.check_circle_outlined),
              title: const Text('Show Achieved Only'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.warning_outlined),
              title: const Text('Show Red Flags Only'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.pending_outlined),
              title: const Text('Show Pending Only'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, Map<String, String> texts) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUtils.getResponsiveBorderRadius(context) + 8),
        ),
      ),
      builder: (context) => Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Progress Report'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: const Text('Export to PDF'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Milestone Settings'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _markMilestoneAchieved(DevelopmentMilestone milestone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked "${milestone.milestone}" as achieved!'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  void _consultSpecialist(DevelopmentMilestone milestone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Specialist consultation information will be provided'),
        backgroundColor: const Color(0xFF0086FF),
      ),
    );
  }

  int _getChildAgeInMonths(Child child) {
    final now = DateTime.now();
    final difference = now.difference(child.birthDate);
    return (difference.inDays / 30.44).round();
  }

  List<DevelopmentMilestone> _getMockMilestones(Child child) {
    final ageInMonths = _getChildAgeInMonths(child);
    final random = math.Random(child.name.hashCode);
    
    return [
      DevelopmentMilestone(
        id: 'milestone_1',
        source: 'WHO',
        ageMonthsMin: 2,
        ageMonthsMax: 4,
        domain: 'gross_motor',
        milestone: 'Lifts head while on tummy',
        description: 'Baby can lift and hold head up while lying on stomach',
        observationTips: 'Place baby on tummy and observe head control',
        isRedFlag: false,
        priority: 2,
        activities: ['Tummy time', 'Visual tracking games'],
        redFlagSigns: [],
        interventionGuidance: 'Continue tummy time practice',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DevelopmentMilestone(
        id: 'milestone_2',
        source: 'WHO',
        ageMonthsMin: 3,
        ageMonthsMax: 5,
        domain: 'social_emotional',
        milestone: 'Smiles responsively',
        description: 'Baby smiles in response to others smiling',
        observationTips: 'Smile at baby and watch for responsive smiles',
        isRedFlag: false,
        priority: 1,
        activities: ['Face-to-face interaction', 'Peek-a-boo games'],
        redFlagSigns: [],
        interventionGuidance: 'Increase social interaction',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DevelopmentMilestone(
        id: 'milestone_3',
        source: 'WHO',
        ageMonthsMin: 4,
        ageMonthsMax: 6,
        domain: 'fine_motor',
        milestone: 'Reaches for objects',
        description: 'Baby reaches out to grab objects within reach',
        observationTips: 'Hold colorful toys within reach and observe reaching behavior',
        isRedFlag: false,
        priority: 2,
        activities: ['Object play', 'Reaching exercises'],
        redFlagSigns: [],
        interventionGuidance: 'Provide reaching opportunities',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      DevelopmentMilestone(
        id: 'milestone_4',
        source: 'WHO',
        ageMonthsMin: 6,
        ageMonthsMax: 8,
        domain: 'language',
        milestone: 'Babbles with expression',
        description: 'Baby makes babbling sounds with varied intonation',
        observationTips: 'Listen for different sounds and rhythm patterns',
        isRedFlag: ageInMonths > 8 && random.nextBool(),
        priority: 1,
        activities: ['Talk to baby', 'Sing songs', 'Read aloud'],
        redFlagSigns: ['No vocalization by 8 months', 'Loss of previously acquired sounds'],
        interventionGuidance: 'Consider hearing evaluation if no babbling by 8 months',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  List<DevelopmentMilestone> _getMockMilestonesForDomain(DevelopmentDomain domain, Child child) {
    return _getMockMilestones(child).where((m) => 
      DevelopmentDomain.fromString(m.domain) == domain
    ).toList();
  }

  Map<String, dynamic> _calculateMilestoneStats(List<DevelopmentMilestone> milestones) {
    final total = milestones.length;
    final achieved = milestones.where((m) => _isMilestoneAchieved(m)).length;
    final redFlags = milestones.where((m) => m.isRedFlag).length;
    final percentage = total > 0 ? (achieved / total) * 100 : 0.0;

    return {
      'total': total,
      'achieved': achieved,
      'pending': total - achieved,
      'redFlags': redFlags,
      'percentage': percentage,
    };
  }

  double _getMockDomainProgress(DevelopmentDomain domain, Child child) {
    final random = math.Random(child.name.hashCode + domain.index);
    return 60 + random.nextDouble() * 35;
  }

  bool _isMilestoneAchieved(DevelopmentMilestone milestone) {
    final random = math.Random(milestone.id.hashCode);
    return random.nextDouble() > 0.3;
  }

  List<DevelopmentAlert> _getMockAlerts(Child child) {
    final ageInMonths = _getChildAgeInMonths(child);
    final alerts = <DevelopmentAlert>[];
    
    if (ageInMonths > 6) {
      alerts.add(DevelopmentAlert(
        id: 'alert_1',
        childId: child.id,
        alertType: 'development_delay',
        severity: 'mild',
        title: 'Milestone Monitoring',
        description: 'Continue observing language development',
        missedMilestones: ['Babbling'],
        redFlags: [],
        recommendations: 'Increase verbal interaction',
        requiresEvaluation: false,
        createdAt: DateTime.now(),
      ));
    }
    
    return alerts;
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return const Color(0xFF10B981);
    if (percentage >= 60) return const Color(0xFF0086FF);
    if (percentage >= 40) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _getDomainColor(DevelopmentDomain domain) {
    return switch (domain) {
      DevelopmentDomain.grossMotor => const Color(0xFF10B981),
      DevelopmentDomain.fineMotor => const Color(0xFF0086FF),
      DevelopmentDomain.language => const Color(0xFF8B5CF6),
      DevelopmentDomain.cognitive => const Color(0xFFF59E0B),
      DevelopmentDomain.socialEmotional => const Color(0xFFEF4444),
      DevelopmentDomain.adaptive => const Color(0xFF06B6D4),
    };
  }

  IconData _getDomainIcon(DevelopmentDomain domain) {
    return switch (domain) {
      DevelopmentDomain.grossMotor => Icons.directions_run_rounded,
      DevelopmentDomain.fineMotor => Icons.pan_tool_rounded,
      DevelopmentDomain.language => Icons.chat_rounded,
      DevelopmentDomain.cognitive => Icons.psychology_rounded,
      DevelopmentDomain.socialEmotional => Icons.people_rounded,
      DevelopmentDomain.adaptive => Icons.self_improvement_rounded,
    };
  }

  Color _getAlertColor(String severity) {
    return switch (severity) {
      'severe' => const Color(0xFFEF4444),
      'moderate' => const Color(0xFFF59E0B),
      'mild' => const Color(0xFF0086FF),
      _ => const Color(0xFF6B7280),
    };
  }

  IconData _getAlertIcon(String severity) {
    return switch (severity) {
      'severe' => Icons.error_rounded,
      'moderate' => Icons.warning_rounded,
      'mild' => Icons.info_rounded,
      _ => Icons.circle_rounded,
    };
  }
}

class ProgressChartPainter extends CustomPainter {
  final Child child;

  ProgressChartPainter(this.child);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final domains = DevelopmentDomain.values;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(centerX, centerY) - 20;

    for (int i = 0; i < domains.length; i++) {
      final angle = (2 * math.pi * i) / domains.length - math.pi / 2;
      final progress = 60 + math.Random(domains[i].index).nextDouble() * 35;
      final progressRadius = radius * (progress / 100);

      final x = centerX + progressRadius * math.cos(angle);
      final y = centerY + progressRadius * math.sin(angle);

      paint.color = _getDomainColor(domains[i]);
      canvas.drawCircle(Offset(x, y), 4, paint);

      if (i < domains.length - 1) {
        final nextAngle = (2 * math.pi * (i + 1)) / domains.length - math.pi / 2;
        final nextProgress = 60 + math.Random(domains[i + 1].index).nextDouble() * 35;
        final nextProgressRadius = radius * (nextProgress / 100);
        final nextX = centerX + nextProgressRadius * math.cos(nextAngle);
        final nextY = centerY + nextProgressRadius * math.sin(nextAngle);

        canvas.drawLine(Offset(x, y), Offset(nextX, nextY), paint);
      }
    }

    // Connect last to first
    if (domains.isNotEmpty) {
      final firstAngle = -math.pi / 2;
      final lastAngle = (2 * math.pi * (domains.length - 1)) / domains.length - math.pi / 2;
      
      final firstProgress = 60 + math.Random(domains[0].index).nextDouble() * 35;
      final lastProgress = 60 + math.Random(domains[domains.length - 1].index).nextDouble() * 35;
      
      final firstRadius = radius * (firstProgress / 100);
      final lastRadius = radius * (lastProgress / 100);
      
      final firstX = centerX + firstRadius * math.cos(firstAngle);
      final firstY = centerY + firstRadius * math.sin(firstAngle);
      final lastX = centerX + lastRadius * math.cos(lastAngle);
      final lastY = centerY + lastRadius * math.sin(lastAngle);

      paint.color = _getDomainColor(domains[domains.length - 1]);
      canvas.drawLine(Offset(lastX, lastY), Offset(firstX, firstY), paint);
    }
  }

  Color _getDomainColor(DevelopmentDomain domain) {
    return switch (domain) {
      DevelopmentDomain.grossMotor => const Color(0xFF10B981),
      DevelopmentDomain.fineMotor => const Color(0xFF0086FF),
      DevelopmentDomain.language => const Color(0xFF8B5CF6),
      DevelopmentDomain.cognitive => const Color(0xFFF59E0B),
      DevelopmentDomain.socialEmotional => const Color(0xFFEF4444),
      DevelopmentDomain.adaptive => const Color(0xFF06B6D4),
    };
  }

  @override
  bool shouldRepaint(ProgressChartPainter oldDelegate) {
    return oldDelegate.child != child;
  }
}