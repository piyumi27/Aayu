import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../providers/child_provider.dart';
import '../utils/responsive_utils.dart';
import '../widgets/safe_ink_well.dart';
import '../l10n/l10n.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  // Industrial color scheme - matching progress screen
  static const Color primaryBlue = Color(0xFF0086FF);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color neutralGray = Color(0xFF6B7280);
  static const Color surfaceWhite = Color(0xFFFAFBFC);
  static const Color cardWhite = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedLanguage = 'en';
  String _selectedCategory = 'all'; // all, milestones, daily, weekly, special

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

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Achievements',
        'subtitle': 'Your journey of accomplishments',
        'level': 'Level',
        'progress': 'Progress',
        'points': 'Points',
        'achievements': 'Achievements',
        'badges': 'Badges Earned',
        'streaks': 'Current Streak',
        'totalPoints': 'Total Points',
        'nextLevel': 'Next Level',
        'categories': 'Categories',
        'all': 'All',
        'milestones': 'Milestones',
        'daily': 'Daily',
        'weekly': 'Weekly',
        'special': 'Special',
        'unlocked': 'Unlocked',
        'locked': 'Locked',
        'inProgress': 'In Progress',
        'congratulations': 'Congratulations!',
        'newBadge': 'New Badge Unlocked',
        'keepGoing': 'Keep up the great work!',
        'days': 'days',
        'collected': 'collected',
        'complete': 'complete',
        // Achievement titles
        'firstWeek': 'First Week Champion',
        'earlyRiser': 'Early Riser',
        'consistency': 'Consistency Master',
        'milestone30': '30 Days Strong',
        'milestone60': '60 Days Warrior',
        'milestone90': '90 Days Hero',
        'milestone120': '120 Days Legend',
        'milestone150': '150 Days Champion',
        'milestone180': '180 Days Master',
        'perfectWeek': 'Perfect Week',
        'monthlyGoal': 'Monthly Goal Crusher',
        'dedication': 'Dedication Award',
        'explorer': 'Growth Explorer',
        'tracker': 'Progress Tracker',
      },
      'si': {
        'title': 'ජයග්‍රහණ',
        'subtitle': 'ඔබේ සාර්ථකත්ව ගමන',
        'level': 'මට්ටම',
        'progress': 'ප්‍රගතිය',
        'points': 'ලකුණු',
        'achievements': 'ජයග්‍රහණ',
        'badges': 'උපාධි ලබා ගත්',
        'streaks': 'වර්තමාන අඛණ්ඩතාව',
        'totalPoints': 'සම්පූර්ණ ලකුණු',
        'nextLevel': 'ඊළඟ මට්ටම',
        'categories': 'කාණ්ඩ',
        'all': 'සියල්ල',
        'milestones': 'සන්ධිස්ථාන',
        'daily': 'දිනපතා',
        'weekly': 'සතිපතා',
        'special': 'විශේෂ',
        'unlocked': 'අගුළු ඇරුණි',
        'locked': 'අගුළු දමා ඇත',
        'inProgress': 'ක්‍රියාත්මකයි',
        'congratulations': 'සුභ පැතුම්!',
        'newBadge': 'නව උපාධියක් අගුළු ඇරුණි',
        'keepGoing': 'හොඳ වැඩක් දිගටම කරගෙන යන්න!',
        'days': 'දින',
        'collected': 'රැස්කර ගන්නා ලදි',
        'complete': 'සම්පූර්ණ',
      },
      'ta': {
        'title': 'சாதனைகள்',
        'subtitle': 'உங்கள் வெற்றியின் பயணம்',
        'level': 'நிலை',
        'progress': 'முன்னேற்றம்',
        'points': 'புள்ளிகள்',
        'achievements': 'சாதனைகள்',
        'badges': 'பெறப்பட்ட பேட்ஜ்கள்',
        'streaks': 'தற்போதைய தொடர்ச்சி',
        'totalPoints': 'மொத்த புள்ளிகள்',
        'nextLevel': 'அடுத்த நிலை',
        'categories': 'வகைகள்',
        'all': 'அனைத்து',
        'milestones': 'மைல்கற்கள்',
        'daily': 'தினசரி',
        'weekly': 'வாராந்திர',
        'special': 'சிறப்பு',
        'unlocked': 'திறக்கப்பட்டது',
        'locked': 'பூட்டப்பட்டது',
        'inProgress': 'முன்னேற்றத்தில்',
        'congratulations': 'வாழ்த்துகள்!',
        'newBadge': 'புதிய பேட்ஜ் திறக்கப்பட்டது',
        'keepGoing': 'சிறந்த வேலையைத் தொடருங்கள்!',
        'days': 'நாட்கள்',
        'collected': 'சேகரிக்கப்பட்டது',
        'complete': 'முழுமையான',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }

  List<Achievement> _getAchievements(
      int daysSinceBirth, Map<String, String> texts) {
    final achievements = <Achievement>[
      // Milestone Achievements
      Achievement(
        id: 'first_week',
        title: texts['firstWeek'] ?? 'First Week Champion',
        description: 'Complete your first 7 days',
        category: 'milestones',
        icon: Icons.emoji_events,
        color: const Color(0xFFFFD700),
        points: 100,
        targetValue: 7,
        currentValue: daysSinceBirth.clamp(0, 7),
        isUnlocked: daysSinceBirth >= 7,
        rarity: AchievementRarity.bronze,
      ),

      Achievement(
        id: 'milestone_30',
        title: texts['milestone30'] ?? '30 Days Strong',
        description: 'Reach the 30-day milestone',
        category: 'milestones',
        icon: Icons.military_tech,
        color: const Color(0xFFFF6B35),
        points: 300,
        targetValue: 30,
        currentValue: daysSinceBirth.clamp(0, 30),
        isUnlocked: daysSinceBirth >= 30,
        rarity: AchievementRarity.silver,
      ),

      Achievement(
        id: 'milestone_60',
        title: texts['milestone60'] ?? '60 Days Warrior',
        description: 'Conquer 2 months of growth',
        category: 'milestones',
        icon: Icons.shield,
        color: const Color(0xFF10B981),
        points: 600,
        targetValue: 60,
        currentValue: daysSinceBirth.clamp(0, 60),
        isUnlocked: daysSinceBirth >= 60,
        rarity: AchievementRarity.silver,
      ),

      Achievement(
        id: 'milestone_90',
        title: texts['milestone90'] ?? '90 Days Hero',
        description: 'Complete 3 months of dedication',
        category: 'milestones',
        icon: Icons.star,
        color: const Color(0xFF0086FF),
        points: 900,
        targetValue: 90,
        currentValue: daysSinceBirth.clamp(0, 90),
        isUnlocked: daysSinceBirth >= 90,
        rarity: AchievementRarity.gold,
      ),

      Achievement(
        id: 'milestone_120',
        title: texts['milestone120'] ?? '120 Days Legend',
        description: '4 months of amazing progress',
        category: 'milestones',
        icon: Icons.workspace_premium,
        color: const Color(0xFF8B5CF6),
        points: 1200,
        targetValue: 120,
        currentValue: daysSinceBirth.clamp(0, 120),
        isUnlocked: daysSinceBirth >= 120,
        rarity: AchievementRarity.gold,
      ),

      Achievement(
        id: 'milestone_150',
        title: texts['milestone150'] ?? '150 Days Champion',
        description: '5 months of incredible growth',
        category: 'milestones',
        icon: Icons.diamond,
        color: const Color(0xFFEC4899),
        points: 1500,
        targetValue: 150,
        currentValue: daysSinceBirth.clamp(0, 150),
        isUnlocked: daysSinceBirth >= 150,
        rarity: AchievementRarity.platinum,
      ),

      Achievement(
        id: 'milestone_180',
        title: texts['milestone180'] ?? '180 Days Master',
        description: 'Complete the 6-month journey',
        category: 'milestones',
        icon: Icons.emoji_events,
        color: const Color(0xFFFFD700),
        points: 1800,
        targetValue: 180,
        currentValue: daysSinceBirth.clamp(0, 180),
        isUnlocked: daysSinceBirth >= 180,
        rarity: AchievementRarity.diamond,
      ),

      // Daily Achievements
      Achievement(
        id: 'early_riser',
        title: texts['earlyRiser'] ?? 'Early Riser',
        description: 'Log progress before 9 AM',
        category: 'daily',
        icon: Icons.wb_sunny,
        color: const Color(0xFFFBBF24),
        points: 50,
        targetValue: 1,
        currentValue: 1, // Simulated
        isUnlocked: true,
        rarity: AchievementRarity.bronze,
      ),

      Achievement(
        id: 'consistency',
        title: texts['consistency'] ?? 'Consistency Master',
        description: 'Track progress for 10 consecutive days',
        category: 'weekly',
        icon: Icons.done_all,
        color: const Color(0xFF059669),
        points: 250,
        targetValue: 10,
        currentValue: math.min(daysSinceBirth, 10),
        isUnlocked: daysSinceBirth >= 10,
        rarity: AchievementRarity.silver,
      ),

      Achievement(
        id: 'perfect_week',
        title: texts['perfectWeek'] ?? 'Perfect Week',
        description: 'Complete all daily goals for a week',
        category: 'weekly',
        icon: Icons.grade,
        color: const Color(0xFF7C3AED),
        points: 200,
        targetValue: 7,
        currentValue: math.min(daysSinceBirth, 7),
        isUnlocked: daysSinceBirth >= 7,
        rarity: AchievementRarity.silver,
      ),

      // Special Achievements
      Achievement(
        id: 'explorer',
        title: texts['explorer'] ?? 'Growth Explorer',
        description: 'Visit all app sections',
        category: 'special',
        icon: Icons.explore,
        color: const Color(0xFF06B6D4),
        points: 150,
        targetValue: 1,
        currentValue: 1, // Simulated
        isUnlocked: true,
        rarity: AchievementRarity.bronze,
      ),

      Achievement(
        id: 'tracker',
        title: texts['tracker'] ?? 'Progress Tracker',
        description: 'View your progress 5 times',
        category: 'special',
        icon: Icons.analytics,
        color: const Color(0xFFEF4444),
        points: 100,
        targetValue: 5,
        currentValue: 5, // Simulated
        isUnlocked: true,
        rarity: AchievementRarity.bronze,
      ),
    ];

    return achievements;
  }

  List<Achievement> _getFilteredAchievements(List<Achievement> achievements) {
    if (_selectedCategory == 'all') return achievements;
    return achievements.where((a) => a.category == _selectedCategory).toList();
  }

  int _calculateTotalPoints(List<Achievement> achievements) {
    return achievements
        .where((a) => a.isUnlocked)
        .fold(0, (total, achievement) => total + achievement.points);
  }

  int _calculateCurrentLevel(int totalPoints) {
    return (totalPoints / 500).floor() + 1;
  }

  double _calculateLevelProgress(int totalPoints) {
    final currentLevelPoints = totalPoints % 500;
    return currentLevelPoints / 500.0;
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
        final achievements = _getAchievements(daysSinceBirth, texts);
        final filteredAchievements = _getFilteredAchievements(achievements);
        final totalPoints = _calculateTotalPoints(achievements);
        final currentLevel = _calculateCurrentLevel(totalPoints);
        final levelProgress = _calculateLevelProgress(totalPoints);
        final unlockedAchievements =
            achievements.where((a) => a.isUnlocked).length;

        return Scaffold(
          backgroundColor: surfaceWhite,
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
                        // Level Overview Card
                        _buildLevelOverviewCard(
                          currentLevel,
                          levelProgress,
                          totalPoints,
                          texts,
                        ),

                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context, 24)),

                        // Statistics Grid
                        _buildStatsGrid(
                            unlockedAchievements, achievements.length, texts),

                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context, 24)),

                        // Category Filter
                        _buildCategoryFilter(texts),

                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context, 24)),

                        // Achievements Section
                        _buildAchievementsGrid(filteredAchievements, texts),

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
        texts['title'] ?? 'Achievements',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      backgroundColor: cardWhite,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {
            // Share functionality
          },
        ),
      ],
    );
  }

  Widget _buildLevelOverviewCard(
    int currentLevel,
    double levelProgress,
    int totalPoints,
    Map<String, String> texts,
  ) {
    final pointsToNext = 500 - (totalPoints % 500);

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: cardWhite,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: warningAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.military_tech_outlined,
                  color: warningAmber,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 32),
                ),
              ),
              SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $currentLevel',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 24),
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '$totalPoints total points earned',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress to Level ${currentLevel + 1}',
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Text(
                    '${(levelProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: warningAmber,
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              LinearProgressIndicator(
                value: levelProgress,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: AlwaysStoppedAnimation<Color>(warningAmber),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
              Text(
                '$pointsToNext more points needed for next level',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(int unlockedAchievements, int totalAchievements,
      Map<String, String> texts) {
    return GridView.count(
      crossAxisCount: ResponsiveUtils.isSmallWidth(context) ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
      mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 16),
      childAspectRatio: ResponsiveUtils.isSmallWidth(context) ? 1.2 : 1.1,
      children: [
        _buildStatCard(
          '$unlockedAchievements',
          'Unlocked',
          Icons.check_circle_outline_rounded,
          successGreen,
        ),
        _buildStatCard(
          '${totalAchievements - unlockedAchievements}',
          'Remaining',
          Icons.radio_button_unchecked_rounded,
          neutralGray,
        ),
        _buildStatCard(
          '${(unlockedAchievements / totalAchievements * 100).toInt()}%',
          'Completion',
          Icons.pie_chart_outline_rounded,
          primaryBlue,
        ),
        _buildStatCard(
          '4',
          'Categories',
          Icons.category_outlined,
          errorRed,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOldHeroSection(
    int currentLevel,
    double levelProgress,
    int totalPoints,
    int unlockedAchievements,
    int totalAchievements,
    Map<String, String> texts,
  ) {
    // Old implementation - keeping for reference
    return Container();
  }

  // Old stat card - replaced with new implementation above
  Widget _buildOldStatCard(
      String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: ResponsiveUtils.getResponsivePadding(context),
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
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context, 28),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Text(
              value,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: const Color(0xFF6B7280),
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
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

  Widget _buildCategoryFilter(Map<String, String> texts) {
    final categories = ['all', 'milestones', 'daily', 'weekly', 'special'];

    return Container(
      height: ResponsiveUtils.getResponsiveSpacing(context, 50),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: EdgeInsets.only(
              right: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            child: SafeInkWell(
              onTap: () => setState(() => _selectedCategory = category),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryBlue : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  texts[category] ?? category,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsGrid(
      List<Achievement> achievements, Map<String, String> texts) {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 20)),
          Text(
            texts['achievements'] ?? 'Achievements',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.getResponsiveColumnCount(context),
              crossAxisSpacing:
                  ResponsiveUtils.getResponsiveSpacing(context, 12),
              mainAxisSpacing:
                  ResponsiveUtils.getResponsiveSpacing(context, 12),
              childAspectRatio:
                  0.75, // Fixed aspect ratio for consistent sizing
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(achievement, texts);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
      Achievement achievement, Map<String, String> texts) {
    final progress = achievement.targetValue > 0
        ? (achievement.currentValue / achievement.targetValue).clamp(0.0, 1.0)
        : 1.0;

    return GestureDetector(
      onTap: () => _showAchievementDetails(achievement, texts),
      child: Container(
        height: double.infinity, // Ensures all cards have same height
        padding:
            EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 12)),
        decoration: BoxDecoration(
          color:
              achievement.isUnlocked ? Colors.white : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: achievement.isUnlocked
                ? achievement.color.withOpacity(0.4)
                : const Color(0xFFE5E7EB),
            width: achievement.isUnlocked ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: achievement.isUnlocked
                  ? achievement.color.withOpacity(0.15)
                  : Colors.black.withOpacity(0.03),
              blurRadius: achievement.isUnlocked ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // Top section: Icon
            Expanded(
              flex: 3,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow effect for unlocked achievements
                    if (achievement.isUnlocked)
                      Container(
                        width:
                            ResponsiveUtils.getResponsiveIconSize(context, 56),
                        height:
                            ResponsiveUtils.getResponsiveIconSize(context, 56),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              achievement.color.withOpacity(0.2),
                              achievement.color.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    // Icon container
                    Container(
                      width: ResponsiveUtils.getResponsiveIconSize(context, 48),
                      height:
                          ResponsiveUtils.getResponsiveIconSize(context, 48),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? achievement.color.withOpacity(0.15)
                            : const Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achievement.isUnlocked
                            ? achievement.icon
                            : Icons.lock_outline,
                        size:
                            ResponsiveUtils.getResponsiveIconSize(context, 24),
                        color: achievement.isUnlocked
                            ? achievement.color
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                    // Checkmark for unlocked achievements
                    if (achievement.isUnlocked)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: ResponsiveUtils.getResponsiveIconSize(
                              context, 16),
                          height: ResponsiveUtils.getResponsiveIconSize(
                              context, 16),
                          decoration: BoxDecoration(
                            color: _getRarityColor(achievement.rarity),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: ResponsiveUtils.getResponsiveIconSize(
                                context, 10),
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Middle section: Title
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 4),
                ),
                child: Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                    color: achievement.isUnlocked
                        ? const Color(0xFF111827)
                        : const Color(0xFF6B7280),
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Bottom section: Progress/Status
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!achievement.isUnlocked &&
                      achievement.targetValue > 0) ...[
                    // Progress bar for locked achievements
                    Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        bottom:
                            ResponsiveUtils.getResponsiveSpacing(context, 4),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          achievement.color.withOpacity(0.6),
                        ),
                        minHeight: 4,
                      ),
                    ),
                    Text(
                      '${achievement.currentValue}/${achievement.targetValue}',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 10),
                        color: const Color(0xFF9CA3AF),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                  ] else ...[
                    // Points or locked status
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveUtils.getResponsiveSpacing(context, 8),
                        vertical:
                            ResponsiveUtils.getResponsiveSpacing(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: achievement.isUnlocked
                            ? achievement.color.withOpacity(0.1)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        achievement.isUnlocked
                            ? '${achievement.points}pt'
                            : texts['locked'] ?? 'Locked',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 10),
                          fontWeight: FontWeight.w600,
                          color: achievement.isUnlocked
                              ? achievement.color
                              : const Color(0xFF9CA3AF),
                          fontFamily: _selectedLanguage == 'si'
                              ? 'NotoSerifSinhala'
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFFC0C0C0);
      case AchievementRarity.gold:
        return const Color(0xFFFFD700);
      case AchievementRarity.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementRarity.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  void _showAchievementDetails(
      Achievement achievement, Map<String, String> texts) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  achievement.color.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Achievement Icon
                Container(
                  width: ResponsiveUtils.getResponsiveIconSize(context, 80),
                  height: ResponsiveUtils.getResponsiveIconSize(context, 80),
                  decoration: BoxDecoration(
                    color: achievement.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement.icon,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 40),
                    color: achievement.color,
                  ),
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 16)),

                // Achievement Title
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8)),

                // Achievement Description
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: const Color(0xFF6B7280),
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 16)),

                // Points and Status
                Container(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  decoration: BoxDecoration(
                    color: achievement.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${achievement.points} ${texts['points']}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 16),
                          fontWeight: FontWeight.w600,
                          color: achievement.color,
                          fontFamily: _selectedLanguage == 'si'
                              ? 'NotoSerifSinhala'
                              : null,
                        ),
                      ),
                      Text(
                        achievement.isUnlocked
                            ? texts['unlocked'] ?? 'Unlocked'
                            : texts['locked'] ?? 'Locked',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 14),
                          color: const Color(0xFF6B7280),
                          fontFamily: _selectedLanguage == 'si'
                              ? 'NotoSerifSinhala'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 20)),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: achievement.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical:
                            ResponsiveUtils.getResponsiveSpacing(context, 16),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final int points;
  final int targetValue;
  final int currentValue;
  final bool isUnlocked;
  final AchievementRarity rarity;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.points,
    required this.targetValue,
    required this.currentValue,
    required this.isUnlocked,
    required this.rarity,
  });
}

enum AchievementRarity {
  bronze,
  silver,
  gold,
  platinum,
  diamond,
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent particles

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;

      // Animate particle opacity and position
      final opacity =
          (math.sin(animationValue * 2 * math.pi + i) * 0.5 + 0.5) * 0.3;
      final animatedY = y + math.sin(animationValue * 2 * math.pi + i) * 20;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, animatedY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
