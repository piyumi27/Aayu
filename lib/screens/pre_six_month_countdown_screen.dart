import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';

import '../models/child.dart';
import '../providers/child_provider.dart';

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
          _showAchievementCelebration();
        } else if (daysSinceBirth >= 181) {
          // Auto-redirect after celebration
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) {
              context.go('/growth');
            }
          });
        }
      }
    });
  }

  void _showAchievementCelebration() {
    setState(() {
      _achievementShown = true;
    });

    _confettiController.play();

    // Show achievement dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showAchievementDialog();
      }
    });
  }

  void _showAchievementDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0086FF),
                const Color(0xFF00B894),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 Congratulations! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your baby has completed 6 months!\nTime to start the growth tracking journey.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/growth');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0086FF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Start Growth Tracking',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    _animationController.dispose();
    _confettiController.dispose();
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
            // Confetti widgets
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2, // Downward
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 50,
                gravity: 0.05,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 0,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.05,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.05,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
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
                onPressed: () => context.pop(),
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
                                      // Days left
                                      Text(
                                        '${180 - daysSinceBirth} ${texts['daysLeft'] ?? 'days left'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: const Color(0xFF0086FF),
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
      onTap: () => context.go('/'),
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