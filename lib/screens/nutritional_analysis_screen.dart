import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/child_provider.dart';

class NutritionalAnalysisScreen extends StatefulWidget {
  const NutritionalAnalysisScreen({super.key});

  @override
  State<NutritionalAnalysisScreen> createState() =>
      _NutritionalAnalysisScreenState();
}

class _NutritionalAnalysisScreenState extends State<NutritionalAnalysisScreen> {
  String _selectedLanguage = 'en';
  bool _isZScoreExpanded = false;
  final String _selectedMonth = 'July 2023';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
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
        'title': 'Nutritional Analysis',
        'mildMalnutrition': 'Mild Malnutrition',
        'moderateMalnutrition': 'Moderate Malnutrition',
        'severeMalnutrition': 'Severe Malnutrition',
        'normal': 'Normal',
        'basedOnMeasurements': 'Based on your recent measurements',
        'requiresAttention':
            'Your child\'s nutritional status requires attention. Follow the recommendations below to improve their health.',
        'withinHealthyRange':
            'Your child\'s nutritional status is within healthy range. Continue with balanced nutrition.',
        'zScoreAnalysis': 'Z-Score Analysis',
        'lastUpdated': 'Last updated',
        'indicator': 'Indicator',
        'zScore': 'Z-Score',
        'status': 'Status',
        'weightForAge': 'Weight-for-Age',
        'heightForAge': 'Height-for-Age',
        'weightForHeight': 'Weight-for-Height',
        'bmiForAge': 'BMI-for-Age',
        'underweight': 'Underweight',
        'wasted': 'Wasted',
        'stunted': 'Stunted',
        'atRisk': 'At Risk',
        'recommendations': 'Personalized Recommendations',
        'rec1': 'Increase protein intake with eggs, lean meat, and legumes',
        'rec2': 'Add energy-dense foods like avocados, nuts, and healthy oils',
        'rec3':
            'Consider zinc supplements after consulting with your healthcare provider',
        'rec4': 'Schedule a follow-up appointment within 2 weeks',
        'getMealPlan': 'Get Detailed Meal Plan',
        'understandingZScores': 'Understanding Z-Scores',
        'zScoreExplanation':
            'Z-scores compare your child\'s measurements to WHO standards for their age and gender. A score between -2 and +2 is considered normal.',
        'nutritionalHistory': 'Nutritional History',
        'viewAll': 'View All',
      },
      'si': {
        'title': 'පෝෂණ විශ්ලේෂණය',
        'mildMalnutrition': 'මෘදු මන්දපෝෂණය',
        'moderateMalnutrition': 'මධ්‍යස්ථ මන්දපෝෂණය',
        'severeMalnutrition': 'දැඩි මන්දපෝෂණය',
        'normal': 'සාමාන්‍ය',
        'basedOnMeasurements': 'ඔබගේ මෑත මිනුම් මත පදනම්ව',
        'requiresAttention':
            'ඔබේ දරුවාගේ පෝෂණ තත්ත්වයට අවධානය අවශ්‍යයි. සෞඛ්‍යය වැඩිදියුණු කිරීමට පහත නිර්දේශ අනුගමනය කරන්න.',
        'withinHealthyRange':
            'ඔබේ දරුවාගේ පෝෂණ තත්ත්වය සෞඛ්‍ය සම්පන්න පරාසය තුළ ඇත.',
        'zScoreAnalysis': 'Z-ලකුණු විශ්ලේෂණය',
        'lastUpdated': 'අවසන් යාවත්කාලීන',
        'indicator': 'දර්ශකය',
        'zScore': 'Z-ලකුණු',
        'status': 'තත්ත්වය',
        'weightForAge': 'වයස සඳහා බර',
        'heightForAge': 'වයස සඳහා උස',
        'weightForHeight': 'උස සඳහා බර',
        'bmiForAge': 'වයස සඳහා BMI',
        'underweight': 'අඩු බර',
        'wasted': 'කෘශ',
        'stunted': 'වර්ධනය අඩාල',
        'atRisk': 'අවදානම්',
        'recommendations': 'පුද්ගලික නිර්දේශ',
        'rec1':
            'බිත්තර, මස් සහ රනිල කුලයේ ආහාර සමඟ ප්‍රෝටීන් ප්‍රමාණය වැඩි කරන්න',
        'rec2':
            'අලිගැට පේර, ඇට වර්ග සහ සෞඛ්‍ය සම්පන්න තෙල් වැනි ශක්ති ඝන ආහාර එක් කරන්න',
        'rec3':
            'සෞඛ්‍ය සේවා සපයන්නා සමඟ සාකච්ඡා කිරීමෙන් පසු සින්ක් අතිරේක සලකා බලන්න',
        'rec4': 'සති 2ක් ඇතුළත පසු විපරම් පත්වීමක් කරන්න',
        'getMealPlan': 'සවිස්තර ආහාර සැලැස්ම ලබා ගන්න',
        'understandingZScores': 'Z-ලකුණු තේරුම් ගැනීම',
        'zScoreExplanation':
            'Z-ලකුණු ඔබේ දරුවාගේ මිනුම් ඔවුන්ගේ වයස සහ ස්ත්‍රී පුරුෂ භාවය සඳහා WHO ප්‍රමිතීන් සමඟ සංසන්දනය කරයි.',
        'nutritionalHistory': 'පෝෂණ ඉතිහාසය',
        'viewAll': 'සියල්ල බලන්න',
      },
      'ta': {
        'title': 'ஊட்டச்சத்து பகுப்பாய்வு',
        'mildMalnutrition': 'லேசான ஊட்டச்சத்து குறைபாடு',
        'moderateMalnutrition': 'மிதமான ஊட்டச்சத்து குறைபாடு',
        'severeMalnutrition': 'கடுமையான ஊட்டச்சத்து குறைபாடு',
        'normal': 'இயல்பு',
        'basedOnMeasurements': 'உங்கள் சமீபத்திய அளவீடுகளின் அடிப்படையில்',
        'requiresAttention':
            'உங்கள் குழந்தையின் ஊட்டச்சத்து நிலை கவனம் தேவை. ஆரோக்கியத்தை மேம்படுத்த கீழே உள்ள பரிந்துரைகளைப் பின்பற்றவும்.',
        'withinHealthyRange':
            'உங்கள் குழந்தையின் ஊட்டச்சத்து நிலை ஆரோக்கியமான வரம்பிற்குள் உள்ளது.',
        'zScoreAnalysis': 'Z-மதிப்பெண் பகுப்பாய்வு',
        'lastUpdated': 'கடைசியாக புதுப்பிக்கப்பட்டது',
        'indicator': 'குறிகாட்டி',
        'zScore': 'Z-மதிப்பெண்',
        'status': 'நிலை',
        'weightForAge': 'வயதுக்கான எடை',
        'heightForAge': 'வயதுக்கான உயரம்',
        'weightForHeight': 'உயரத்திற்கான எடை',
        'bmiForAge': 'வயதுக்கான BMI',
        'underweight': 'குறைந்த எடை',
        'wasted': 'மெலிந்த',
        'stunted': 'வளர்ச்சி குன்றிய',
        'atRisk': 'ஆபத்தில்',
        'recommendations': 'தனிப்பயனாக்கப்பட்ட பரிந்துரைகள்',
        'rec1':
            'முட்டை, மெலிந்த இறைச்சி மற்றும் பருப்பு வகைகளுடன் புரத உட்கொள்ளலை அதிகரிக்கவும்',
        'rec2':
            'வெண்ணெய் பழம், கொட்டைகள் மற்றும் ஆரோக்கியமான எண்ணெய்கள் போன்ற ஆற்றல் அடர்த்தியான உணவுகளை சேர்க்கவும்',
        'rec3':
            'உங்கள் சுகாதார வழங்குநருடன் ஆலோசித்த பிறகு துத்தநாக சப்ளிமெண்ட்களை கருத்தில் கொள்ளவும்',
        'rec4': '2 வாரங்களுக்குள் பின்தொடர் சந்திப்பை திட்டமிடவும்',
        'getMealPlan': 'விரிவான உணவு திட்டம் பெறவும்',
        'understandingZScores': 'Z-மதிப்பெண்களை புரிந்துகொள்ளுதல்',
        'zScoreExplanation':
            'Z-மதிப்பெண்கள் உங்கள் குழந்தையின் அளவீடுகளை அவர்களின் வயது மற்றும் பாலினத்திற்கான WHO தரநிலைகளுடன் ஒப்பிடுகின்றன.',
        'nutritionalHistory': 'ஊட்டச்சத்து வரலாறு',
        'viewAll': 'அனைத்தையும் காண்க',
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
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('No child selected'),
        ),
      );
    }

    final status = _calculateNutritionalStatus(provider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF1A1A1A)),
              onPressed: () {
                // Previous month
              },
            ),
            Text(
              _selectedMonth,
              style: TextStyle(
                color: const Color(0xFF1A1A1A),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today_outlined,
                  color: Color(0xFF10B981), size: 20),
              onPressed: () {
                // Open calendar
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF1A1A1A)),
              onPressed: () {
                // Next month
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(status, texts),

            const SizedBox(height: 24),

            // Z-Score Analysis
            _buildZScoreAnalysis(provider, texts),

            const SizedBox(height: 24),

            // Personalized Recommendations
            _buildRecommendations(status, texts),

            const SizedBox(height: 16),

            // Get Meal Plan Button
            _buildMealPlanButton(texts),

            const SizedBox(height: 24),

            // Understanding Z-Scores
            _buildUnderstandingZScores(texts),

            const SizedBox(height: 24),

            // Nutritional History
            _buildNutritionalHistory(texts),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      Map<String, dynamic> status, Map<String, String> texts) {
    final statusColor = _getStatusColor(status['severity']);
    final statusBgColor = _getStatusBackgroundColor(status['severity']);
    final statusIcon = _getStatusIcon(status['severity']);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texts[status['label']]!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      texts['basedOnMeasurements']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            status['severity'] == 'normal'
                ? texts['withinHealthyRange']!
                : texts['requiresAttention']!,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF374151),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZScoreAnalysis(
      ChildProvider provider, Map<String, String> texts) {
    final zScores = _calculateZScores(provider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                texts['zScoreAnalysis']!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              Text(
                '${texts['lastUpdated']}: Jul 15, 2023',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                // Header Row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          texts['indicator']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                            fontFamily: _selectedLanguage == 'si'
                                ? 'NotoSerifSinhala'
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          texts['zScore']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                            fontFamily: _selectedLanguage == 'si'
                                ? 'NotoSerifSinhala'
                                : null,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          texts['status']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                            fontFamily: _selectedLanguage == 'si'
                                ? 'NotoSerifSinhala'
                                : null,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Z-Score Rows
                ...zScores.map((score) => _buildZScoreRow(score, texts)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZScoreRow(
      Map<String, dynamic> score, Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              texts[score['indicator']]!,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF374151),
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              score['value'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: score['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    texts[score['status']]!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: score['color'],
                      fontFamily:
                          _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(
      Map<String, dynamic> status, Map<String, String> texts) {
    final recommendations = [
      texts['rec1']!,
      texts['rec2']!,
      texts['rec3']!,
      texts['rec4']!,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['recommendations']!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF374151),
                          height: 1.4,
                          fontFamily: _selectedLanguage == 'si'
                              ? 'NotoSerifSinhala'
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMealPlanButton(Map<String, String> texts) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.go('/learn');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          texts['getMealPlan']!,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
      ),
    );
  }

  Widget _buildUnderstandingZScores(Map<String, String> texts) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isZScoreExpanded = !_isZScoreExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      texts['understandingZScores']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                  ),
                  Icon(
                    _isZScoreExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          if (_isZScoreExpanded)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                texts['zScoreExplanation']!,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNutritionalHistory(Map<String, String> texts) {
    final history = [
      {'date': 'Jun 15, 2023', 'status': 'moderateMalnutrition'},
      {'date': 'May 15, 2023', 'status': 'moderateMalnutrition'},
      {'date': 'Apr 15, 2023', 'status': 'severeMalnutrition'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                texts['nutritionalHistory']!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  texts['viewAll']!,
                  style: TextStyle(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...history.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  title: Text(
                    item['date'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  subtitle: Text(
                    texts[item['status']]!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                      fontFamily:
                          _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF6B7280),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateNutritionalStatus(ChildProvider provider) {
    // This is a simplified calculation - actual implementation would use WHO standards
    final latestRecord =
        provider.growthRecords.isNotEmpty ? provider.growthRecords.first : null;

    if (latestRecord == null) {
      return {'severity': 'normal', 'label': 'normal'};
    }

    final bmi = latestRecord.weight /
        ((latestRecord.height / 100) * (latestRecord.height / 100));

    if (bmi < 16) {
      return {'severity': 'severe', 'label': 'severeMalnutrition'};
    } else if (bmi < 17) {
      return {'severity': 'moderate', 'label': 'moderateMalnutrition'};
    } else if (bmi < 18.5) {
      return {'severity': 'mild', 'label': 'mildMalnutrition'};
    } else {
      return {'severity': 'normal', 'label': 'normal'};
    }
  }

  List<Map<String, dynamic>> _calculateZScores(ChildProvider provider) {
    // Placeholder Z-scores - actual implementation would use WHO standards
    return [
      {
        'indicator': 'weightForAge',
        'value': '-1.8',
        'status': 'underweight',
        'color': const Color(0xFFFBBF24),
      },
      {
        'indicator': 'heightForAge',
        'value': '-0.9',
        'status': 'normal',
        'color': const Color(0xFF10B981),
      },
      {
        'indicator': 'weightForHeight',
        'value': '-2.1',
        'status': 'wasted',
        'color': const Color(0xFFEF4444),
      },
      {
        'indicator': 'bmiForAge',
        'value': '-1.5',
        'status': 'atRisk',
        'color': const Color(0xFFFBBF24),
      },
    ];
  }

  Color _getStatusColor(String severity) {
    switch (severity) {
      case 'severe':
        return const Color(0xFFEF4444);
      case 'moderate':
        return const Color(0xFFFB923C);
      case 'mild':
        return const Color(0xFFFBBF24);
      default:
        return const Color(0xFF10B981);
    }
  }

  Color _getStatusBackgroundColor(String severity) {
    switch (severity) {
      case 'severe':
        return const Color(0xFFFEE2E2);
      case 'moderate':
        return const Color(0xFFFED7AA);
      case 'mild':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFD1FAE5);
    }
  }

  IconData _getStatusIcon(String severity) {
    switch (severity) {
      case 'severe':
      case 'moderate':
      case 'mild':
        return Icons.warning_amber_rounded;
      default:
        return Icons.check_circle_outline;
    }
  }
}
