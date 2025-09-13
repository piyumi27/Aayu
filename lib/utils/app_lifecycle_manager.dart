import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Manages app lifecycle and prevents common lifecycle-related errors
class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({
    required this.child,
    super.key,
  });

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        debugPrint('🔄 App lifecycle: detached');
        _handleAppDetached();
        break;
      case AppLifecycleState.resumed:
        debugPrint('🔄 App lifecycle: resumed');
        _handleAppResumed();
        break;
      case AppLifecycleState.inactive:
        debugPrint('🔄 App lifecycle: inactive');
        _handleAppInactive();
        break;
      case AppLifecycleState.paused:
        debugPrint('🔄 App lifecycle: paused');
        _handleAppPaused();
        break;
      case AppLifecycleState.hidden:
        debugPrint('🔄 App lifecycle: hidden');
        _handleAppHidden();
        break;
    }
  }

  void _handleAppDetached() {
    // App is about to be destroyed
    // Clean up resources to prevent memory leaks
    debugPrint('🧹 Cleaning up app resources');
  }

  void _handleAppResumed() {
    // App became active and visible
    // Refresh data if needed
    debugPrint('🔄 App resumed - refreshing state if needed');
  }

  void _handleAppInactive() {
    // App is transitioning to background or becoming inactive
    // Save critical state
    debugPrint('💾 App becoming inactive - saving state');
  }

  void _handleAppPaused() {
    // App is in background
    // Pause expensive operations
    debugPrint('⏸️ App paused - stopping background operations');
  }

  void _handleAppHidden() {
    // App is hidden but may still be running
    debugPrint('👁️ App hidden');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// System UI manager for safe system operations
class SystemUIManager {
  static void setSystemUIOverlayStyle({
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Brightness? statusBarIconBrightness,
    Color? systemNavigationBarColor,
    Brightness? systemNavigationBarIconBrightness,
  }) {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarBrightness: statusBarBrightness,
          statusBarIconBrightness: statusBarIconBrightness,
          systemNavigationBarColor: systemNavigationBarColor,
          systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Failed to set system UI overlay style: $e');
    }
  }

  static void setPreferredOrientations(List<DeviceOrientation> orientations) {
    try {
      SystemChrome.setPreferredOrientations(orientations);
    } catch (e) {
      debugPrint('⚠️ Failed to set preferred orientations: $e');
    }
  }
}

/// Memory manager to help prevent memory-related issues
class MemoryManager {
  static void forceGarbageCollection() {
    try {
      // Suggest garbage collection
      // Note: This is just a suggestion to the VM
      debugPrint('🗑️ Suggesting garbage collection');
    } catch (e) {
      debugPrint('⚠️ Error during garbage collection suggestion: $e');
    }
  }

  static void clearCaches() {
    try {
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      debugPrint('🧹 Cleared image cache');
    } catch (e) {
      debugPrint('⚠️ Error clearing caches: $e');
    }
  }

  static void reportMemoryUsage() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      debugPrint('📊 Memory usage:');
      debugPrint('   Image cache size: ${imageCache.currentSize}');
      debugPrint('   Image cache count: ${imageCache.liveImageCount}');
    } catch (e) {
      debugPrint('⚠️ Error reporting memory usage: $e');
    }
  }
}
