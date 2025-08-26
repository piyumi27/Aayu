import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/child_provider.dart';
import '../utils/responsive_utils.dart';
import 'add_child_screen.dart';
import 'add_measurement_screen.dart';
import 'growth_charts_screen.dart';
import 'vaccination_calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    Future.microtask(() {
      if (mounted) {
        context.read<ChildProvider>().loadChildren();
        context.read<ChildProvider>().loadVaccines();
      }
    });
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'dashboard': 'Dashboard',
        'welcomeToAayu': 'Welcome to Aayu',
        'addChildToStart': 'Add your child to get started',
        'addChild': 'Add Child',
        'weight': 'Weight',
        'height': 'Height',
        'bmi': 'BMI',
        'noData': 'No data',
        'nutritionalStatus': 'Nutritional Status',
        'normal': 'Normal',
        'underweight': 'Underweight',
        'overweight': 'Overweight',
        'addMeasurement': 'Add Measurement',
        'growthCharts': 'Growth Charts',
        'vaccines': 'Vaccines',
        'learn': 'Learn',
        'recentActivity': 'Recent Activity',
        'noRecentActivity': 'No recent activity',
        'age': 'Age',
        'gender': 'Gender',
        'kg': 'kg',
        'cm': 'cm',
        'lastMeasurement': 'Last measurement',
      },
      'si': {
        'dashboard': 'උපකරණ පුවරුව',
        'welcomeToAayu': 'ආයු වෙත සාදරයෙන් පිළිගනිමු',
        'addChildToStart': 'ආරම්භ කිරීමට ඔබේ දරුවා එක් කරන්න',
        'addChild': 'දරුවා එක් කරන්න',
        'weight': 'බර',
        'height': 'උස',
        'bmi': 'BMI',
        'noData': 'දත්ත නොමැත',
        'nutritionalStatus': 'පෝෂණ තත්ත්වය',
        'normal': 'සාමාන්‍ය',
        'underweight': 'අඩු බර',
        'overweight': 'වැඩි බර',
        'addMeasurement': 'මැනීම එක් කරන්න',
        'growthCharts': 'වර්ධන ප්‍රස්ථාර',
        'vaccines': 'එන්නත්',
        'learn': 'ඉගෙන ගන්න',
        'recentActivity': 'මෑත ක්‍රියාකාරකම්',
        'noRecentActivity': 'මෑත ක්‍රියාකාරකම් නොමැත',
        'age': 'වයස',
        'gender': 'ලිංගය',
        'kg': 'කිලෝ',
        'cm': 'සෙමී',
        'lastMeasurement': 'අවසන් මැනීම',
      },
      'ta': {
        'dashboard': 'டாஷ்போர்டு',
        'welcomeToAayu': 'ஆயுவிற்கு வரவேற்கிறோம்',
        'addChildToStart': 'தொடங்க உங்கள் குழந்தையை சேர்க்கவும்',
        'addChild': 'குழந்தையை சேர்க்கவும்',
        'weight': 'எடை',
        'height': 'உயரம்',
        'bmi': 'BMI',
        'noData': 'தரவு இல்லை',
        'nutritionalStatus': 'ஊட்டச்சத்து நிலை',
        'normal': 'சாதாரண',
        'underweight': 'குறைந்த எடை',
        'overweight': 'அதிக எடை',
        'addMeasurement': 'அளவீடு சேர்க்கவும்',
        'growthCharts': 'வளர்ச்சி விளக்கப்படங்கள்',
        'vaccines': 'தடுப்பூசிகள்',
        'learn': 'கற்றுக்கொள்ளுங்கள்',
        'recentActivity': 'சமீபத்திய செயல்பாடு',
        'noRecentActivity': 'சமீபத்திய செயல்பாடு இல்லை',
        'age': 'வயது',
        'gender': 'பாலினம்',
        'kg': 'கிலோ',
        'cm': 'செமீ',
        'lastMeasurement': 'கடைசி அளவீடு',
      },
    };

    return texts[_selectedLanguage] ?? texts['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    
    return Consumer<ChildProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: SafeArea(
            child: provider.children.isEmpty
                ? _buildEmptyState(texts)
                : Column(
                    children: [
                      // App Header
                      _buildAppHeader(texts),
                      
                      // Child Selector (always show to include Add Child button)
                      _buildCleanChildSelector(provider, texts),
                      
                      // Main Content Area
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              
                              // Hero Card
                              if (provider.selectedChild != null)
                                _buildCleanHeroCard(provider, texts),
                              
                              // Nutritional Status Banner
                              if (provider.selectedChild != null)
                                _buildNutritionStatusBanner(provider, texts),
                              
                              // Action Grid
                              _buildCleanActionGrid(texts),
                              
                              // Recent Activity
                              if (provider.selectedChild != null)
                                _buildCleanRecentActivity(provider, texts),
                              
                              const SizedBox(height: 100), // Space for bottom navigation
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Map<String, String> texts) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.child_care,
            size: 100,
            color: const Color(0xFF0086FF).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            texts['welcomeToAayu']!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texts['addChildToStart']!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _addChild(context),
            icon: const Icon(Icons.add),
            label: Text(
              texts['addChild']!,
              style: TextStyle(
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }











  void _openAddMeasurement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddMeasurementScreen(),
      ),
    );
  }

  void _addChild(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddChildScreen(),
      ),
    );
  }

  Widget _buildAppHeader(Map<String, String> texts) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // App title
          Expanded(
            child: Text(
              texts['dashboard'] ?? 'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
          // Action buttons
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () => context.push('/settings'),
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF6B7280),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanChildSelector(ChildProvider provider, Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Child selector chips
            ...provider.children.map((child) {
              final isSelected = provider.selectedChild?.id == child.id;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => provider.selectChild(child),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0086FF) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isSelected 
                              ? Colors.white.withValues(alpha: 0.3)
                              : const Color(0xFF6B7280),
                          child: Text(
                            child.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          child.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF374151),
                            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            
            // Add Child button
            GestureDetector(
              onTap: () => _addChild(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      texts['addChild'] ?? 'Add Child',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanHeroCard(ChildProvider provider, Map<String, String> texts) {
    final child = provider.selectedChild;
    if (child == null) return const SizedBox();
    
    final latestGrowth = provider.growthRecords.isNotEmpty 
        ? provider.growthRecords.first 
        : null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Child info row
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFF0086FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    child.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and age
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    Text(
                      '${texts['age']}: ${provider.getAgeString(child.birthDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metrics row
          Row(
            children: [
              _buildMetricItem(
                texts['weight'] ?? 'Weight',
                latestGrowth?.weight.toString() ?? '--',
                texts['kg'] ?? 'kg',
              ),
              const SizedBox(width: 16),
              _buildMetricItem(
                texts['height'] ?? 'Height',
                latestGrowth?.height.toString() ?? '--',
                texts['cm'] ?? 'cm',
              ),
              const SizedBox(width: 16),
              _buildMetricItem(
                texts['bmi'] ?? 'BMI',
                latestGrowth != null 
                    ? (latestGrowth.weight / ((latestGrowth.height / 100) * (latestGrowth.height / 100))).toStringAsFixed(1)
                    : '--',
                '',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String unit) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF6B7280),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionStatusBanner(ChildProvider provider, Map<String, String> texts) {
    final latestGrowth = provider.growthRecords.isNotEmpty 
        ? provider.growthRecords.first 
        : null;
    
    String status = texts['normal'] ?? 'Normal';
    Color statusColor = const Color(0xFF10B981);
    IconData statusIcon = Icons.check_circle;
    
    if (latestGrowth != null) {
      final bmi = latestGrowth.weight / ((latestGrowth.height / 100) * (latestGrowth.height / 100));
      if (bmi < 18.5) {
        status = texts['underweight'] ?? 'Underweight';
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.warning;
      } else if (bmi > 25) {
        status = texts['overweight'] ?? 'Overweight';
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error;
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${texts['nutritionalStatus'] ?? 'Nutritional Status'}: $status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: statusColor,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanActionGrid(Map<String, String> texts) {
    final actions = [
      {
        'title': texts['addMeasurement'] ?? 'Add Measurement',
        'icon': Icons.add_chart_outlined,
        'color': const Color(0xFF0086FF),
        'onTap': () => _openAddMeasurement(context),
      },
      {
        'title': texts['growthCharts'] ?? 'Growth Charts',
        'icon': Icons.trending_up,
        'color': const Color(0xFF10B981),
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const GrowthChartsScreen(),
          ),
        ),
      },
      {
        'title': texts['vaccines'] ?? 'Vaccines',
        'icon': Icons.vaccines_outlined,
        'color': const Color(0xFFF59E0B),
        'onTap': () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const VaccinationCalendarScreen(),
          ),
        ),
      },
      {
        'title': texts['learn'] ?? 'Learn',
        'icon': Icons.school_outlined,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => context.go('/learn'),
      },
    ];

    return Container(
      margin: ResponsiveUtils.getResponsivePadding(context),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.getResponsiveColumnCount(context),
          crossAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
          mainAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
          childAspectRatio: ResponsiveUtils.isSmallWidth(context) ? 0.9 : 1.0,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: action['onTap'] as VoidCallback,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      action['icon'] as IconData,
                      color: action['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    action['title'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF374151),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCleanRecentActivity(ChildProvider provider, Map<String, String> texts) {
    final recentRecords = <Map<String, dynamic>>[];
    
    // Add recent growth records
    for (final record in provider.growthRecords.take(3)) {
      recentRecords.add({
        'type': 'measurement',
        'title': '${texts['weight']}: ${record.weight} ${texts['kg']}, ${texts['height']}: ${record.height} ${texts['cm']}',
        'date': record.date,
        'icon': Icons.trending_up,
        'color': const Color(0xFF10B981),
      });
    }
    
    // Add recent vaccine records
    for (final record in provider.vaccineRecords.take(2)) {
      try {
        final vaccine = provider.vaccines.firstWhere(
          (v) => v.id == record.vaccineId,
        );
        recentRecords.add({
          'type': 'vaccine',
          'title': vaccine.name,
          'date': record.givenDate,
          'icon': Icons.vaccines,
          'color': const Color(0xFFF59E0B),
        });
      } catch (e) {
        continue;
      }
    }
    
    // Sort by date and take last 5
    recentRecords.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    final displayRecords = recentRecords.take(5).toList();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['recentActivity'] ?? 'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF111827),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 12),
          if (displayRecords.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  texts['noRecentActivity'] ?? 'No recent activity',
                  style: TextStyle(
                    color: const Color(0xFF6B7280),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayRecords.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Color(0xFFE5E7EB),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final record = displayRecords[index];
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: (record['color'] as Color).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            record['icon'] as IconData,
                            color: record['color'] as Color,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record['title'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF111827),
                                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (record['date'] as DateTime).toString().split(' ')[0],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}