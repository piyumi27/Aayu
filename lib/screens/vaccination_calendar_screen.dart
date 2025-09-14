import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/child_provider.dart';
import '../models/notification.dart';
import '../services/vaccination_notification_service.dart';
import 'add_health_record_screen.dart';

/// Professional vaccination calendar screen with smooth scroll animations
class VaccinationCalendarScreen extends StatefulWidget {
  const VaccinationCalendarScreen({super.key});

  @override
  State<VaccinationCalendarScreen> createState() => _VaccinationCalendarScreenState();
}

class _VaccinationCalendarScreenState extends State<VaccinationCalendarScreen>
    with TickerProviderStateMixin {
  
  // Core calendar state
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // App state
  String _selectedLanguage = 'en';
  
  // Animation state
  late ScrollController _scrollController;
  late AnimationController _calendarAnimationController;
  late Animation<double> _calendarAnimation;
  
  // Constants
  static const double _maxScrollDistance = 200.0;
  static const Duration _animationDuration = Duration(milliseconds: 50);
  
  // Sample vaccine events
  final Map<DateTime, List<VaccineEvent>> _events = {};

  // Vaccination notification service
  final VaccinationNotificationService _notificationService = VaccinationNotificationService();

  @override
  void initState() {
    super.initState();
    _initializeState();
    _initializeAnimations();

    // Load events after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVaccineEvents();
      _initializeNotificationService();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _calendarAnimationController.dispose();
    super.dispose();
  }

  /// Initialize app state
  void _initializeState() {
    _selectedDay = DateTime.now();
    _loadLanguage();
  }

  /// Initialize smooth scroll animations
  void _initializeAnimations() {
    _scrollController = ScrollController()..addListener(_onScroll);
    
    _calendarAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
      value: 0.0, // Start fully visible
    );
    
    _calendarAnimation = Tween<double>(
      begin: 0.0, // Fully visible
      end: 1.0,   // Fully hidden
    ).animate(CurvedAnimation(
      parent: _calendarAnimationController,
      curve: Curves.linear, // Smooth linear animation
    ));
  }

  /// Load user language preference
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('selected_language') ?? 'en';
      });
    }
  }

  /// Initialize vaccination notification service
  Future<void> _initializeNotificationService() async {
    try {
      await _notificationService.initialize();
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('Failed to initialize notification service: $e');
    }
  }

  /// Load sample vaccine events
  void _loadVaccineEvents() {
    final provider = context.read<ChildProvider>();
    final selectedChild = provider.selectedChild;

    if (selectedChild == null) return;

    // Clear existing events
    _events.clear();

    // Get vaccines from database and child age
    final vaccines = provider.vaccines;
    final childAge = provider.calculateAgeInMonths(selectedChild.birthDate);
    final vaccineRecords = provider.vaccineRecords;
    final givenVaccineIds = vaccineRecords.map((r) => r.vaccineId).toSet();

    // Filter vaccines to show only mandatory ones and relevant age range (birth to 5 years)
    final relevantVaccines = vaccines.where((vaccine) =>
      vaccine.isMandatory && vaccine.recommendedAgeMonths <= 60
    ).toList();

    for (final vaccine in relevantVaccines) {
      // Calculate the target date for the vaccine based on recommended age
      final targetDate = _calculateVaccineDate(selectedChild.birthDate, vaccine.recommendedAgeMonths);

      // Only show events within reasonable range (past 2 years to future 1 year)
      final now = DateTime.now();
      if (targetDate.isBefore(now.subtract(const Duration(days: 730))) ||
          targetDate.isAfter(now.add(const Duration(days: 365)))) {
        continue;
      }

      // Determine status based on current age and given vaccines
      VaccineStatus status;

      if (givenVaccineIds.contains(vaccine.id)) {
        status = VaccineStatus.completed;
      } else if (vaccine.recommendedAgeMonths < childAge - 1) {
        status = VaccineStatus.overdue;
      } else if (vaccine.recommendedAgeMonths <= childAge + 1) {
        status = VaccineStatus.scheduled;
      } else {
        status = VaccineStatus.scheduled;
      }

      final event = VaccineEvent(vaccine.name, status, targetDate);

      // Group events by date
      final dateKey = DateTime(targetDate.year, targetDate.month, targetDate.day);
      if (_events[dateKey] == null) {
        _events[dateKey] = [];
      }
      _events[dateKey]!.add(event);
    }

    // Notify listeners to rebuild calendar
    if (mounted) {
      setState(() {});
    }
  }

  /// Calculate the target date for a vaccine based on child's birth date and vaccine age
  DateTime _calculateVaccineDate(DateTime birthDate, int ageInMonths) {
    if (ageInMonths == 0) {
      return birthDate; // Birth vaccines
    }

    // Add months to birth date
    DateTime targetDate = DateTime(
      birthDate.year,
      birthDate.month + ageInMonths,
      birthDate.day,
    );

    // Handle month overflow
    while (targetDate.month > 12) {
      targetDate = DateTime(targetDate.year + 1, targetDate.month - 12, targetDate.day);
    }

    return targetDate;
  }

  /// Smooth scroll-based animation handler
  void _onScroll() {
    final offset = _scrollController.offset.clamp(0.0, _maxScrollDistance);
    final animationValue = offset / _maxScrollDistance;
    
    _calendarAnimationController.animateTo(
      animationValue,
      duration: _animationDuration,
      curve: Curves.linear,
    );
  }


  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedTexts();
    final provider = Provider.of<ChildProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(texts),
          if (provider.children.length > 1) _buildChildSelector(provider, texts),
          _buildAnimatedCalendar(texts),
          _buildLegend(texts),
          _buildUnifiedVaccinationsHeader(provider, texts),
        ],
        body: _buildUnifiedVaccinesList(provider, texts),
      ),
      floatingActionButton: _buildFAB(texts),
    );
  }

  /// Build unified vaccinations header with reminders and schedule
  Widget _buildUnifiedVaccinationsHeader(ChildProvider provider, Map<String, String> texts) {
    if (provider.selectedChild == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: FutureBuilder<List<dynamic>>(
        future: _getVaccinationReminders(provider.selectedChild!),
        builder: (context, snapshot) {
          final reminders = snapshot.hasData ? snapshot.data! : <dynamic>[];
          final upcomingVaccines = _getUpcomingVaccines();
          final totalCount = reminders.length + upcomingVaccines.length;

          return Container(
            color: const Color(0xFFF8F9FA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unified header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.vaccines_outlined,
                        color: const Color(0xFF0086FF),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vaccinations',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      if (totalCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0086FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            totalCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Reminders section (if any)
                if (reminders.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Action Required',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEF4444),
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reminders.length.toString(),
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...reminders.map((reminder) => _buildVaccinationReminderCard(reminder, texts)),
                ],
                // Upcoming vaccines section (if any)
                if (upcomingVaccines.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, reminders.isNotEmpty ? 16 : 8, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0086FF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Upcoming Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0086FF),
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            upcomingVaccines.length.toString(),
                            style: const TextStyle(
                              color: Color(0xFF0086FF),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build upcoming vaccination reminders section (deprecated - kept for reference)
  Widget _buildUpcomingRemindersSection(ChildProvider provider, Map<String, String> texts) {
    if (provider.selectedChild == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: FutureBuilder<List<dynamic>>(
        future: _getVaccinationReminders(provider.selectedChild!),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final reminders = snapshot.data!;

          return Container(
            color: const Color(0xFFF8F9FA),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: const Color(0xFF0086FF),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vaccination Reminders',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      if (reminders.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0086FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reminders.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ...reminders.map((reminder) => _buildVaccinationReminderCard(reminder, texts)),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build vaccination reminder card using existing vaccine card styling
  Widget _buildVaccinationReminderCard(dynamic reminder, Map<String, String> texts) {
    // Map notification priority to vaccine status for consistent styling
    final NotificationPriority priority = reminder.priority as NotificationPriority;
    final VaccineStatus status = switch (priority) {
      NotificationPriority.critical => VaccineStatus.overdue,
      NotificationPriority.high => VaccineStatus.overdue,
      NotificationPriority.medium => VaccineStatus.scheduled,
      NotificationPriority.low => VaccineStatus.scheduled,
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: status.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    status.icon,
                    color: status.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.vaccineName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: status.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getPriorityText(priority),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status.color,
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToAddRecord(reminder),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0086FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                      icon: const Icon(Icons.add_outlined, size: 18),
                      label: const Text(
                        'Add Health Record',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDismissDialog(reminder),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6B7280)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(0, 44),
                      ),
                      icon: const Icon(Icons.schedule_outlined, size: 18),
                      label: const Text(
                        'Remind Later',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get vaccination reminders for the selected child
  Future<List<dynamic>> _getVaccinationReminders(dynamic child) async {
    try {
      await _notificationService.generateNotificationsForChild(child);
      return await _notificationService.getActiveNotifications(child.id);
    } catch (e) {
      debugPrint('Error loading vaccination reminders: $e');
      return [];
    }
  }

  /// Navigate to add health record screen with pre-filled information
  void _navigateToAddRecord(dynamic reminder) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHealthRecordScreen(
          initialRecordType: HealthRecordType.vaccine,
          preselectedVaccineName: reminder.vaccineName,
          preselectedVaccineId: reminder.vaccineId,
        ),
      ),
    );

    if (result == true && mounted) {
      // Mark notification as completed and refresh
      await _notificationService.completeNotification(
        reminder.vaccineId,
        reminder.childId,
      );
      setState(() {}); // Refresh the reminders

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reminder.vaccineName} health record added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Show dismissal dialog
  void _showDismissDialog(dynamic reminder) {
    final reasons = [
      'Vaccine already given at clinic',
      'Postponed due to illness',
      'Doctor advised to wait',
      'Child refused vaccination',
      'Vaccine not available',
      'Other reason',
    ];

    String selectedReason = reasons.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Dismiss Reminder'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Why are you dismissing this vaccination reminder for ${reminder.vaccineName}?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedReason,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: reasons.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(
                          reason,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedReason = value;
                        });
                      }
                    },
                    isExpanded: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _notificationService.dismissNotification(
                  reminder.id,
                  selectedReason,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  this.setState(() {}); // Refresh the reminders
                }
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get priority text for display
  String _getPriorityText(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.critical:
        return 'Seriously Overdue';
      case NotificationPriority.high:
        return 'Overdue';
      case NotificationPriority.medium:
        return 'Due Soon';
      case NotificationPriority.low:
        return 'Upcoming';
    }
  }

  /// Build app bar with notification button
  Widget _buildAppBar(Map<String, String> texts) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      title: Text(
        texts['title']!,
        style: TextStyle(
          color: const Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
          onPressed: () {},
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
      ),
    );
  }

  /// Build child selector
  Widget _buildChildSelector(ChildProvider provider, Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: provider.selectedChild?.id,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
            items: provider.children.map((child) => DropdownMenuItem<String>(
              value: child.id,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF0086FF).withValues(alpha: 0.1),
                    backgroundImage: child.photoUrl != null && child.photoUrl!.isNotEmpty
                        ? (child.photoUrl!.startsWith('http')
                            ? NetworkImage(child.photoUrl!) as ImageProvider
                            : FileImage(File(child.photoUrl!)))
                        : null,
                    child: child.photoUrl == null || child.photoUrl!.isEmpty
                        ? Text(
                            child.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF0086FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        child.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      Text(
                        provider.getAgeString(child.birthDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )).toList(),
            onChanged: (String? childId) {
              if (childId != null) {
                final child = provider.children.firstWhere((c) => c.id == childId);
                provider.selectChild(child);
              }
            },
          ),
        ),
      ),
    );
  }

  /// Build animated table calendar
  Widget _buildAnimatedCalendar(Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _calendarAnimation,
          builder: (context, child) {
            final animValue = _calendarAnimation.value;
            final scale = 1.0 - (animValue * 0.3);
            final opacity = 1.0 - (animValue * 0.7);
            final height = _calculateCalendarHeight(animValue);
            
            return Container(
              height: height,
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 415.0, // Fixed height for calendar with additional buffer
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: child!,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          child: _buildTableCalendar(texts),
        ),
      ),
    );
  }

  /// Build professional table calendar
  Widget _buildTableCalendar(Map<String, String> texts) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 14.0), // Extra bottom padding
        child: TableCalendar<VaccineEvent>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month, // Fixed format to prevent dynamic sizing
          eventLoader: (day) => _events[day] ?? [],
          startingDayOfWeek: StartingDayOfWeek.sunday,
          sixWeekMonthsEnforced: false, // Allow flexible week count
          availableGestures: AvailableGestures.all,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            weekendTextStyle: const TextStyle(color: Color(0xFF6B7280)),
            holidayTextStyle: const TextStyle(color: Color(0xFF0086FF)),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF0086FF),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: const Color(0xFF0086FF).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            canMarkersOverflow: false,
            cellMargin: const EdgeInsets.all(3.0), // Reduced margin to save space
            cellPadding: const EdgeInsets.all(1.5), // Reduced padding to save space
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            leftChevronIcon: const Icon(
              Icons.chevron_left,
              color: Color(0xFF6B7280),
            ),
            rightChevronIcon: const Icon(
              Icons.chevron_right,
              color: Color(0xFF6B7280),
            ),
            headerPadding: const EdgeInsets.symmetric(vertical: 6.0), // Further reduced header padding
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            
            final events = _events[selectedDay];
            if (events != null && events.isNotEmpty) {
              _showDayEventsSheet(selectedDay, events, texts);
            }
          },
          onFormatChanged: (format) {
            // Format changed - no state needed
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
      ),
    );
  }

  /// Build legend
  Widget _buildLegend(Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _calendarAnimation,
          builder: (context, child) {
            final opacity = 1.0 - _calendarAnimation.value;
            return opacity > 0.1
                ? Opacity(opacity: opacity, child: child!)
                : const SizedBox.shrink();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFF0086FF), texts['scheduled']!),
                const SizedBox(width: 24),
                _buildLegendItem(const Color(0xFFEF4444), texts['overdue']!),
                const SizedBox(width: 24),
                _buildLegendItem(const Color(0xFF10B981), texts['completed']!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build legend item
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF6B7280),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
      ],
    );
  }

  /// Build vaccines section header
  Widget _buildVaccinesHeader(Map<String, String> texts) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        color: const Color(0xFFF8F9FA),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              texts['upcomingVaccines']!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                texts['viewAll']!,
                style: TextStyle(
                  color: const Color(0xFF0086FF),
                  fontWeight: FontWeight.w600,
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build vaccines list
  /// Build unified vaccines list showing upcoming vaccines as cards
  Widget _buildUnifiedVaccinesList(ChildProvider provider, Map<String, String> texts) {
    final upcomingVaccines = _getUpcomingVaccines();

    if (upcomingVaccines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            Text(
              'All vaccinations up to date!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No upcoming vaccination schedule at this time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 16,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: upcomingVaccines.length,
      itemBuilder: (context, index) => _buildVaccineCard(upcomingVaccines[index], texts),
    );
  }

  /// Build vaccines list (deprecated - kept for compatibility)
  Widget _buildVaccinesList(ChildProvider provider, Map<String, String> texts) {
    return _buildUnifiedVaccinesList(provider, texts);
  }

  /// Build vaccine card
  Widget _buildVaccineCard(Map<String, dynamic> vaccine, Map<String, String> texts) {
    final status = VaccineStatus.values.firstWhere(
      (s) => s.name == vaccine['status'],
      orElse: () => VaccineStatus.scheduled,
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: status.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    status.icon,
                    color: status.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccine['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: status.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          texts[vaccine['status']]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status.color,
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.calendar_today, texts['dueOn']!, vaccine['date']),
                  if (vaccine['clinic'] != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.location_on_outlined, 'Clinic', vaccine['clinic']),
                  ],
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.access_time, 'Time', '2:30 PM'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.person, 'Doctor', 'Dr. Sarah Johnson'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: status.getActionButtons(texts, () {}),
            ),
          ],
        ),
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF6B7280),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
      ],
    );
  }


  /// Build floating action button
  Widget _buildFAB(Map<String, String> texts) {
    return FloatingActionButton(
      onPressed: () => _navigateToAddHealthRecord(),
      backgroundColor: const Color(0xFF0086FF),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  /// Calculate calendar height based on animation value
  double _calculateCalendarHeight(double animValue) {
    // Adjusted heights to accommodate table_calendar's internal layout with buffer for overflow
    const double totalHeight = 415.0; // Additional 5px buffer to prevent 2px overflow
    const double minHeight = 90.0;    // Increased minimum height for better collapsed state
    return totalHeight - ((totalHeight - minHeight) * animValue);
  }

  /// Show day events bottom sheet
  void _showDayEventsSheet(DateTime day, List<VaccineEvent> events, Map<String, String> texts) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${day.day}/${day.month}/${day.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...events.map((event) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: event.status.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(event.status.icon, color: event.status.color, size: 20),
              ),
              title: Text(event.name),
              subtitle: Text(texts[event.status.name] ?? event.status.name),
              trailing: TextButton(
                onPressed: () {},
                child: Text(
                  texts['details']!,
                  style: const TextStyle(color: Color(0xFF0086FF)),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Navigate to Add Health Record screen
  void _navigateToAddHealthRecord() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddHealthRecordScreen(),
      ),
    );
  }

  /// Get upcoming vaccines data
  List<Map<String, dynamic>> _getUpcomingVaccines() {
    return [
      {
        'name': 'MMR (Measles, Mumps, Rubella)',
        'date': 'Aug 20, 2023',
        'status': 'overdue',
        'clinic': 'Sunshine Pediatrics',
      },
      {
        'name': 'DTaP (5th dose)',
        'date': 'Aug 25, 2023',
        'status': 'scheduled',
        'clinic': 'Sunshine Pediatrics',
      },
      {
        'name': 'Hepatitis A (2nd dose)',
        'date': 'Sep 15, 2023',
        'status': 'scheduled',
        'clinic': 'Sunshine Pediatrics',
      },
    ];
  }

  /// Get localized texts
  Map<String, String> _getLocalizedTexts() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Vaccination Calendar',
        'upcomingVaccines': 'Upcoming Vaccines',
        'viewAll': 'View All',
        'overdue': 'Overdue',
        'scheduled': 'Scheduled',
        'completed': 'Completed',
        'dueOn': 'Due on',
        'reschedule': 'Reschedule',
        'schedule': 'Schedule',
        'details': 'Details',
        'markComplete': 'Mark Complete',
        'addVaccine': 'Add Vaccine',
        'noVaccines': 'No vaccines scheduled',
      },
      'si': {
        'title': 'එන්නත් දින දර්ශනය',
        'upcomingVaccines': 'ඉදිරි එන්නත්',
        'viewAll': 'සියල්ල බලන්න',
        'overdue': 'ප්‍රමාද වූ',
        'scheduled': 'සැලසුම් කළ',
        'completed': 'සම්පූර්ණ කළ',
        'dueOn': 'නියමිත දිනය',
        'reschedule': 'නැවත සැලසුම් කරන්න',
        'schedule': 'සැලසුම් කරන්න',
        'details': 'විස්තර',
        'markComplete': 'සම්පූර්ණ කළ බව සලකුණු කරන්න',
        'addVaccine': 'එන්නත එක් කරන්න',
        'noVaccines': 'එන්නත් සැලසුම් කර නැත',
      },
      'ta': {
        'title': 'தடுப்பூசி காலெண்டர்',
        'upcomingVaccines': 'வரவிருக்கும் தடுப்பூசிகள்',
        'viewAll': 'அனைத்தையும் காண்க',
        'overdue': 'தாமதமான',
        'scheduled': 'திட்டமிடப்பட்ட',
        'completed': 'நிறைவு',
        'dueOn': 'நிலுவை தேதி',
        'reschedule': 'மீண்டும் திட்டமிடு',
        'schedule': 'திட்டமிடு',
        'details': 'விவரங்கள்',
        'markComplete': 'முடிந்ததாக குறி',
        'addVaccine': 'தடுப்பூசி சேர்க்க',
        'noVaccines': 'தடுப்பூசிகள் திட்டமிடப்படவில்லை',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }
}

