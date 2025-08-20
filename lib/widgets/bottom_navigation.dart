import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/')) {
      if (location == '/') return 0;
      if (location.startsWith('/growth')) return 1;
      if (location.startsWith('/vaccines')) return 2;
      if (location.startsWith('/learn')) return 3;
      if (location.startsWith('/profile')) return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/growth');
        break;
      case 2:
        context.go('/vaccines');
        break;
      case 3:
        context.go('/learn');
        break;
      case 4:
        context.go('/profile');
        break;
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
    
    return Container(
      height: 56,
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
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0086FF),
        unselectedItemColor: const Color(0xFF666666),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.notoSerifSinhala(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSerifSinhala(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined, size: 24),
            activeIcon: const Icon(Icons.home, size: 24),
            label: labels['home'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up_outlined, size: 24),
            activeIcon: const Icon(Icons.trending_up, size: 24),
            label: labels['growth'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medical_services_outlined, size: 24),
            activeIcon: const Icon(Icons.medical_services, size: 24),
            label: labels['medicine'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined, size: 24),
            activeIcon: const Icon(Icons.menu_book, size: 24),
            label: labels['learn'],
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline, size: 24),
            activeIcon: const Icon(Icons.person, size: 24),
            label: labels['profile'],
          ),
        ],
      ),
    );
  }
}