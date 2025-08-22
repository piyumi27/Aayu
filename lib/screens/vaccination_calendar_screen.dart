import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';

import '../providers/child_provider.dart';
import '../models/vaccine.dart';
import '../models/vaccine_record.dart';
import '../models/child.dart';

class VaccinationCalendarScreen extends StatefulWidget {
  const VaccinationCalendarScreen({super.key});

  @override
  State<VaccinationCalendarScreen> createState() => _VaccinationCalendarScreenState();
}

class _VaccinationCalendarScreenState extends State<VaccinationCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedLanguage = 'en';
  bool _isListView = false;
  
  final Map<DateTime, List<VaccineEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _selectedDay = DateTime.now();
    _loadVaccineEvents();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  void _loadVaccineEvents() {
    // Sample events - would be loaded from database
    final today = DateTime.now();
    _events[DateTime(today.year, today.month, 15)] = [
      VaccineEvent('MMR', 'scheduled', DateTime(today.year, today.month, 15)),
    ];
    _events[DateTime(today.year, today.month, 20)] = [
      VaccineEvent('DTaP', 'overdue', DateTime(today.year, today.month, 20)),
    ];
    _events[DateTime(today.year, today.month, 25)] = [
      VaccineEvent('Hepatitis B', 'scheduled', DateTime(today.year, today.month, 25)),
    ];
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Vaccination Calendar',
        'upcomingVaccines': 'Upcoming Vaccines',
        'viewAll': 'View All',
        'overdue': 'Overdue',
        'scheduled': 'Scheduled',
        'completed': 'Completed',
        'upcoming': 'Upcoming',
        'dueOn': 'Due on',
        'reschedule': 'Reschedule',
        'schedule': 'Schedule',
        'details': 'Details',
        'markComplete': 'Mark Complete',
        'mmr': 'MMR (Measles, Mumps, Rubella)',
        'dtap': 'DTaP (5th dose)',
        'hepatitisA': 'Hepatitis A (2nd dose)',
        'hepatitisB': 'Hepatitis B',
        'clinic': 'Sunshine Pediatrics',
        'addVaccine': 'Add Vaccine',
        'months': 'months',
        'years': 'years',
        'noVaccines': 'No vaccines scheduled',
        'selectChild': 'Select Child',
      },
      'si': {
        'title': 'එන්නත් දින දර්ශනය',
        'upcomingVaccines': 'ඉදිරි එන්නත්',
        'viewAll': 'සියල්ල බලන්න',
        'overdue': 'ප්‍රමාද වූ',
        'scheduled': 'සැලසුම් කළ',
        'completed': 'සම්පූර්ණ කළ',
        'upcoming': 'ඉදිරි',
        'dueOn': 'නියමිත දිනය',
        'reschedule': 'නැවත සැලසුම් කරන්න',
        'schedule': 'සැලසුම් කරන්න',
        'details': 'විස්තර',
        'markComplete': 'සම්පූර්ණ කළ බව සලකුණු කරන්න',
        'mmr': 'MMR (සම්මාන, උකුණන්, රුබෙලා)',
        'dtap': 'DTaP (5 වන මාත්‍රාව)',
        'hepatitisA': 'හෙපටයිටිස් A (2 වන මාත්‍රාව)',
        'hepatitisB': 'හෙපටයිටිස් B',
        'clinic': 'සන්ෂයින් ළමා රෝහල',
        'addVaccine': 'එන්නත එක් කරන්න',
        'months': 'මාස',
        'years': 'අවුරුදු',
        'noVaccines': 'එන්නත් සැලසුම් කර නැත',
        'selectChild': 'දරුවා තෝරන්න',
      },
      'ta': {
        'title': 'தடுப்பூசி காலெண்டர்',
        'upcomingVaccines': 'வரவிருக்கும் தடுப்பூசிகள்',
        'viewAll': 'அனைத்தையும் காண்க',
        'overdue': 'தாமதமான',
        'scheduled': 'திட்டமிடப்பட்ட',
        'completed': 'நிறைவு',
        'upcoming': 'வரவிருக்கும்',
        'dueOn': 'நிலுவை தேதி',
        'reschedule': 'மீண்டும் திட்டமிடு',
        'schedule': 'திட்டமிடு',
        'details': 'விவரங்கள்',
        'markComplete': 'முடிந்ததாக குறி',
        'mmr': 'MMR (தட்டம்மை, பொன்னுக்கு வீங்கி, ரூபெல்லா)',
        'dtap': 'DTaP (5வது டோஸ்)',
        'hepatitisA': 'ஹெபடைடிஸ் A (2வது டோஸ்)',
        'hepatitisB': 'ஹெபடைடிஸ் B',
        'clinic': 'சன்ஷைன் குழந்தை மருத்துவமனை',
        'addVaccine': 'தடுப்பூசி சேர்க்க',
        'months': 'மாதங்கள்',
        'years': 'ஆண்டுகள்',
        'noVaccines': 'தடுப்பூசிகள் திட்டமிடப்படவில்லை',
        'selectChild': 'குழந்தையை தேர்ந்தெடுக்கவும்',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    final provider = Provider.of<ChildProvider>(context);
    final child = provider.selectedChild;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          texts['title']!,
          style: TextStyle(
            color: const Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isListView ? Icons.calendar_month : Icons.list,
              color: const Color(0xFF6B7280),
            ),
            onPressed: () {
              setState(() {
                _isListView = !_isListView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: Column(
        children: [
          // Child Selector
          if (provider.children.length > 1)
            _buildChildSelector(provider, texts),
          
          // Calendar or List View
          if (!_isListView) ...[
            _buildCalendarView(texts),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
          ],
          
          // Legend
          if (!_isListView)
            _buildLegend(texts),
          
          // Upcoming Vaccines Section
          Expanded(
            child: _buildUpcomingVaccines(provider, texts),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddVaccineDialog(context, texts);
        },
        backgroundColor: const Color(0xFF0086FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildChildSelector(ChildProvider provider, Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<Child>(
          value: provider.selectedChild,
          isExpanded: true,
          underline: const SizedBox(),
          icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
          items: provider.children.map((child) {
            final age = provider.getAgeString(child.birthDate);
            return DropdownMenuItem<Child>(
              value: child,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF0086FF).withValues(alpha: 0.1),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0086FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
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
                        age,
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
            );
          }).toList(),
          onChanged: (Child? child) {
            if (child != null) {
              provider.selectChild(child);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCalendarView(Map<String, String> texts) {
    return Container(
      color: Colors.white,
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        eventLoader: (day) {
          return _events[DateTime(day.year, day.month, day.day)] ?? [];
        },
        startingDayOfWeek: StartingDayOfWeek.sunday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          weekendTextStyle: const TextStyle(color: Color(0xFF6B7280)),
          holidayTextStyle: const TextStyle(color: Color(0xFF6B7280)),
          selectedDecoration: BoxDecoration(
            color: const Color(0xFF0086FF).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Color(0xFF0086FF),
            fontWeight: FontWeight.bold,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF0086FF).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: Color(0xFF0086FF),
            fontWeight: FontWeight.w600,
          ),
          markersMaxCount: 3,
          markerDecoration: const BoxDecoration(
            color: Color(0xFF0086FF),
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 16,
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
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return null;
            
            final vaccineEvents = events.cast<VaccineEvent>();
            final colors = <Color>[];
            
            for (final event in vaccineEvents) {
              if (event.status == 'overdue') {
                colors.add(const Color(0xFFEF4444));
              } else if (event.status == 'scheduled') {
                colors.add(const Color(0xFF0086FF));
              } else if (event.status == 'completed') {
                colors.add(const Color(0xFF10B981));
              }
            }
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: colors.take(3).map((color) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            );
          },
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          
          final events = _events[DateTime(selectedDay.year, selectedDay.month, selectedDay.day)];
          if (events != null && events.isNotEmpty) {
            _showDayEventsSheet(context, selectedDay, events, texts);
          }
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildLegend(Map<String, String> texts) {
    return Container(
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
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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

  Widget _buildUpcomingVaccines(ChildProvider provider, Map<String, String> texts) {
    final upcomingVaccines = _getUpcomingVaccines();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                texts['upcomingVaccines']!,
                style: TextStyle(
                  fontSize: 18,
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
        Expanded(
          child: upcomingVaccines.isEmpty
              ? Center(
                  child: Text(
                    texts['noVaccines']!,
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: upcomingVaccines.length,
                  itemBuilder: (context, index) {
                    final vaccine = upcomingVaccines[index];
                    return _buildVaccineCard(vaccine, texts);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVaccineCard(Map<String, dynamic> vaccine, Map<String, String> texts) {
    final statusColor = _getStatusColor(vaccine['status']);
    final statusBgColor = _getStatusBackgroundColor(vaccine['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccine['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${texts['dueOn']!} ${vaccine['date']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    texts[vaccine['status']]!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ),
              ],
            ),
            if (vaccine['clinic'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    vaccine['clinic'],
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (vaccine['status'] == 'overdue')
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      texts['reschedule']!,
                      style: TextStyle(
                        color: const Color(0xFF0086FF),
                        fontWeight: FontWeight.w600,
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  )
                else if (vaccine['status'] == 'scheduled')
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      texts['details']!,
                      style: TextStyle(
                        color: const Color(0xFF0086FF),
                        fontWeight: FontWeight.w600,
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      texts['schedule']!,
                      style: TextStyle(
                        color: const Color(0xFF0086FF),
                        fontWeight: FontWeight.w600,
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getUpcomingVaccines() {
    // Sample data - would be loaded from database
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
        'status': 'upcoming',
        'clinic': 'Sunshine Pediatrics',
      },
    ];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'overdue':
        return const Color(0xFFEF4444);
      case 'scheduled':
        return const Color(0xFF0086FF);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'overdue':
        return const Color(0xFFFEE2E2);
      case 'scheduled':
        return const Color(0xFFE0F2FF);
      case 'completed':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  void _showDayEventsSheet(BuildContext context, DateTime day, List<VaccineEvent> events, Map<String, String> texts) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.day}/${day.month}/${day.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...events.map((event) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(event.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.vaccines,
                    color: _getStatusColor(event.status),
                    size: 20,
                  ),
                ),
                title: Text(event.name),
                subtitle: Text(texts[event.status] ?? event.status),
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
        );
      },
    );
  }

  void _showAddVaccineDialog(BuildContext context, Map<String, String> texts) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(texts['addVaccine']!),
          content: const Text('Add vaccine functionality would go here'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class VaccineEvent {
  final String name;
  final String status;
  final DateTime date;

  VaccineEvent(this.name, this.status, this.date);
}