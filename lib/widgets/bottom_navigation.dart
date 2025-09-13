import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/responsive_utils.dart';
import '../utils/navigation_manager.dart';

// Screen imports for reference (these screens are navigated to via GoRouter)
// Home (/) -> HomeScreen
// Growth (/growth) -> GrowthChartsScreen  
// Medicine (/vaccines) -> AddHealthRecordScreen
// Learn (/learn) -> LearnScreen
// Profile (/profile) -> ProfileScreen

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String? location = NavigationManager.getCurrentRoute(context);
    if (location != null && location.startsWith('/')) {
      if (location == '/') return 0;
      if (location.startsWith('/growth')) return 1;
      if (location.startsWith('/vaccines')) return 2;
      if (location.startsWith('/learn')) return 3;
      if (location.startsWith('/profile')) return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final routes = ['/', '/growth', '/vaccines', '/learn', '/profile'];
    if (index >= 0 && index < routes.length) {
      NavigationManager.safeNavigate(context, routes[index], replace: true);
    }
  }

  Map<String, String> _getLocalizedLabels() {
    final Map<String, Map<String, String>> labels = {
      'en': {
        'home': 'Home',
        'growth': 'Growth',
        'medicine': 'Medicine',
        'learn': 'Learn',
        'profile': 'Profile',
      },
      'si': {
        'home': 'මුල් පිටුව',
        'growth': 'වර්ධනය',
        'medicine': 'ඖෂධ',
        'learn': 'ඉගෙන ගන්න',
        'profile': 'පැතිකඩ',
      },
      'ta': {
        'home': 'முகப்பு',
        'growth': 'வளர்ச்சி',
        'medicine': 'மருந்து',
        'learn': 'கற்றல்',
        'profile': 'சுயவிவரம்',
      },
    };

    return labels[_selectedLanguage] ?? labels['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final labels = _getLocalizedLabels();
    final selectedIndex = _calculateSelectedIndex(context);
    
    // Responsive sizing
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context, 24);
    final fontSize = ResponsiveUtils.getResponsiveFontSize(context, 12);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0086FF),
          unselectedItemColor: const Color(0xFF666666),
          selectedFontSize: fontSize,
          unselectedFontSize: fontSize,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.notoSerifSinhala(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.notoSerifSinhala(
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: iconSize),
              activeIcon: Icon(Icons.home, size: iconSize),
              label: labels['home'],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_outlined, size: iconSize),
              activeIcon: Icon(Icons.trending_up, size: iconSize),
              label: labels['growth'],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined, size: iconSize),
              activeIcon: Icon(Icons.medical_services, size: iconSize),
              label: labels['medicine'],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined, size: iconSize),
              activeIcon: Icon(Icons.menu_book, size: iconSize),
              label: labels['learn'],
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: iconSize),
              activeIcon: Icon(Icons.person, size: iconSize),
              label: labels['profile'],
            ),
          ],
        ),
      ),
    );
  }
}