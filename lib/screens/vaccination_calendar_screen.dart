import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/child_provider.dart';

class VaccinationCalendarScreen extends StatefulWidget {
  const VaccinationCalendarScreen({super.key});

  @override
  State<VaccinationCalendarScreen> createState() => _VaccinationCalendarScreenState();
}

class _VaccinationCalendarScreenState extends State<VaccinationCalendarScreen> 
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _selectedLanguage = 'en';
  bool _isListView = false;
  bool _isCalendarCollapsed = false;
  
  final Map<DateTime, List<VaccineEvent>> _events = {};
  ScrollController? _scrollController;
  AnimationController? _calendarAnimationController;
  Animation<double>? _calendarAnimation;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _selectedDay = DateTime.now();
    _loadVaccineEvents();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    _scrollController = ScrollController();
    _calendarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _calendarAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _calendarAnimationController!,
      curve: Curves.easeInOut,
    ));
    
    _scrollController!.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController?.dispose();
    _calendarAnimationController?.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController == null || _calendarAnimationController == null) return;
    
    const threshold = 100.0;
    final offset = _scrollController!.offset;
    
    // Scroll UP minimizes calendar, scroll DOWN expands calendar
    if (offset > threshold && !_isCalendarCollapsed) {
      setState(() {
        _isCalendarCollapsed = true;
      });
      _calendarAnimationController!.forward();
    } else if (offset <= threshold && _isCalendarCollapsed) {
      setState(() {
        _isCalendarCollapsed = false;
      });
      _calendarAnimationController!.reverse();
    }
  }
  
  void _toggleCalendar() {
    if (_calendarAnimationController == null) return;
    
    setState(() {
      _isCalendarCollapsed = !_isCalendarCollapsed;
    });
    
    if (_isCalendarCollapsed) {
      _calendarAnimationController!.forward();
    } else {
      _calendarAnimationController!.reverse();
    }
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

    if (_isListView) {
      return _buildListView(provider, texts);
    }

    // Ensure controllers are initialized
    if (_scrollController == null || _calendarAnimationController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        controller: _scrollController!,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              floating: false,
              expandedHeight: 0,
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
                    _isCalendarCollapsed ? Icons.expand_more : Icons.expand_less,
                    color: const Color(0xFF6B7280),
                  ),
                  onPressed: _toggleCalendar,
                  tooltip: _isCalendarCollapsed ? 'Show Calendar' : 'Hide Calendar',
                ),
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
            
            // Child Selector
            if (provider.children.length > 1)
              SliverToBoxAdapter(
                child: _buildChildSelector(provider, texts),
              ),
            
            // Collapsible Calendar
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _calendarAnimation!,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _getCalendarHeight(),
                    child: ClipRect(
                      child: Transform.scale(
                        scale: 0.7 + (0.3 * (1 - _calendarAnimation!.value)),
                        child: Opacity(
                          opacity: 0.3 + (0.7 * (1 - _calendarAnimation!.value)),
                          child: _buildCalendarView(texts),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Legend
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _calendarAnimation!,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _calendarAnimation!.value > 0.5 ? 0 : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _calendarAnimation!.value > 0.5 ? 0 : 1,
                      child: _buildLegend(texts),
                    ),
                  );
                },
              ),
            ),
            
            // Section Header for Upcoming Vaccines
            SliverToBoxAdapter(
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
            ),
          ];
        },
        body: _buildUpcomingVaccinesList(provider, texts),
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
  
  double _getCalendarHeight() {
    // Calculate height based on calendar components
    final headerHeight = 60.0;        // Calendar header
    final daysOfWeekHeight = 40.0;     // Days of week header
    final calendarGridHeight = 288.0;  // 6 weeks * 48px per row
    final totalHeight = headerHeight + daysOfWeekHeight + calendarGridHeight;
    final minHeight = headerHeight;    // Just show header when collapsed
    
    if (_calendarAnimation == null) return totalHeight;
    return minHeight + ((totalHeight - minHeight) * (1 - _calendarAnimation!.value));
  }
  
  Widget _buildListView(ChildProvider provider, Map<String, String> texts) {
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
          if (provider.children.length > 1)
            _buildChildSelector(provider, texts),
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
        child: DropdownButton<String>(
          value: provider.selectedChild?.id,
          isExpanded: true,
          underline: const SizedBox(),
          icon: const Icon(Icons.expand_more, color: Color(0xFF6B7280)),
          items: provider.children.map((child) {
            final age = provider.getAgeString(child.birthDate);
            return DropdownMenuItem<String>(
              value: child.id,
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
          onChanged: (String? childId) {
            if (childId != null) {
              final child = provider.children.firstWhere((c) => c.id == childId);
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
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calendar Header
            _buildCalendarHeader(),
            
            // Days of Week
            _buildDaysOfWeekHeader(),
            
            // Calendar Grid
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    
    return SizedBox(
      height: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                });
              },
              icon: const Icon(Icons.chevron_left, color: Color(0xFF6B7280)),
            ),
            Text(
              '${monthNames[_focusedDay.month - 1]} ${_focusedDay.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                });
              },
              icon: const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    final daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    
    return SizedBox(
      height: 40,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: daysOfWeek.map((day) {
            return Expanded(
              child: Text(
                day,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;
    
    final weeks = <Widget>[];
    var dayCounter = 1;
    
    // Build weeks (limit to 6 weeks max)
    for (int week = 0; week < 6; week++) {
      final days = <Widget>[];
      
      for (int day = 0; day < 7; day++) {
        Widget dayWidget;
        
        if (week == 0 && day < firstDayWeekday) {
          // Previous month days
          final prevMonthDay = DateTime(_focusedDay.year, _focusedDay.month, 0).day - (firstDayWeekday - day - 1);
          dayWidget = _buildDayCell(
            prevMonthDay.toString(),
            DateTime(_focusedDay.year, _focusedDay.month - 1, prevMonthDay),
            isCurrentMonth: false,
          );
        } else if (dayCounter <= daysInMonth) {
          // Current month days
          final currentDate = DateTime(_focusedDay.year, _focusedDay.month, dayCounter);
          dayWidget = _buildDayCell(
            dayCounter.toString(),
            currentDate,
            isCurrentMonth: true,
          );
          dayCounter++;
        } else {
          // Next month days
          final nextMonthDay = dayCounter - daysInMonth;
          dayWidget = _buildDayCell(
            nextMonthDay.toString(),
            DateTime(_focusedDay.year, _focusedDay.month + 1, nextMonthDay),
            isCurrentMonth: false,
          );
          dayCounter++;
        }
        
        days.add(Expanded(child: dayWidget));
      }
      
      weeks.add(
        SizedBox(
          height: 48, // Fixed height for each week row
          child: Row(children: days),
        ),
      );
      
      if (dayCounter > daysInMonth && week > 3) break;
    }
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: weeks,
    );
  }

  Widget _buildDayCell(String day, DateTime date, {required bool isCurrentMonth}) {
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _selectedDay != null && _isSameDay(date, _selectedDay!);
    final events = _events[DateTime(date.year, date.month, date.day)] ?? [];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = date;
        });
        
        if (events.isNotEmpty) {
          _showDayEventsSheet(context, date, events, _getLocalizedText());
        }
      },
      child: Container(
        height: 48,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0086FF).withValues(alpha: 0.2)
              : isToday
                  ? const Color(0xFF0086FF).withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isCurrentMonth
                    ? isSelected || isToday
                        ? const Color(0xFF0086FF)
                        : const Color(0xFF1A1A1A)
                    : const Color(0xFF9CA3AF),
              ),
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: events.take(3).map((event) {
                  Color color = const Color(0xFF0086FF);
                  if (event.status == 'overdue') {
                    color = const Color(0xFFEF4444);
                  } else if (event.status == 'completed') {
                    color = const Color(0xFF10B981);
                  }
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
  
  Widget _buildUpcomingVaccinesList(ChildProvider provider, Map<String, String> texts) {
    final upcomingVaccines = _getUpcomingVaccines();
    
    if (upcomingVaccines.isEmpty) {
      return Center(
        child: Text(
          texts['noVaccines']!,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Extra bottom padding for FAB
      itemCount: upcomingVaccines.length,
      itemBuilder: (context, index) {
        final vaccine = upcomingVaccines[index];
        return _buildExpandedVaccineCard(vaccine, texts);
      },
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
  
  Widget _buildExpandedVaccineCard(Map<String, dynamic> vaccine, Map<String, String> texts) {
    final statusColor = _getStatusColor(vaccine['status']);
    final statusBgColor = _getStatusBackgroundColor(vaccine['status']);
    final statusIcon = _getStatusIcon(vaccine['status']);
    
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
            // Header with icon and status
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
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
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          texts[vaccine['status']]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
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
            
            // Details section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(Icons.calendar_today, texts['dueOn']!, vaccine['date'], texts),
                  if (vaccine['clinic'] != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.location_on_outlined, 'Clinic', vaccine['clinic'], texts),
                  ],
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.access_time, 'Time', '2:30 PM', texts),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.person, 'Doctor', 'Dr. Sarah Johnson', texts),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                if (vaccine['status'] == 'overdue') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        texts['reschedule']!,
                        style: TextStyle(
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0086FF),
                        side: const BorderSide(color: Color(0xFF0086FF)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check),
                      label: Text(
                        texts['markComplete']!,
                        style: TextStyle(
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0086FF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else if (vaccine['status'] == 'scheduled') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_calendar),
                      label: Text(
                        texts['reschedule']!,
                        style: TextStyle(
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0086FF),
                        side: const BorderSide(color: Color(0xFF0086FF)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline),
                      label: Text(
                        texts['details']!,
                        style: TextStyle(
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0086FF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        texts['schedule']!,
                        style: TextStyle(
                          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0086FF),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value, Map<String, String> texts) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF6B7280),
        ),
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
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'overdue':
        return Icons.warning;
      case 'scheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.vaccines;
    }
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
              ),),
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