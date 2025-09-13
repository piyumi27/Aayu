import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child.dart';
import '../models/nutrition_guideline.dart';
import '../providers/child_provider.dart';
import '../repositories/standards_repository.dart';
import '../utils/responsive_utils.dart';
import '../widgets/notifications/notification_badge.dart';

class NutritionCalculatorScreen extends StatefulWidget {
  const NutritionCalculatorScreen({super.key});

  @override
  State<NutritionCalculatorScreen> createState() => _NutritionCalculatorScreenState();
}

class _NutritionCalculatorScreenState extends State<NutritionCalculatorScreen> {
  String _selectedLanguage = 'en';
  String _selectedTab = 'calculator';
  List<NutritionGuideline> _guidelines = [];
  late StandardsRepository _repository;

  // Calculator state
  double _childWeight = 0;
  int _childAgeMonths = 0;
  String _activityLevel = 'moderate';
  Map<String, double> _dailyRequirements = {};

  // Meal planning state
  List<Map<String, dynamic>> _mealPlan = [];

  @override
  void initState() {
    super.initState();
    _repository = StandardsRepository();
    _loadLanguage();
    _loadNutritionData();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    });
  }

  Future<void> _loadNutritionData() async {
    final provider = Provider.of<ChildProvider>(context, listen: false);
    final child = provider.selectedChild;
    
    if (child != null) {
      final ageInMonths = provider.calculateAgeInMonths(child.birthDate);
      final latestRecord = provider.growthRecords.isNotEmpty ? provider.growthRecords.first : null;
      
      setState(() {
        _childAgeMonths = ageInMonths;
        _childWeight = latestRecord?.weight ?? 0;
      });

      // Load nutrition guidelines
      try {
        final guidelines = await _repository.getNutritionGuidelinesForAge(
          ageMonths: ageInMonths,
          source: 'SriLanka',
        );
        setState(() {
          _guidelines = guidelines;
        });
        _calculateDailyRequirements();
      } catch (e) {
        // Handle error
        print('Error loading nutrition data: $e');
      }
    }
  }

  void _calculateDailyRequirements() {
    if (_childWeight == 0 || _childAgeMonths == 0) return;

    // Calculate daily caloric needs based on Sri Lankan guidelines
    double calories = 0;
    if (_childAgeMonths < 6) {
      calories = 108 * _childWeight; // Breast milk only
    } else if (_childAgeMonths < 12) {
      calories = 95 * _childWeight; // With complementary foods
    } else if (_childAgeMonths < 24) {
      calories = 90 * _childWeight;
    } else {
      calories = 85 * _childWeight;
    }

    // Adjust for activity level
    switch (_activityLevel) {
      case 'low':
        calories *= 0.9;
        break;
      case 'high':
        calories *= 1.1;
        break;
      default: // moderate
        break;
    }

    setState(() {
      _dailyRequirements = {
        'calories': calories,
        'protein': calories * 0.12 / 4, // 12% of calories from protein
        'carbs': calories * 0.55 / 4, // 55% from carbs
        'fat': calories * 0.33 / 9, // 33% from fat
        'calcium': _childAgeMonths < 12 ? 525 : 700, // mg
        'iron': _childAgeMonths < 12 ? 11 : 7, // mg
        'vitaminC': _childAgeMonths < 12 ? 50 : 15, // mg
        'vitaminD': 10, // mcg
      };
    });

    _generateMealPlan();
  }

  void _generateMealPlan() {
    final calories = _dailyRequirements['calories'] ?? 0;
    
    if (_childAgeMonths < 6) {
      // Breast milk only
      setState(() {
        _mealPlan = [
          {
            'meal': _getLocalizedText()['breastMilk']!,
            'time': '6:00 AM',
            'food': _getLocalizedText()['exclusiveBreastfeeding']!,
            'calories': calories / 8,
            'frequency': '8-12 times per day',
          }
        ];
      });
    } else {
      // Generate age-appropriate meal plan
      final meals = _getAgeAppropriateMeals();
      setState(() {
        _mealPlan = meals;
      });
    }
  }

  List<Map<String, dynamic>> _getAgeAppropriateMeals() {
    final texts = _getLocalizedText();
    final calories = _dailyRequirements['calories'] ?? 0;

    if (_childAgeMonths < 12) {
      return [
        {
          'meal': texts['breakfast']!,
          'time': '7:00 AM',
          'food': texts['ironRichCereal']!,
          'calories': calories * 0.2,
          'description': texts['ironRichCerealDesc']!,
        },
        {
          'meal': texts['midMorning']!,
          'time': '10:00 AM',
          'food': texts['breastMilk']!,
          'calories': calories * 0.15,
          'description': texts['continuedBreastfeeding']!,
        },
        {
          'meal': texts['lunch']!,
          'time': '12:30 PM',
          'food': texts['veggiePuree']!,
          'calories': calories * 0.25,
          'description': texts['veggiePureeDesc']!,
        },
        {
          'meal': texts['afternoon']!,
          'time': '3:00 PM',
          'food': texts['fruitPuree']!,
          'calories': calories * 0.15,
          'description': texts['fruitPureeDesc']!,
        },
        {
          'meal': texts['dinner']!,
          'time': '6:00 PM',
          'food': texts['lentilRice']!,
          'calories': calories * 0.25,
          'description': texts['lentilRiceDesc']!,
        },
      ];
    } else {
      return [
        {
          'meal': texts['breakfast']!,
          'time': '7:30 AM',
          'food': texts['hoppers']!,
          'calories': calories * 0.25,
          'description': texts['hoppersDesc']!,
        },
        {
          'meal': texts['midMorning']!,
          'time': '10:00 AM',
          'food': texts['coconutWater']!,
          'calories': calories * 0.1,
          'description': texts['coconutWaterDesc']!,
        },
        {
          'meal': texts['lunch']!,
          'time': '12:30 PM',
          'food': texts['riceCurry']!,
          'calories': calories * 0.35,
          'description': texts['riceCurryDesc']!,
        },
        {
          'meal': texts['afternoon']!,
          'time': '3:00 PM',
          'food': texts['kiribath']!,
          'calories': calories * 0.15,
          'description': texts['kiribathDesc']!,
        },
        {
          'meal': texts['dinner']!,
          'time': '7:00 PM',
          'food': texts['stringHoppers']!,
          'calories': calories * 0.15,
          'description': texts['stringHoppersDesc']!,
        },
      ];
    }
  }

  Map<String, String> _getLocalizedText() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Nutrition Calculator',
        'calculator': 'Calculator',
        'planner': 'Meal Planner',
        'guidelines': 'Guidelines',
        'dailyRequirements': 'Daily Nutritional Requirements',
        'calories': 'Calories',
        'protein': 'Protein',
        'carbohydrates': 'Carbohydrates',
        'fat': 'Fat',
        'calcium': 'Calcium',
        'iron': 'Iron',
        'vitaminC': 'Vitamin C',
        'vitaminD': 'Vitamin D',
        'activityLevel': 'Activity Level',
        'low': 'Low',
        'moderate': 'Moderate',
        'high': 'High',
        'mealPlan': 'Recommended Meal Plan',
        'breakfast': 'Breakfast',
        'midMorning': 'Mid Morning',
        'lunch': 'Lunch',
        'afternoon': 'Afternoon',
        'dinner': 'Dinner',
        'breastMilk': 'Breast Milk',
        'exclusiveBreastfeeding': 'Exclusive breastfeeding recommended',
        'continuedBreastfeeding': 'Continue breastfeeding on demand',
        'ironRichCereal': 'Iron-fortified infant cereal',
        'ironRichCerealDesc': 'Mixed with breast milk or formula',
        'veggiePuree': 'Vegetable puree',
        'veggiePureeDesc': 'Carrot, sweet potato, or green leafy vegetables',
        'fruitPuree': 'Fruit puree',
        'fruitPureeDesc': 'Banana, papaya, or mango',
        'lentilRice': 'Lentil rice',
        'lentilRiceDesc': 'Soft cooked rice with well-cooked lentils',
        'hoppers': 'Hoppers (Appa)',
        'hoppersDesc': 'Traditional Sri Lankan pancake with egg',
        'coconutWater': 'Coconut water',
        'coconutWaterDesc': 'Fresh coconut water for hydration',
        'riceCurry': 'Rice & Curry',
        'riceCurryDesc': 'Rice with vegetable curry and dhal',
        'kiribath': 'Milk rice (Kiribath)',
        'kiribathDesc': 'Rice cooked in coconut milk',
        'stringHoppers': 'String hoppers',
        'stringHoppersDesc': 'With coconut sambol and curry',
        'localFoods': 'Local Food Recommendations',
        'portions': 'Age-appropriate portions',
        'frequency': 'Meal frequency',
        'tips': 'Feeding Tips',
      },
      'si': {
        'title': 'පෝෂණ කැල්කියුලේටරය',
        'calculator': 'කැල්කියුලේටරය',
        'planner': 'ආහාර සැලසුම්කරණය',
        'guidelines': 'මාර්ගෝපදේශ',
        'dailyRequirements': 'දෛනික පෝෂණ අවශ්‍යතා',
        'calories': 'කැලරි',
        'protein': 'ප්‍රෝටීන්',
        'carbohydrates': 'කාබෝහයිඩ්‍රේට්',
        'fat': 'මේදය',
        'calcium': 'කැල්සියම්',
        'iron': 'යකඩ',
        'vitaminC': 'විටමින් C',
        'vitaminD': 'විටමින් D',
        'activityLevel': 'ක්‍රියාකාරීත්ව මට්ටම',
        'low': 'අඩු',
        'moderate': 'මධ්‍යම',
        'high': 'ඉහළ',
        'mealPlan': 'නිර්දේශිත ආහාර සැලසුම',
        'breakfast': 'උදේ ආහාරය',
        'midMorning': 'උදේ මැද',
        'lunch': 'දිවා ආහාරය',
        'afternoon': 'සවස',
        'dinner': 'රාත්‍රී ආහාරය',
        'breastMilk': 'මව් කිරි',
        'exclusiveBreastfeeding': 'පමණක් මව් කිරි පානය කරවන්න',
        'continuedBreastfeeding': 'අවශ්‍යතාව පරිදි මව් කිරි දිගටම ලබා දෙන්න',
        'ironRichCereal': 'යකඩ සහිත ළමා ධාන්‍ය',
        'ironRichCerealDesc': 'මව් කිරි හෝ කිරි කුඩුව සමග මිශ්‍ර කර',
        'localFoods': 'දේශීය ආහාර නිර්දේශ',
        'portions': 'වයසට සරිලන කොටස්',
        'frequency': 'ආහාර සංඛ්‍යාතය',
        'tips': 'පෝෂණ ඉඟි',
      },
      'ta': {
        'title': 'ஊட்டச்சத்து கணிப்பான்',
        'calculator': 'கணிப்பான்',
        'planner': 'உணவுத் திட்டமிடல்',
        'guidelines': 'வழிகாட்டுதல்கள்',
        'dailyRequirements': 'தினசரி ஊட்டச்சத்து தேவைகள்',
        'calories': 'கலோரிகள்',
        'protein': 'புரதம்',
        'carbohydrates': 'கார்போஹைட்ரேட்',
        'fat': 'கொழுப்பு',
        'calcium': 'கால்சியம்',
        'iron': 'இரும்பு',
        'vitaminC': 'வைட்டமின் C',
        'vitaminD': 'வைட்டமின் D',
        'localFoods': 'உள்ளூர் உணவு பரிந்துரைகள்',
        'portions': 'வயதுக்கு ஏற்ற பகுதிகள்',
        'frequency': 'உணவு அதிர்வெண்',
        'tips': 'உணவளிக்கும் குறிப்புகள்',
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
          // Tab Navigation
          _buildTabNavigation(texts),
          
          // Content
          Expanded(
            child: _selectedTab == 'calculator'
                ? _buildCalculatorView(texts)
                : _selectedTab == 'planner'
                ? _buildPlannerView(texts)
                : _buildGuidelinesView(texts),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(Map<String, String> texts) {
    final tabs = ['calculator', 'planner', 'guidelines'];
    
    return Container(
      color: Colors.white,
      child: Row(
        children: tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 16),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF0086FF) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  texts[tab]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF0086FF) : const Color(0xFF6B7280),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalculatorView(Map<String, String> texts) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Level Selector
          _buildActivitySelector(texts),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          
          // Daily Requirements
          _buildDailyRequirements(texts),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
          
          // Local Food Recommendations
          _buildLocalFoodRecommendations(texts),
        ],
      ),
    );
  }

  Widget _buildActivitySelector(Map<String, String> texts) {
    return Container(
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
          Text(
            texts['activityLevel']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          
          Row(
            children: ['low', 'moderate', 'high'].map((level) {
              final isSelected = _activityLevel == level;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _activityLevel = level);
                    _calculateDailyRequirements();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveSpacing(context, 4),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0086FF) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      texts[level]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRequirements(Map<String, String> texts) {
    if (_dailyRequirements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
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
          Text(
            texts['dailyRequirements']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          
          ...['calories', 'protein', 'carbohydrates', 'fat', 'calcium', 'iron', 'vitaminC', 'vitaminD'].map(
            (nutrient) => _buildNutrientRow(nutrient, texts),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String nutrient, Map<String, String> texts) {
    final value = _dailyRequirements[nutrient == 'carbohydrates' ? 'carbs' : nutrient] ?? 0;
    String unit = '';
    String displayValue = '';

    switch (nutrient) {
      case 'calories':
        unit = 'kcal';
        displayValue = value.round().toString();
        break;
      case 'protein':
      case 'carbohydrates':
      case 'fat':
        unit = 'g';
        displayValue = value.toStringAsFixed(1);
        break;
      case 'calcium':
      case 'iron':
      case 'vitaminC':
        unit = 'mg';
        displayValue = value.toStringAsFixed(1);
        break;
      case 'vitaminD':
        unit = 'mcg';
        displayValue = value.toStringAsFixed(1);
        break;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            texts[nutrient]!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              color: const Color(0xFF374151),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          Text(
            '$displayValue $unit',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0086FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalFoodRecommendations(Map<String, String> texts) {
    final localFoods = [
      {'name': 'Red rice (කේකුළු හාල්)', 'benefit': 'Rich in fiber and nutrients'},
      {'name': 'Jack fruit (කොස්)', 'benefit': 'High in vitamin C and fiber'},
      {'name': 'Curry leaves (කරපින්චා)', 'benefit': 'Rich in antioxidants'},
      {'name': 'Coconut (පොල්)', 'benefit': 'Healthy fats and minerals'},
      {'name': 'Gotukola (ගොටුකොළ)', 'benefit': 'Brain development'},
      {'name': 'Fish (මාළු)', 'benefit': 'Omega-3 and protein'},
    ];

    return Container(
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
          Text(
            texts['localFoods']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          
          ...localFoods.map((food) => Container(
            margin: EdgeInsets.only(
              bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['name']!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                Text(
                  food['benefit']!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPlannerView(Map<String, String> texts) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['mealPlan']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          
          ..._mealPlan.map((meal) => _buildMealCard(meal, texts)).toList(),
        ],
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, Map<String, String> texts) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal['meal'],
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              Text(
                meal['time'],
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: const Color(0xFF0086FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          
          Text(
            meal['food'],
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          
          if (meal['description'] != null) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            Text(
              meal['description'],
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: const Color(0xFF6B7280),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ],
          
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                color: const Color(0xFFEF4444),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
              Text(
                '${meal['calories'].round()} ${texts['calories']!}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelinesView(Map<String, String> texts) {
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        children: [
          _buildGuidelineCard(texts['portions']!, 'Serve age-appropriate portion sizes', Icons.restaurant_menu),
          _buildGuidelineCard(texts['frequency']!, 'Feed frequently in small amounts', Icons.schedule),
          _buildGuidelineCard(texts['tips']!, 'Introduce new foods gradually', Icons.lightbulb_outline),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard(String title, String description, IconData icon) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 12)),
            decoration: BoxDecoration(
              color: const Color(0xFF0086FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0086FF),
              size: ResponsiveUtils.getResponsiveIconSize(context, 24),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}