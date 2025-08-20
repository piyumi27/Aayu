import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = 'en';
  
  // Lottie animation controllers for better performance
  late AnimationController _lottieController1;
  late AnimationController _lottieController2;
  late AnimationController _lottieController3;
  
  // Individual animation loading states
  final Map<int, bool> _animationLoadedStates = {
    0: false,
    1: false,
    2: false,
  };

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeLottieControllers();
  }

  void _initializeLottieControllers() {
    _lottieController1 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _lottieController2 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _lottieController3 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void _onAnimationLoaded(int index) {
    if (mounted) {
      setState(() {
        _animationLoadedStates[index] = true;
      });
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _lottieController1.dispose();
    _lottieController2.dispose();
    _lottieController3.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/login');
    }
  }

  Map<String, dynamic> _getLocalizedContent() {
    final Map<String, Map<String, dynamic>> content = {
      'en': {
        'skip': 'Skip',
        'getStarted': 'Get Started',
        'slides': [
          {
            'title': 'Track Growth',
            'subtitle': 'Monitor your child\'s height, weight and development milestones with easy-to-read charts',
          },
          {
            'title': 'Record Vaccines',
            'subtitle': 'Keep track of immunizations and get timely reminders for upcoming vaccines',
          },
          {
            'title': 'Learn Nutrition',
            'subtitle': 'Access expert guidance on child nutrition and healthy meal planning',
          },
        ],
      },
      'si': {
        'skip': 'මඟ හරින්න',
        'getStarted': 'ආරම්භ කරන්න',
        'slides': [
          {
            'title': 'වර්ධනය නිරීක්ෂණය',
            'subtitle': 'ඔබේ දරුවාගේ උස, බර සහ වර්ධන සන්ධිස්ථාන පහසුවෙන් කියවිය හැකි ප්‍රස්ථාර සමඟ නිරීක්ෂණය කරන්න',
          },
          {
            'title': 'එන්නත් වාර්තා',
            'subtitle': 'එන්නත් කිරීම් පිළිබඳව සටහන් තබා ගන්න සහ ඉදිරි එන්නත් සඳහා කාලෝචිත මතක් කිරීම් ලබා ගන්න',
          },
          {
            'title': 'පෝෂණය ඉගෙන ගන්න',
            'subtitle': 'ළමා පෝෂණය සහ සෞඛ්‍ය සම්පන්න ආහාර සැලසුම් පිළිබඳ විශේෂඥ මාර්ගෝපදේශ ලබා ගන්න',
          },
        ],
      },
      'ta': {
        'skip': 'தவிர்',
        'getStarted': 'தொடங்கு',
        'slides': [
          {
            'title': 'வளர்ச்சியைக் கண்காணிக்கவும்',
            'subtitle': 'உங்கள் குழந்தையின் உயரம், எடை மற்றும் வளர்ச்சி மைல்கற்களை எளிதில் படிக்கக்கூடிய விளக்கப்படங்களுடன் கண்காணிக்கவும்',
          },
          {
            'title': 'தடுப்பூசிகளை பதிவு செய்யுங்கள்',
            'subtitle': 'நோய்த்தடுப்பு மருந்துகளை கண்காணித்து, வரவிருக்கும் தடுப்பூசிகளுக்கான சரியான நேரத்தில் நினைவூட்டல்களைப் பெறுங்கள்',
          },
          {
            'title': 'ஊட்டச்சத்து கற்றுக்கொள்ளுங்கள்',
            'subtitle': 'குழந்தை ஊட்டச்சத்து மற்றும் ஆரோக்கியமான உணவு திட்டமிடல் குறித்த நிபுணர் வழிகாட்டுதலை அணுகவும்',
          },
        ],
      },
    };

    return content[_selectedLanguage] ?? content['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final localizedContent = _getLocalizedContent();
    final slides = localizedContent['slides'] as List;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Skip button
            Positioned(
              top: 20,
              right: 20,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  localizedContent['skip'],
                  style: TextStyle(
                    color: const Color(0xFF1E90FF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
            ),
            
            // Page content
            Column(
              children: [
                const SizedBox(height: 60),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                      
                      // Start animation for current page if it's already loaded
                      if (_animationLoadedStates[page] == true) {
                        switch (page) {
                          case 0:
                            _lottieController1.reset();
                            _lottieController1.forward();
                            break;
                          case 1:
                            _lottieController2.reset();
                            _lottieController2.forward();
                            break;
                          case 2:
                            _lottieController3.reset();
                            _lottieController3.forward();
                            break;
                        }
                      }
                    },
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(
                        slides[index]['title'],
                        slides[index]['subtitle'],
                        index,
                      );
                    },
                  ),
                ),
                
                // Navigation dots
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                ),
                
                // Get Started button (only on last page)
                if (_currentPage == slides.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E90FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          localizedContent['getStarted'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 96),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(String title, String subtitle, int index) {
    // Define Lottie animation URLs - using the user's requested URLs
    final List<String> lottieAnimations = [
      'https://assets9.lottiefiles.com/packages/lf20_5tl1xxnz.json', // Growth tracking - Rocket Launch
      'https://assets3.lottiefiles.com/packages/lf20_tutvdkg0.json', // Medical/vaccine
      'https://assets5.lottiefiles.com/packages/lf20_ysas4vcp.json', // Nutrition - Healthy or Junk Food
    ];

    // Get appropriate controller for the animation
    AnimationController controller;
    switch (index) {
      case 0:
        controller = _lottieController1;
        break;
      case 1:
        controller = _lottieController2;
        break;
      case 2:
        controller = _lottieController3;
        break;
      default:
        controller = _lottieController1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Animation with loading optimization
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E90FF).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Lottie animation
                  Lottie.network(
                    lottieAnimations[index],
                    controller: controller,
                    fit: BoxFit.contain,
                    animate: _currentPage == index && _animationLoadedStates[index] == true,
                    repeat: true,
                    options: LottieOptions(
                      enableMergePaths: true,
                    ),
                    onLoaded: (composition) {
                      // Mark animation as loaded
                      _onAnimationLoaded(index);
                      
                      // Start animation when loaded and if this is the current page
                      if (_currentPage == index) {
                        controller.duration = composition.duration;
                        controller.reset();
                        controller.forward();
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Mark as loaded even on error to hide loading
                      _onAnimationLoaded(index);
                      
                      // Fallback to icon if Lottie fails to load
                      return Center(
                        child: Icon(
                          index == 0
                              ? Icons.trending_up
                              : index == 1
                                  ? Icons.vaccines
                                  : Icons.restaurant,
                          size: 120,
                          color: const Color(0xFF1E90FF),
                        ),
                      );
                    },
                  ),
                  
                  // Loading placeholder - only show if this specific animation is not loaded
                  if (_animationLoadedStates[index] != true)
                    Container(
                      color: const Color(0xFF1E90FF).withValues(alpha: 0.05),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF1E90FF),
                              strokeWidth: 2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading animation...',
                              style: TextStyle(
                                color: const Color(0xFF1E90FF),
                                fontSize: 14,
                                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: _currentPage == index ? 24 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF1E90FF)
            : const Color(0xFF1E90FF).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}