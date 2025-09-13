import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../models/vaccine.dart';
import '../providers/child_provider.dart';
import '../utils/responsive_utils.dart';
import '../utils/sri_lankan_vaccination_schedule.dart';
import '../widgets/notifications/notification_badge.dart';
import '../widgets/safe_gesture_detector.dart';

class VaccinationTimelineScreen extends StatefulWidget {
  const VaccinationTimelineScreen({super.key});

  @override
  State<VaccinationTimelineScreen> createState() =>
      _VaccinationTimelineScreenState();
}

class _VaccinationTimelineScreenState extends State<VaccinationTimelineScreen> {
  String _selectedLanguage = 'en';
  String _selectedView = 'timeline'; // timeline, calendar
  List<Vaccine> _allVaccines = [];
  List<VaccineRecord> _givenVaccines = [];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadVaccineData();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  void _loadVaccineData() {
    setState(() {
      _allVaccines = SriLankanVaccinationSchedule.vaccines;
    });

    final provider = Provider.of<ChildProvider>(context, listen: false);
    setState(() {
      _givenVaccines = provider.vaccineRecords;
    });
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Vaccination Timeline',
        'timeline': 'Timeline',
        'calendar': 'Calendar',
        'completed': 'Completed',
        'upcoming': 'Upcoming',
        'overdue': 'Overdue',
        'birth': 'Birth',
        'months': 'months',
        'years': 'years',
        'dueAt': 'Due at',
        'givenOn': 'Given on',
        'mandatory': 'Mandatory',
        'optional': 'Optional',
        'scheduleNow': 'Schedule Now',
        'markComplete': 'Mark Complete',
        'vaccineInfo': 'Vaccine Information',
        'description': 'Description',
        'ageRange': 'Age Range',
        'nextDue': 'Next vaccines due',
        'overdueVaccines': 'Overdue vaccines',
      },
      'si': {
        'title': 'එන්නත් කාලසටහන',
        'timeline': 'කාලසටහන',
        'calendar': 'දිනදසුන',
        'completed': 'සම්පූර්ණයි',
        'upcoming': 'ඉදිරියට',
        'overdue': 'ප්‍රමාද වූ',
        'birth': 'උපත',
        'months': 'මාස',
        'years': 'අවුරුදු',
        'dueAt': 'කල් බලා සිටී',
        'givenOn': 'ලබා දී ඇත',
        'mandatory': 'අනිවාර්ය',
        'optional': 'විකල්ප',
        'scheduleNow': 'දැන් සැලසුම් කරන්න',
        'markComplete': 'සම්පූර්ණ කළ ලෙස සලකුණු කරන්න',
        'vaccineInfo': 'එන්නත් තොරතුරු',
        'description': 'විස්තරය',
        'ageRange': 'වයස් පරාසය',
        'nextDue': 'ඊළඟ එන්නත්',
        'overdueVaccines': 'ප්‍රමාද වූ එන්නත්',
      },
      'ta': {
        'title': 'தடுப்பூசி காலவரிசை',
        'timeline': 'காலவரிசை',
        'calendar': 'நாட்காட்டி',
        'completed': 'முடிந்தது',
        'upcoming': 'வரவிருக்கும்',
        'overdue': 'தாமதமான',
        'birth': 'பிறப்பு',
        'months': 'மாதங்கள்',
        'years': 'ஆண்டுகள்',
        'dueAt': 'காரணமாக',
        'givenOn': 'கொடுக்கப்பட்டது',
        'mandatory': 'கட்டாயம்',
        'optional': 'விருப்பமான',
        'scheduleNow': 'இப்போது திட்டமிடுங்கள்',
        'markComplete': 'முடிந்ததாக குறிக்கவும்',
        'vaccineInfo': 'தடுப்பூசி தகவல்',
        'description': 'விவரம்',
        'ageRange': 'வயது வரம்பு',
        'nextDue': 'அடுத்த தடுப்பூசிகள்',
        'overdueVaccines': 'தாமதமான தடுப்பூசிகள்',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    final provider = Provider.of<ChildProvider>(context);
    final child = provider.selectedChild;

    if (child == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(texts['title']!),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: Text('No child selected'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          texts['title']!,
          style: TextStyle(
            color: const Color(0xFF1A1A1A),
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => context.pop(),
        ),
        actions: [
          SmartNotificationBadge(
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Icon(
                Icons.notifications_outlined,
                color: const Color(0xFF6B7280),
                size: ResponsiveUtils.getResponsiveIconSize(context, 24),
              ),
              tooltip: 'Notifications',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // View Toggle
          _buildViewToggle(texts),

          // Summary Cards
          _buildSummaryCards(child, texts),

          // Vaccination Timeline
          Expanded(
            child: _selectedView == 'timeline'
                ? _buildTimelineView(child, texts)
                : _buildCalendarView(child, texts),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(Map<String, String> texts) {
    return Container(
      color: Colors.white,
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: ['timeline', 'calendar'].map((view) {
            final isSelected = _selectedView == view;
            return Expanded(
              child: SafeGestureDetector(
                onTap: () => setState(() => _selectedView = view),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0086FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    texts[view]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 14),
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? Colors.white : const Color(0xFF6B7280),
                      fontFamily:
                          _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Child child, Map<String, String> texts) {
    final ageInMonths = Provider.of<ChildProvider>(context)
        .calculateAgeInMonths(child.birthDate);
    final upcomingVaccines = _getUpcomingVaccines(ageInMonths);
    final overdueVaccines = _getOverdueVaccines(ageInMonths);
    final completedCount = _givenVaccines.length;

    return Container(
      color: Colors.white,
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              texts['completed']!,
              completedCount.toString(),
              const Color(0xFF10B981),
              Icons.check_circle_outline,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: _buildSummaryCard(
              texts['upcoming']!,
              upcomingVaccines.length.toString(),
              const Color(0xFF3B82F6),
              Icons.schedule,
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 12)),
          Expanded(
            child: _buildSummaryCard(
              texts['overdue']!,
              overdueVaccines.length.toString(),
              const Color(0xFFEF4444),
              Icons.warning_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveUtils.getResponsiveIconSize(context, 24),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              color: const Color(0xFF6B7280),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView(Child child, Map<String, String> texts) {
    final ageInMonths = Provider.of<ChildProvider>(context)
        .calculateAgeInMonths(child.birthDate);
    final sortedVaccines = List<Vaccine>.from(_allVaccines)
      ..sort(
          (a, b) => a.recommendedAgeMonths.compareTo(b.recommendedAgeMonths));

    return ListView.builder(
      padding: ResponsiveUtils.getResponsivePadding(context),
      itemCount: sortedVaccines.length,
      itemBuilder: (context, index) {
        final vaccine = sortedVaccines[index];
        final isGiven = _isVaccineGiven(vaccine.id);
        final isOverdue =
            vaccine.recommendedAgeMonths < ageInMonths && !isGiven;
        final isUpcoming =
            vaccine.recommendedAgeMonths <= ageInMonths + 3 && !isGiven;

        return _buildTimelineItem(
          vaccine,
          isGiven,
          isOverdue,
          isUpcoming,
          texts,
          index == sortedVaccines.length - 1,
        );
      },
    );
  }

  Widget _buildTimelineItem(
    Vaccine vaccine,
    bool isGiven,
    bool isOverdue,
    bool isUpcoming,
    Map<String, String> texts,
    bool isLast,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isGiven) {
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle;
      statusText = texts['completed']!;
    } else if (isOverdue) {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.warning;
      statusText = texts['overdue']!;
    } else if (isUpcoming) {
      statusColor = const Color(0xFF3B82F6);
      statusIcon = Icons.schedule;
      statusText = texts['upcoming']!;
    } else {
      statusColor = const Color(0xFF9CA3AF);
      statusIcon = Icons.radio_button_unchecked;
      statusText = '';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: ResponsiveUtils.getResponsiveIconSize(context, 24),
              height: ResponsiveUtils.getResponsiveIconSize(context, 24),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusIcon,
                color: Colors.white,
                size: ResponsiveUtils.getResponsiveIconSize(context, 16),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: ResponsiveUtils.getResponsiveSpacing(context, 40),
                color: const Color(0xFFE5E7EB),
              ),
          ],
        ),

        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),

        // Vaccine card
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
            ),
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedLanguage == 'si'
                            ? vaccine.nameLocal
                            : vaccine.name,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 16),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si'
                              ? 'NotoSerifSinhala'
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveUtils.getResponsiveSpacing(context, 8),
                        vertical:
                            ResponsiveUtils.getResponsiveSpacing(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 12),
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                          fontFamily: _selectedLanguage == 'si'
                              ? 'NotoSerifSinhala'
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                Text(
                  vaccine.description,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: const Color(0xFF6B7280),
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(context, 12)),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(
                        width:
                            ResponsiveUtils.getResponsiveSpacing(context, 4)),
                    Text(
                      '${texts['dueAt']!} ${_formatAge(vaccine.recommendedAgeMonths, texts)}',
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 14),
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                    const Spacer(),
                    if (vaccine.isMandatory)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveUtils.getResponsiveSpacing(context, 8),
                          vertical:
                              ResponsiveUtils.getResponsiveSpacing(context, 2),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          texts['mandatory']!,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context, 11),
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFDC2626),
                            fontFamily: _selectedLanguage == 'si'
                                ? 'NotoSerifSinhala'
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(Child child, Map<String, String> texts) {
    // Placeholder for calendar view - can be enhanced later
    return const Center(
      child: Text('Calendar view coming soon'),
    );
  }

  String _formatAge(int months, Map<String, String> texts) {
    if (months == 0) {
      return texts['birth']!;
    } else if (months < 12) {
      return '$months ${texts['months']!}';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths == 0) {
        return '$years ${texts['years']!}';
      } else {
        return '$years ${texts['years']!} $remainingMonths ${texts['months']!}';
      }
    }
  }

  bool _isVaccineGiven(String vaccineId) {
    return _givenVaccines.any((record) => record.vaccineId == vaccineId);
  }

  List<Vaccine> _getUpcomingVaccines(int currentAgeInMonths) {
    final givenVaccineIds = _givenVaccines.map((r) => r.vaccineId).toSet();
    return _allVaccines.where((vaccine) {
      return !givenVaccineIds.contains(vaccine.id) &&
          vaccine.recommendedAgeMonths <= currentAgeInMonths + 3 &&
          vaccine.recommendedAgeMonths >= currentAgeInMonths;
    }).toList();
  }

  List<Vaccine> _getOverdueVaccines(int currentAgeInMonths) {
    final givenVaccineIds = _givenVaccines.map((r) => r.vaccineId).toSet();
    return _allVaccines.where((vaccine) {
      return !givenVaccineIds.contains(vaccine.id) &&
          vaccine.recommendedAgeMonths < currentAgeInMonths;
    }).toList();
  }
}
