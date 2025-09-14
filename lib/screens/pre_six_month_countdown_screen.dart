import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

import '../models/child.dart';
import '../providers/child_provider.dart';
import '../utils/safe_navigation.dart';

class PreSixMonthCountdownScreen extends StatefulWidget {
  const PreSixMonthCountdownScreen({super.key});

  @override
  State<PreSixMonthCountdownScreen> createState() => _PreSixMonthCountdownScreenState();
}

class _PreSixMonthCountdownScreenState extends State<PreSixMonthCountdownScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late ConfettiController _confettiController;
  String _selectedLanguage = 'en';
  bool _tipDismissed = false;
  bool _achievementShown = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadTipDismissedState();
    _initializeAnimations();
    _checkAutoRedirect();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);

    _animationController.forward();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  Future<void> _loadTipDismissedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tipDismissed = prefs.getBool('tip_dismissed_today') ?? false;
    });
  }

  Future<void> _dismissTip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tip_dismissed_today', true);
    setState(() {
      _tipDismissed = true;
    });
  }

  void _checkAutoRedirect() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childProvider = Provider.of<ChildProvider>(context, listen: false);
      final selectedChild = childProvider.selectedChild;

      if (selectedChild != null) {
        final daysSinceBirth = _calculateDaysSinceBirth(selectedChild);
        if (daysSinceBirth >= 180 && !_achievementShown) {
          _showBackgroundCelebration();
        }
      }
    });
  }

  void _showBackgroundCelebration() {
    setState(() {
      _achievementShown = true;
    });

    // Start confetti animation in background (no blocking dialog)
    _confettiController.play();

    // Stop confetti after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _confettiController.stop();
      }
    });
  }


  int _calculateDaysSinceBirth(Child child) {
    final now = DateTime.now();
    final difference = now.difference(child.birthDate);
    return difference.inDays;
  }

  double _calculateProgress(int daysSinceBirth) {
    return math.min(daysSinceBirth / 180.0, 1.0);
  }

  Color _getProgressColor(int daysSinceBirth) {
    final progress = _calculateProgress(daysSinceBirth);
    // Interpolate between #00B894 (green) at 0 days and #0086FF (blue) at 180 days
    return Color.lerp(
      const Color(0xFF00B894), // Green at start
      const Color(0xFF0086FF), // Blue at end
      progress,
    )!;
  }



  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': '6-Month Goal',
        'dayCounter': '',
        'daysCompleted': 'days completed',
        'daysLeft': 'days left',
        'goalAchieved': 'Goal Achieved!',
        'nextMilestone': 'Next milestone:',
        'inDays': 'in',
        'daysUnit': 'days',
        'tipOfTheDay': 'Tip of the Day',
        'tipContent': 'Set small daily goals to maintain momentum toward your 6-month target.',
        'progress': 'Progress',
        'achievements': 'Achievements',
        'goToDashboard': 'Go to Dashboard',
        'remainingDays': 'remaining days until 6 months',
      },
      'si': {
        'title': '6-මාස ඉලක්කය',
        'dayCounter': 'දිනය',
        'ofTotal': '180 න්',
        'nutritionTip': 'පෝෂණ ඉඟිය',
        'tipContent': 'දිනපතා විටමින් ඩී බිංදු හඳුන්වා දෙන්න.',
        'skipToDashboard': 'ඩෑෂ්බෝඩ් වෙත යන්න',
        'remainingDays': 'මාස 6 ක් වන තෙක් ඉතිරි දින',
      },
      'ta': {
        'title': 'வளர்ச்சி எண்ணிக்கை',
        'dayCounter': 'நாள்',
        'ofTotal': '180 இல்',
        'nutritionTip': 'ஊட்டச்சத்து குறிப்பு',
        'tipContent': 'தினமும் வைட்டமின் டி துளிகளை அறிமுகப்படுத்துங்கள்.',
        'skipToDashboard': 'டாஷ்போர்டுக்கு செல்லுங்கள்',
        'remainingDays': '6 மாதங்கள் வரை மீதமுள்ள நாட்கள்',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  @override
  void dispose() {
    try {
      // Safely dispose animation controller
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      _animationController.dispose();

      // Safely dispose confetti controller
      if (_confettiController.state == ConfettiControllerState.playing) {
        _confettiController.stop();
      }
      _confettiController.dispose();
    } catch (e) {
      // Ignore disposal errors to prevent cascade failures
      debugPrint('⚠️ Warning: Controller disposal failed: $e');
    }
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
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final daysSinceBirth = _calculateDaysSinceBirth(selectedChild);
        final progress = _calculateProgress(daysSinceBirth);
        final progressColor = _getProgressColor(daysSinceBirth);

        return Stack(
          children: [
            // Background confetti widgets (behind the circle)
            Positioned(
              top: 100,
              left: MediaQuery.of(context).size.width / 2 - 150,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2, // Downward
                maxBlastForce: 5,
                minBlastForce: 2,
                particleDrag: 0.03,
                emissionFrequency: 0.1,
                numberOfParticles: 20,
                gravity: 0.03,
                shouldLoop: false,
                colors: const [
                  Color(0xFF4CAF50), // Green
                  Color(0xFF0086FF), // Blue
                  Color(0xFFFF9800), // Orange
                  Color(0xFFE91E63), // Pink
                ],
              ),
            ),
            Positioned(
              top: 120,
              left: 50,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 4, // Diagonal
                maxBlastForce: 4,
                minBlastForce: 2,
                particleDrag: 0.03,
                emissionFrequency: 0.08,
                numberOfParticles: 15,
                gravity: 0.03,
                shouldLoop: false,
                colors: const [
                  Color(0xFF4CAF50),
                  Color(0xFF0086FF),
                  Color(0xFFFF9800),
                ],
              ),
            ),
            Positioned(
              top: 120,
              right: 50,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 3 * math.pi / 4, // Diagonal
                maxBlastForce: 4,
                minBlastForce: 2,
                particleDrag: 0.03,
                emissionFrequency: 0.08,
                numberOfParticles: 15,
                gravity: 0.03,
                shouldLoop: false,
                colors: const [
                  Color(0xFF4CAF50),
                  Color(0xFF0086FF),
                  Color(0xFFE91E63),
                ],
              ),
            ),
            Scaffold(
              backgroundColor: const Color(0xFFF8F9FA),
              appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A), size: 20),
                onPressed: () {
                  // Check if we can pop, otherwise go to home
                  if (Navigator.of(context).canPop()) {
                    SafeNavigation.safePop(context);
                  } else {
                    SafeNavigation.safeGo(context, '/');
                  }
                },
              ),
            ),
            title: Text(
              texts['title'] ?? '6-Month Goal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A), size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 
                             MediaQuery.of(context).padding.top - 
                             MediaQuery.of(context).padding.bottom - 
                             kToolbarHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Circular Progress Ring
                      Semantics(
                        label: '$daysSinceBirth ${texts['remainingDays']}',
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: CircularProgressPainter(
                                  progress: progress * _progressAnimation.value,
                                  progressColor: progressColor,
                                  strokeWidth: 8,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Large day number
                                      Text(
                                        '$daysSinceBirth',
                                        style: TextStyle(
                                          fontSize: 56,
                                          fontWeight: FontWeight.w300,
                                          color: const Color(0xFF1A1A1A),
                                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                        ),
                                      ),
                                      // Days completed
                                      Text(
                                        texts['daysCompleted'] ?? 'days completed',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: const Color(0xFF6B7280),
                                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Days left or achievement text
                                      Text(
                                        daysSinceBirth >= 180
                                          ? '🎉 ${texts['goalAchieved'] ?? 'Goal Achieved!'} 🎉'
                                          : '${180 - daysSinceBirth} ${texts['daysLeft'] ?? 'days left'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: daysSinceBirth >= 180
                                            ? const Color(0xFF4CAF50)  // Green for achievement
                                            : const Color(0xFF0086FF), // Blue for countdown
                                          fontWeight: FontWeight.w600,
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
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Next milestone
                      _buildNextMilestone(texts, daysSinceBirth),
                      
                      const Spacer(),
                      
                      // Tip-of-Day card
                      if (!_tipDismissed) ...[
                        _buildTipCard(texts),
                        const SizedBox(height: 20),
                      ],
                      
                      // Bottom buttons
                      _buildBottomButtons(texts),
                      
                      const SizedBox(height: 12),
                      
                      // Go to Dashboard button
                      _buildGoToDashboardButton(texts),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
          ], // Close Stack children
        );
      },
    );
  }

  Widget _buildNextMilestone(Map<String, String> texts, int daysSinceBirth) {
    // Calculate next milestone
    int nextMilestoneDay = 60; // Default to day 60
    if (daysSinceBirth >= 150) {
      nextMilestoneDay = 180;
    } else if (daysSinceBirth >= 120) {
      nextMilestoneDay = 150;
    } else if (daysSinceBirth >= 90) {
      nextMilestoneDay = 120;
    } else if (daysSinceBirth >= 60) {
      nextMilestoneDay = 90;
    } else if (daysSinceBirth >= 30) {
      nextMilestoneDay = 60;
    } else {
      nextMilestoneDay = 30;
    }

    final daysUntilMilestone = math.max(0, nextMilestoneDay - daysSinceBirth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0086FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF0086FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${texts['nextMilestone'] ?? 'Next milestone:'} Day $nextMilestoneDay (${texts['inDays'] ?? 'in'} $daysUntilMilestone ${texts['daysUnit'] ?? 'days'})',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF0086FF),
                fontWeight: FontWeight.w500,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(Map<String, String> texts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Light bulb icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0086FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: Color(0xFF0086FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  texts['tipOfTheDay'] ?? 'Tip of the Day',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  texts['tipContent'] ?? 'Set small daily goals to maintain momentum toward your 6-month target.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: _dismissTip,
            icon: const Icon(
              Icons.close,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(Map<String, String> texts) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/progress-tracking'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      texts['progress'] ?? 'Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/achievements'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      color: Color(0xFF8B5CF6),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      texts['achievements'] ?? 'Achievements',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoToDashboardButton(Map<String, String> texts) {
    return GestureDetector(
      onTap: () => SafeNavigation.safeGo(context, '/'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF0086FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.dashboard_outlined,
                color: Color(0xFF0086FF),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              texts['goToDashboard'] ?? 'Go to Dashboard',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF0086FF),
                fontWeight: FontWeight.w600,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
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

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}