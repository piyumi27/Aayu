import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child.dart';
import '../providers/child_provider.dart';
import 'add_child_screen.dart';

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
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          texts['dashboard']!,
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
      body: Consumer<ChildProvider>(
        builder: (context, provider, child) {
          if (provider.children.isEmpty) {
            return _buildEmptyState(texts);
          }

          return _buildDashboard(provider, texts);
        },
      ),
      floatingActionButton: Consumer<ChildProvider>(
        builder: (context, provider, child) {
          if (provider.children.isEmpty) return const SizedBox();
          return FloatingActionButton(
            onPressed: () => _openAddMeasurement(context),
            backgroundColor: const Color(0xFF0086FF),
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
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

  Widget _buildDashboard(ChildProvider provider, Map<String, String> texts) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child selector chips
          _buildChildSelectorChips(provider, texts),
          
          const SizedBox(height: 16),
          
          // Hero card
          _buildHeroCard(provider, texts),
          
          const SizedBox(height: 16),
          
          // Metrics row
          _buildMetricsRow(provider, texts),
          
          const SizedBox(height: 16),
          
          // Nutritional status banner
          _buildNutritionalStatusBanner(provider, texts),
          
          const SizedBox(height: 24),
          
          // Action grid
          _buildActionGrid(texts),
          
          const SizedBox(height: 24),
          
          // Recent activity
          _buildRecentActivity(provider, texts),
          
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildChildSelectorChips(ChildProvider provider, Map<String, String> texts) {
    if (provider.children.length <= 1) return const SizedBox();
    
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.children.length,
        itemBuilder: (context, index) {
          final child = provider.children[index];
          final isSelected = provider.selectedChild?.id == child.id;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => provider.selectChild(child),
              avatar: CircleAvatar(
                radius: 16,
                backgroundColor: isSelected 
                    ? Colors.white 
                    : const Color(0xFF0086FF).withValues(alpha: 0.1),
                child: Text(
                  child.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF0086FF) : Colors.grey[600],
                  ),
                ),
              ),
              label: Text(
                child.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              selectedColor: const Color(0xFF0086FF),
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(ChildProvider provider, Map<String, String> texts) {
    final child = provider.selectedChild;
    if (child == null) return const SizedBox();
    
    final latestGrowth = provider.growthRecords.isNotEmpty 
        ? provider.growthRecords.first 
        : null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0086FF).withValues(alpha: 0.1),
            const Color(0xFF0086FF).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0086FF).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Child photo (72dp)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0086FF),
                  const Color(0xFF0086FF).withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Center(
              child: Text(
                child.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Child details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${texts['age']}: ${provider.getAgeString(child.birthDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                if (latestGrowth != null)
                  Text(
                    '${texts['lastMeasurement']}: ${latestGrowth.date.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(ChildProvider provider, Map<String, String> texts) {
    final latestGrowth = provider.growthRecords.isNotEmpty 
        ? provider.growthRecords.first 
        : null;
    
    double? bmi;
    if (latestGrowth != null) {
      bmi = latestGrowth.weight / ((latestGrowth.height / 100) * (latestGrowth.height / 100));
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildMetricChip(
            texts['weight']!,
            latestGrowth?.weight.toString() ?? '--',
            texts['kg']!,
            _getMetricStatusColor('weight', latestGrowth?.weight),
            Icons.monitor_weight,
          ),
          const SizedBox(width: 12),
          _buildMetricChip(
            texts['height']!,
            latestGrowth?.height.toString() ?? '--',
            texts['cm']!,
            _getMetricStatusColor('height', latestGrowth?.height),
            Icons.height,
          ),
          const SizedBox(width: 12),
          _buildMetricChip(
            texts['bmi']!,
            bmi?.toStringAsFixed(1) ?? '--',
            '',
            _getMetricStatusColor('bmi', bmi),
            Icons.analytics,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, String unit, Color statusColor, IconData icon) {
    return Expanded(
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: statusColor, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getMetricStatusColor(String metric, double? value) {
    if (value == null) return Colors.grey;
    
    // Simplified status logic - in real app, this would be based on age/gender charts
    switch (metric) {
      case 'weight':
        return Colors.green; // Normal range
      case 'height':
        return Colors.green; // Normal range
      case 'bmi':
        if (value < 18.5) return Colors.orange; // Underweight
        if (value > 25) return Colors.red; // Overweight
        return Colors.green; // Normal
      default:
        return Colors.grey;
    }
  }

  Widget _buildNutritionalStatusBanner(ChildProvider provider, Map<String, String> texts) {
    final latestGrowth = provider.growthRecords.isNotEmpty 
        ? provider.growthRecords.first 
        : null;
    
    String status = texts['normal']!;
    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;
    
    if (latestGrowth != null) {
      final bmi = latestGrowth.weight / ((latestGrowth.height / 100) * (latestGrowth.height / 100));
      if (bmi < 18.5) {
        status = texts['underweight']!;
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
      } else if (bmi > 25) {
        status = texts['overweight']!;
        statusColor = Colors.red;
        statusIcon = Icons.error;
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${texts['nutritionalStatus']}: $status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: statusColor,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(Map<String, String> texts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
        children: [
          _buildActionGridItem(
            texts['addMeasurement']!,
            Icons.add_chart,
            const Color(0xFF0086FF),
            () => _openAddMeasurement(context),
          ),
          _buildActionGridItem(
            texts['growthCharts']!,
            Icons.trending_up,
            Colors.green,
            () => context.go('/growth'),
          ),
          _buildActionGridItem(
            texts['vaccines']!,
            Icons.vaccines,
            Colors.orange,
            () => context.go('/vaccines'),
          ),
          _buildActionGridItem(
            texts['learn']!,
            Icons.school,
            Colors.purple,
            () => context.go('/learn'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGridItem(String label, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 160,
      height: 160,
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.1),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ChildProvider provider, Map<String, String> texts) {
    final recentRecords = <Map<String, dynamic>>[];
    
    // Add recent growth records
    for (final record in provider.growthRecords.take(3)) {
      recentRecords.add({
        'type': 'measurement',
        'title': '${texts['weight']}: ${record.weight} ${texts['kg']}, ${texts['height']}: ${record.height} ${texts['cm']}',
        'date': record.date,
        'icon': Icons.trending_up,
        'color': Colors.green,
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
          'color': Colors.orange,
        });
      } catch (e) {
        // Vaccine not found, skip this record
        continue;
      }
    }
    
    // Sort by date and take last 5
    recentRecords.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    final displayRecords = recentRecords.take(5).toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['recentActivity']!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 12),
          if (displayRecords.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  texts['noRecentActivity']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayRecords.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = displayRecords[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (record['color'] as Color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          record['icon'] as IconData,
                          color: record['color'] as Color,
                          size: 20,
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
                                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (record['date'] as DateTime).toString().split(' ')[0],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
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
        ],
      ),
    );
  }

  void _openAddMeasurement(BuildContext context) {
    // This should open the Add Growth Record sheet from the growth screen
    context.go('/growth');
  }

  void _addChild(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddChildScreen(),
      ),
    );
  }
}