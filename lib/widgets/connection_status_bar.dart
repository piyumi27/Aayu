import 'package:flutter/material.dart';
import '../services/firebase_initialization_service.dart';

/// Status bar that shows connection and Firebase status
class ConnectionStatusBar extends StatelessWidget {
  const ConnectionStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseInitializationService();

    if (firebaseService.isInitialized) {
      // Don't show anything when Firebase is working normally
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Running in offline mode - all data saved locally',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (firebaseService.initializationFailed)
            TextButton(
              onPressed: () => _showOfflineModeInfo(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Learn More',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showOfflineModeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Offline Mode'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The app is currently running in offline mode. Here\'s what this means:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            _InfoItem(
              icon: Icons.check_circle,
              text: 'All your data is saved locally on your device',
              color: Colors.green,
            ),
            _InfoItem(
              icon: Icons.check_circle,
              text: 'Growth tracking and measurements work normally',
              color: Colors.green,
            ),
            _InfoItem(
              icon: Icons.check_circle,
              text: 'Vaccination schedules and milestones are available',
              color: Colors.green,
            ),
            _InfoItem(
              icon: Icons.info,
              text: 'Cloud sync and backup are temporarily unavailable',
              color: Colors.orange,
            ),
            _InfoItem(
              icon: Icons.info,
              text: 'Push notifications may be limited',
              color: Colors.orange,
            ),
            SizedBox(height: 12),
            Text(
              'When you have a stable internet connection, the app will automatically sync your data to the cloud.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
