import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/child_provider.dart';
import 'services/local_auth_service.dart';
import 'screens/about_aayu_screen.dart';
import 'screens/add_child_screen.dart';
import 'screens/add_health_record_screen.dart';
import 'screens/edit_child_profile_screen.dart';
import 'screens/edit_parent_profile_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/growth_charts_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/login_screen.dart';
import 'screens/measurement_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/pre_six_month_countdown_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/verification_center_screen.dart';
import 'screens/progress_tracking_screen.dart';
import 'screens/achievements_screen.dart';
import 'services/firebase_sync_service.dart';
import 'widgets/bottom_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize WorkManager for background sync
  await FirebaseSyncService.initialize();
  
  runApp(const AayuApp());
}

class AayuApp extends StatelessWidget {
  const AayuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChildProvider()),
      ],
      child: MaterialApp.router(
        title: 'ආයු',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0086FF)),
          textTheme: GoogleFonts.notoSerifSinhalaTextTheme(
            Theme.of(context).textTheme,
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('si', 'LK'),
          Locale('ta', 'LK'),
        ],
        routerConfig: _router,
      ),
    );
  }
}

// Custom page transitions
class SlideRightTransitionPage extends CustomTransitionPage<void> {
  SlideRightTransitionPage({
    required LocalKey super.key,
    required super.child,
  }) : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/language-selection',
      builder: (context, state) => const LanguageSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! Map<String, dynamic>) {
          throw Exception('OTP Verification requires phoneNumber, verificationId, and fullName parameters');
        }
        return OTPVerificationScreen(
          phoneNumber: extra['phoneNumber'],
          verificationId: extra['verificationId'],
          fullName: extra['fullName'],
        );
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/verification-center',
      builder: (context, state) => const VerificationCenterScreen(),
    ),
    GoRoute(
      path: '/add-child',
      builder: (context, state) => const AddChildScreen(),
    ),
    GoRoute(
      path: '/pre-six-month-countdown',
      builder: (context, state) => const PreSixMonthCountdownScreen(),
    ),
    GoRoute(
      path: '/measurement-detail',
      builder: (context, state) {
        final extra = state.extra;
        if (extra == null || extra is! Map<String, dynamic>) {
          throw Exception('Measurement Detail requires measurementId and childId parameters');
        }
        return MeasurementDetailScreen(
          measurementId: extra['measurementId'],
          childId: extra['childId'],
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => SlideRightTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
          redirect: (context, state) async {
            // Use LocalAuthService to check authentication status
            final authService = LocalAuthService();
            final isLoggedIn = await authService.isLoggedIn();
            
            if (!isLoggedIn) {
              return '/login';
            }
            
            // If logged in, check if user needs verification
            // Note: Allow unverified users to access the app offline
            // They can access verification center through profile screen
            // Removed automatic redirect to verification center for unverified users
            
            return null;
          },
        ),
        GoRoute(
          path: '/growth',
          pageBuilder: (context, state) => SlideRightTransitionPage(
            key: state.pageKey,
            child: const GrowthChartsScreen(),
          ),
        ),
        GoRoute(
          path: '/vaccines',
          pageBuilder: (context, state) => SlideRightTransitionPage(
            key: state.pageKey,
            child: const AddHealthRecordScreen(),
          ),
        ),
        GoRoute(
          path: '/learn',
          pageBuilder: (context, state) => SlideRightTransitionPage(
            key: state.pageKey,
            child: const LearnScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => SlideRightTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => SlideRightTransitionPage(
            key: state.pageKey,
            child: const NotificationsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => SlideRightTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/edit-parent-profile',
      builder: (context, state) => const EditParentProfileScreen(),
    ),
    GoRoute(
      path: '/edit-child-profile',
      builder: (context, state) {
        final extra = state.extra;
        String? childId;
        if (extra != null && extra is Map<String, dynamic>) {
          childId = extra['childId'] as String?;
        }
        return EditChildProfileScreen(
          childId: childId,
        );
      },
    ),
    GoRoute(
      path: '/help-support',
      builder: (context, state) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: '/about-aayu',
      builder: (context, state) => const AboutAayuScreen(),
    ),
    GoRoute(
      path: '/verification-center',
      builder: (context, state) => const VerificationCenterScreen(),
    ),
    GoRoute(
      path: '/progress-tracking',
      builder: (context, state) => const ProgressTrackingScreen(),
    ),
    GoRoute(
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;
  
  const ScaffoldWithNavBar({
    required this.child,
    this.showBottomNav = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if we should show bottom navigation based on current route
    final String location = GoRouterState.of(context).uri.path;
    
    // List of routes that should show bottom navigation
    final showNavRoutes = [
      '/',  // Home Dashboard
      '/growth',  // Growth Charts
      '/vaccines',  // Vaccination Calendar (Medicine)
      '/learn',  // Learning Center
      '/profile',  // Profile/Settings
    ];
    
    final shouldShowNav = showNavRoutes.contains(location);
    
    return Scaffold(
      body: child,
      bottomNavigationBar: shouldShowNav ? const BottomNavigation() : null,
    );
  }
}