/// Professional vaccine event model
class VaccineEvent {
  final String name;
  final VaccineStatus status;
  final DateTime date;

  const VaccineEvent(this.name, this.status, this.date);
}

/// Professional vaccine status enum with behavior
enum VaccineStatus {
  scheduled(
    Color(0xFF0086FF),
    Color(0xFFE0F2FF),
    Icons.schedule,
    'scheduled',
  ),
  overdue(
    Color(0xFFEF4444),
    Color(0xFFFEE2E2),
    Icons.warning,
    'overdue',
  ),
  completed(
    Color(0xFF10B981),
    Color(0xFFD1FAE5),
    Icons.check_circle,
    'completed',
  );

  const VaccineStatus(this.color, this.backgroundColor, this.icon, this.name);

  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final String name;

  /// Get action buttons based on status
  List<Widget> getActionButtons(Map<String, String> texts, VoidCallback onPressed) {
    switch (this) {
      case VaccineStatus.overdue:
        return [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.schedule),
              label: Text(texts['reschedule']!),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0086FF),
                side: const BorderSide(color: Color(0xFF0086FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.check),
              label: Text(texts['markComplete']!),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0086FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ];
      case VaccineStatus.scheduled:
        return [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.edit_calendar),
              label: Text(texts['reschedule']!),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0086FF),
                side: const BorderSide(color: Color(0xFF0086FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.info_outline),
              label: Text(texts['details']!),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0086FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ];
      case VaccineStatus.completed:
        return [
          Expanded(
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.info_outline),
              label: Text(texts['details']!),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0086FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ];
    }
  }
}