import 'package:flutter/material.dart';

/// Responsive design utilities for consistent cross-device layouts
class ResponsiveUtils {
  /// Screen breakpoints
  static const double mobileBreakpoint = 428;
  static const double tabletBreakpoint = 834;
  static const double desktopBreakpoint = 1194;
  
  /// Get current screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return ScreenType.desktop;
    if (width >= tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.mobile;
  }
  
  /// Check if screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }
  
  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }
  
  /// Check if screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16);
      case ScreenType.tablet:
        return const EdgeInsets.all(24);
      case ScreenType.desktop:
        return const EdgeInsets.all(32);
    }
  }
  
  /// Get responsive margin based on screen size
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(8);
      case ScreenType.tablet:
        return const EdgeInsets.all(12);
      case ScreenType.desktop:
        return const EdgeInsets.all(16);
    }
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseFontSize;
      case ScreenType.tablet:
        return baseFontSize * 1.1;
      case ScreenType.desktop:
        return baseFontSize * 1.2;
    }
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseIconSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseIconSize;
      case ScreenType.tablet:
        return baseIconSize * 1.2;
      case ScreenType.desktop:
        return baseIconSize * 1.4;
    }
  }
  
  /// Get responsive card elevation
  static double getResponsiveElevation(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 2.0;
      case ScreenType.tablet:
        return 4.0;
      case ScreenType.desktop:
        return 6.0;
    }
  }
  
  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 8.0;
      case ScreenType.tablet:
        return 12.0;
      case ScreenType.desktop:
        return 16.0;
    }
  }
  
  /// Get responsive column count for grid layouts
  static int getResponsiveColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return 4;
    if (width >= tabletBreakpoint) return 3;
    if (width >= 500) return 2;
    return 2; // Minimum 2 columns even on small screens
  }
  
  /// Get responsive aspect ratio
  static double getResponsiveAspectRatio(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return 16 / 9;
      case ScreenType.tablet:
        return 4 / 3;
      case ScreenType.desktop:
        return 16 / 10;
    }
  }
  
  /// Get responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return const BoxConstraints(
          minHeight: 48,
          maxWidth: double.infinity,
        );
      case ScreenType.tablet:
        return const BoxConstraints(
          minHeight: 56,
          maxWidth: 600,
        );
      case ScreenType.desktop:
        return const BoxConstraints(
          minHeight: 64,
          maxWidth: 800,
        );
    }
  }
  
  /// Get responsive content width
  static double getResponsiveContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return screenWidth;
      case ScreenType.tablet:
        return screenWidth * 0.85;
      case ScreenType.desktop:
        return screenWidth * 0.7;
    }
  }
  
  /// Get responsive safe area padding
  static EdgeInsets getResponsiveSafeAreaPadding(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;
    final basePadding = getResponsivePadding(context);
    
    return EdgeInsets.only(
      top: safePadding.top + basePadding.top,
      bottom: safePadding.bottom + basePadding.bottom,
      left: safePadding.left + basePadding.left,
      right: safePadding.right + basePadding.right,
    );
  }
  
  /// Check if screen has small width (for compact layouts)
  static bool isSmallWidth(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  /// Check if screen has small height (for compact layouts)
  static bool isSmallHeight(BuildContext context) {
    return MediaQuery.of(context).size.height < 640;
  }
  
  /// Get text scaling factor that respects user preferences
  static double getResponsiveTextScale(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    // Clamp text scale factor to prevent extreme scaling
    return textScaler.scale(1.0).clamp(0.8, 1.3);
  }
}

/// Screen type enumeration
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

/// Responsive widget builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
    this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return mobile ?? builder(context, screenType);
      case ScreenType.tablet:
        return tablet ?? builder(context, screenType);
      case ScreenType.desktop:
        return desktop ?? builder(context, screenType);
    }
  }
}

/// Responsive layout wrapper
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BoxConstraints? constraints;
  final bool useSafeArea;
  
  const ResponsiveLayout({
    super.key,
    required this.child,
    this.padding,
    this.constraints,
    this.useSafeArea = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveConstraints = constraints ?? ResponsiveUtils.getResponsiveConstraints(context);
    
    Widget content = Container(
      padding: responsivePadding,
      constraints: responsiveConstraints,
      child: child,
    );
    
    if (useSafeArea) {
      content = SafeArea(child: content);
    }
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.getResponsiveContentWidth(context),
        ),
        child: content,
      ),
    );
  }
}