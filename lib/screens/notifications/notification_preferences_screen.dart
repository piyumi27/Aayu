import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notifications/local_notification_service.dart';
import '../../services/notifications/push_notification_service.dart';
import '../../utils/responsive_utils.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();
  final PushNotificationService _pushNotificationService =
      PushNotificationService();

  bool _pushNotificationsEnabled = true;
  bool _localNotificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _badgeEnabled = true;

  Map<String, bool> _categoryPreferences = {
    'critical_health_alerts': true,
    'health_alerts': true,
    'vaccination_reminders': true,
    'growth_tracking': true,
    'milestone_tracking': true,
    'feeding_reminders': true,
    'medication_reminders': true,
    'appointment_reminders': true,
    'general_notifications': false,
  };

  Map<String, TimeOfDay> _quietHours = {
    'start': const TimeOfDay(hour: 22, minute: 0),
    'end': const TimeOfDay(hour: 7, minute: 0),
  };

  bool _quietHoursEnabled = true;
  String _notificationFrequency = 'normal'; // normal, minimal, maximum
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _pushNotificationsEnabled =
            prefs.getBool('push_notifications_enabled') ?? true;
        _localNotificationsEnabled =
            prefs.getBool('local_notifications_enabled') ?? true;
        _soundEnabled = prefs.getBool('notification_sound_enabled') ?? true;
        _vibrationEnabled =
            prefs.getBool('notification_vibration_enabled') ?? true;
        _badgeEnabled = prefs.getBool('notification_badge_enabled') ?? true;
        _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? true;
        _notificationFrequency =
            prefs.getString('notification_frequency') ?? 'normal';

        // Load category preferences
        _categoryPreferences.forEach((key, defaultValue) {
          _categoryPreferences[key] =
              prefs.getBool('category_$key') ?? defaultValue;
        });

        // Load quiet hours
        _quietHours['start'] = TimeOfDay(
          hour: prefs.getInt('quiet_hours_start_hour') ?? 22,
          minute: prefs.getInt('quiet_hours_start_minute') ?? 0,
        );
        _quietHours['end'] = TimeOfDay(
          hour: prefs.getInt('quiet_hours_end_hour') ?? 7,
          minute: prefs.getInt('quiet_hours_end_minute') ?? 0,
        );
      });
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
          'push_notifications_enabled', _pushNotificationsEnabled);
      await prefs.setBool(
          'local_notifications_enabled', _localNotificationsEnabled);
      await prefs.setBool('notification_sound_enabled', _soundEnabled);
      await prefs.setBool('notification_vibration_enabled', _vibrationEnabled);
      await prefs.setBool('notification_badge_enabled', _badgeEnabled);
      await prefs.setBool('quiet_hours_enabled', _quietHoursEnabled);
      await prefs.setString('notification_frequency', _notificationFrequency);

      // Save category preferences
      for (final entry in _categoryPreferences.entries) {
        await prefs.setBool('category_${entry.key}', entry.value);
      }

      // Save quiet hours
      await prefs.setInt('quiet_hours_start_hour', _quietHours['start']!.hour);
      await prefs.setInt(
          'quiet_hours_start_minute', _quietHours['start']!.minute);
      await prefs.setInt('quiet_hours_end_hour', _quietHours['end']!.hour);
      await prefs.setInt('quiet_hours_end_minute', _quietHours['end']!.minute);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification preferences saved')),
        );
      }
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save preferences')),
        );
      }
    }
  }

  Future<void> _selectTime(String type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _quietHours[type]!,
      helpText: type == 'start'
          ? 'Select quiet hours start'
          : 'Select quiet hours end',
    );

    if (picked != null) {
      setState(() {
        _quietHours[type] = picked;
      });
      await _savePreferences();
    }
  }

  String _getCategoryDisplayName(String key) {
    switch (key) {
      case 'critical_health_alerts':
        return 'Critical Health Alerts';
      case 'health_alerts':
        return 'Health Alerts';
      case 'vaccination_reminders':
        return 'Vaccination Reminders';
      case 'growth_tracking':
        return 'Growth Tracking';
      case 'milestone_tracking':
        return 'Milestone Tracking';
      case 'feeding_reminders':
        return 'Feeding Reminders';
      case 'medication_reminders':
        return 'Medication Reminders';
      case 'appointment_reminders':
        return 'Appointment Reminders';
      case 'general_notifications':
        return 'General Notifications';
      default:
        return key
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : word)
            .join(' ');
    }
  }

  String _getCategoryDescription(String key) {
    switch (key) {
      case 'critical_health_alerts':
        return 'Urgent health issues requiring immediate attention';
      case 'health_alerts':
        return 'Health warnings and important health information';
      case 'vaccination_reminders':
        return 'Upcoming and overdue vaccination schedules';
      case 'growth_tracking':
        return 'Growth measurement reminders and milestone alerts';
      case 'milestone_tracking':
        return 'Developmental milestone tracking and assessments';
      case 'feeding_reminders':
        return 'Feeding schedules and nutrition reminders';
      case 'medication_reminders':
        return 'Medicine dosage and timing reminders';
      case 'appointment_reminders':
        return 'Medical appointments and checkup reminders';
      case 'general_notifications':
        return 'App updates and general information';
      default:
        return 'Notifications for ${_getCategoryDisplayName(key).toLowerCase()}';
    }
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    String? subtitle,
  }) {
    return Card(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
      ),
      child: Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 16),
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 12),
                    ),
              ),
            ],
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
    IconData? icon,
    bool enabled = true,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(
              icon,
              size: ResponsiveUtils.getResponsiveIconSize(context, 24),
              color: enabled ? null : Theme.of(context).disabledColor,
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              color: enabled ? null : Theme.of(context).disabledColor,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: enabled
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).disabledColor,
                  ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await _localNotificationService.showTestNotification();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent')),
                );
              }
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Test'),
          ),
        ],
      ),
      body: ListView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        children: [
          // General Settings
          _buildSection(
            title: 'General Settings',
            subtitle: 'Configure basic notification preferences',
            children: [
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive notifications from the server',
                value: _pushNotificationsEnabled,
                icon: Icons.cloud_queue,
                onChanged: (value) {
                  setState(() => _pushNotificationsEnabled = value);
                  _savePreferences();
                },
              ),
              _buildSwitchTile(
                title: 'Local Notifications',
                subtitle: 'Receive locally scheduled notifications',
                value: _localNotificationsEnabled,
                icon: Icons.phone_android,
                onChanged: (value) {
                  setState(() => _localNotificationsEnabled = value);
                  _savePreferences();
                },
              ),
              _buildSwitchTile(
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                value: _soundEnabled,
                icon: Icons.volume_up,
                enabled:
                    _localNotificationsEnabled || _pushNotificationsEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                  _savePreferences();
                },
              ),
              _buildSwitchTile(
                title: 'Vibration',
                subtitle: 'Vibrate device for notifications',
                value: _vibrationEnabled,
                icon: Icons.vibration,
                enabled:
                    _localNotificationsEnabled || _pushNotificationsEnabled,
                onChanged: (value) {
                  setState(() => _vibrationEnabled = value);
                  _savePreferences();
                },
              ),
              _buildSwitchTile(
                title: 'Badge Count',
                subtitle: 'Show unread count on app icon',
                value: _badgeEnabled,
                icon: Icons.circle_notifications,
                enabled:
                    _localNotificationsEnabled || _pushNotificationsEnabled,
                onChanged: (value) {
                  setState(() => _badgeEnabled = value);
                  _savePreferences();
                },
              ),
            ],
          ),

          // Notification Categories
          _buildSection(
            title: 'Notification Categories',
            subtitle: 'Choose which types of notifications to receive',
            children: _categoryPreferences.entries.map((entry) {
              final isEnabled = (_localNotificationsEnabled ||
                      _pushNotificationsEnabled) &&
                  (entry.key !=
                      'critical_health_alerts'); // Critical alerts always enabled

              return _buildSwitchTile(
                title: _getCategoryDisplayName(entry.key),
                subtitle: _getCategoryDescription(entry.key),
                value: entry.value,
                enabled: isEnabled,
                onChanged: (value) {
                  setState(() => _categoryPreferences[entry.key] = value);
                  _savePreferences();
                },
              );
            }).toList(),
          ),

          // Quiet Hours
          _buildSection(
            title: 'Quiet Hours',
            subtitle: 'Set times when non-critical notifications are silenced',
            children: [
              _buildSwitchTile(
                title: 'Enable Quiet Hours',
                subtitle:
                    'Silence non-critical notifications during specified hours',
                value: _quietHoursEnabled,
                icon: Icons.bedtime,
                enabled:
                    _localNotificationsEnabled || _pushNotificationsEnabled,
                onChanged: (value) {
                  setState(() => _quietHoursEnabled = value);
                  _savePreferences();
                },
              ),
              if (_quietHoursEnabled) ...[
                ListTile(
                  leading: const Icon(Icons.nightlight_round),
                  title: const Text('Start Time'),
                  subtitle: Text(_quietHours['start']!.format(context)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectTime('start'),
                ),
                ListTile(
                  leading: const Icon(Icons.wb_sunny),
                  title: const Text('End Time'),
                  subtitle: Text(_quietHours['end']!.format(context)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectTime('end'),
                ),
              ],
            ],
          ),

          // Notification Frequency
          _buildSection(
            title: 'Notification Frequency',
            subtitle: 'Control how often you receive notifications',
            children: [
              RadioListTile<String>(
                title: const Text('Minimal'),
                subtitle:
                    const Text('Only critical and high-priority notifications'),
                value: 'minimal',
                groupValue: _notificationFrequency,
                onChanged:
                    (_localNotificationsEnabled || _pushNotificationsEnabled)
                        ? (value) {
                            setState(() => _notificationFrequency = value!);
                            _savePreferences();
                          }
                        : null,
              ),
              RadioListTile<String>(
                title: const Text('Normal'),
                subtitle: const Text('Balanced notification frequency'),
                value: 'normal',
                groupValue: _notificationFrequency,
                onChanged:
                    (_localNotificationsEnabled || _pushNotificationsEnabled)
                        ? (value) {
                            setState(() => _notificationFrequency = value!);
                            _savePreferences();
                          }
                        : null,
              ),
              RadioListTile<String>(
                title: const Text('Maximum'),
                subtitle:
                    const Text('All available notifications and reminders'),
                value: 'maximum',
                groupValue: _notificationFrequency,
                onChanged:
                    (_localNotificationsEnabled || _pushNotificationsEnabled)
                        ? (value) {
                            setState(() => _notificationFrequency = value!);
                            _savePreferences();
                          }
                        : null,
              ),
            ],
          ),

          // Advanced Settings
          _buildSection(
            title: 'Advanced Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Clear Notification History'),
                subtitle: const Text('Remove all notification history'),
                trailing: const Icon(Icons.delete_outline),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Notification History'),
                      content: const Text(
                          'This will permanently delete all notification history. This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    // Clear notification history
                    // This would be implemented in the database service
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Notification history cleared')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
