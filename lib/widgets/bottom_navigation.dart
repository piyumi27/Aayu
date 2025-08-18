import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

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

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _calculateSelectedIndex(context),
      onDestinationSelected: (index) => _onItemTapped(index, context),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.trending_up_outlined),
          selectedIcon: Icon(Icons.trending_up),
          label: 'Growth',
        ),
        NavigationDestination(
          icon: Icon(Icons.vaccines_outlined),
          selectedIcon: Icon(Icons.vaccines),
          label: 'Vaccines',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Learn',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}