import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/responsive_utils.dart';

class AboutAayuScreen extends StatefulWidget {
  const AboutAayuScreen({super.key});

  @override
  State<AboutAayuScreen> createState() => _AboutAayuScreenState();
}

class _AboutAayuScreenState extends State<AboutAayuScreen> {
  String _selectedLanguage = 'en';

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
        'title': 'About Aayu',
        'appName': 'ආයු (Aayu)',
        'subtitle': 'Child Nutrition Tracking for Sri Lankan Families',
        'version': 'Version 1.0.0',
        'description': 'Aayu is a comprehensive child nutrition tracking app designed specifically for Sri Lankan families. Track your child\'s growth, manage vaccination schedules, and get personalized nutrition guidance.',
        'features': 'Key Features',
        'featureGrowth': '• Growth tracking with WHO standards',
        'featureVaccines': '• Vaccination calendar management',
        'featureNutrition': '• Personalized nutrition recommendations',
        'featureMultilingual': '• Multilingual support (English, Sinhala, Tamil)',
        'featureOffline': '• Offline-first with cloud sync',
        'featureSecure': '• Secure and private data storage',
        'developer': 'Developer',
        'developerName': 'Akash Hasendra',
        'developerRole': 'Full Stack Developer & App Designer',
        'github': 'GitHub: HMAHD',
        'madeWith': 'Made with ❤️ in Sri Lanka',
        'privacy': 'Privacy Policy',
        'terms': 'Terms of Service',
        'licenses': 'Open Source Licenses',
        'contact': 'Contact Us',
        'email': 'Email: support@aayu.dev',
        'website': 'Website: www.aayu.dev',
        'visitGithub': 'Visit GitHub Profile',
        'openSourceNotice': 'This app is built with Flutter and uses various open-source libraries.',
      },
      'si': {
        'title': 'ආයු ගැන',
        'appName': 'ආයු (Aayu)',
        'subtitle': 'ශ්‍රී ලාංකික පවුල් සඳහා ළමා පෝෂණ ට්‍රැකර්',
        'version': 'අනුවාදය 1.0.0',
        'description': 'ආයු යනු ශ්‍රී ලාංකික පවුල් සඳහා විශේෂයෙන් නිර්මාණය කරන ලද සම්පූර්ණ ළමා පෝෂණ ට්‍රැකින් යෙදුමකි. ඔබේ දරුවාගේ වර්ධනය ලුහුබඳින්න, එන්නත් කාලසටහන් කළමනාකරණය කරන්න, සහ පුද්ගලාරෝපිත පෝෂණ මඟපෙන්වීම් ලබාගන්න.',
        'features': 'ප්‍රධාන විශේෂාංග',
        'featureGrowth': '• ලෝක සෞඛ්‍ය සංවිධානයේ ප්‍රමිතීන් සමඟ වර්ධන ලුහුබැඳීම',
        'featureVaccines': '• එන්නත් දිනදර්ශන කළමනාකරණය',
        'featureNutrition': '• පුද්ගලාරෝපිත පෝෂණ නිර්දේශ',
        'featureMultilingual': '• බහුභාෂා සහාය (ඉංග්‍රීසි, සිංහල, දමිළ)',
        'featureOffline': '• ක්ලවුඩ් සමමුහුර්ත කිරීම සහිත මැර ලයින් ප්‍රධාන',
        'featureSecure': '• ආරක්‍ෂිත සහ පුද්ගලික දත්ත ගබඩාව',
        'developer': 'සංවර්ධක',
        'developerName': 'ආකාශ් හසේන්ද්‍ර',
        'developerRole': 'පූර්ණ ස්ටැක් සංවර්ධක සහ යෙදුම් නිර්මාණකරු',
        'github': 'GitHub: HMAHD',
        'madeWith': 'ශ්‍රී ලංකාවේදී ❤️ සමඟ නිර්මාණය කරන ලදී',
        'privacy': 'පෞද්ගලිකත්ව ප්‍රතිපත්තිය',
        'terms': 'සේවා කොන්දේසි',
        'licenses': 'විවෘත මූලාශ්‍ර බලපත්‍ර',
        'contact': 'අප සම්බන්ධ කරගන්න',
        'email': 'ඊමේල්: support@aayu.dev',
        'website': 'වෙබ් අඩවිය: www.aayu.dev',
        'visitGithub': 'GitHub පැතිකඩ බලන්න',
        'openSourceNotice': 'මෙම යෙදුම Flutter සමඟ ගොඩනගා ඇති අතර විවිධ විවෘත මූලාශ්‍ර පුස්තකාල භාවිතා කරයි.',
      },
      'ta': {
        'title': 'Aayu பற்றி',
        'appName': 'ආයු (Aayu)',
        'subtitle': 'இலங்கை குடும்பங்களுக்கான குழந்தை ஊட்டச்சத்து கண்காணிப்பு',
        'version': 'பதிப்பு 1.0.0',
        'description': 'Aayu என்பது இலங்கை குடும்பங்களுக்காக பிரத்யேகமாக வடிவமைக்கப்பட்ட ஒரு விரிவான குழந்தை ஊட்டச்சத்து கண்காணிப்பு பயன்பாடு. உங்கள் குழந்தையின் வளர்ச்சியை கண்காணித்து, தடுப்பூசி அட்டவணைகளை நிர்வகித்து, தனிப்பட்ட ஊட்டச்சத்து வழிகாட்டுதலைப் பெறுங்கள்.',
        'features': 'முக்கிய அம்சங்கள்',
        'featureGrowth': '• WHO தரநிலைகளுடன் வளர்ச்சி கண்காணிப்பு',
        'featureVaccines': '• தடுப்பூசி நாட்காட்டி நிர்வாகம்',
        'featureNutrition': '• தனிப்பட்ட ஊட்டச்சத்து பரிந்துரைகள்',
        'featureMultilingual': '• பல மொழி ஆதரவு (ஆங்கிலம், சிங்களம், தமிழ்)',
        'featureOffline': '• கிளவுட் ஒத்திசைவுடன் ஆஃப்லைன்-முதல்',
        'featureSecure': '• பாதுகாப்பான மற்றும் தனிப்பட்ட தரவு சேமிப்பு',
        'developer': 'டெவலப்பர்',
        'developerName': 'அகாஷ் ஹசேந்திர',
        'developerRole': 'ஃபுல் ஸ்டாக் டெவலப்பர் & ஆப் டிசைனர்',
        'github': 'GitHub: HMAHD',
        'madeWith': 'இலங்கையில் ❤️ உடன் உருவாக்கப்பட்டது',
        'privacy': 'தனியுரிமை கொள்கை',
        'terms': 'சேவை விதிமுறைகள்',
        'licenses': 'திறந்த மூல உரிமங்கள்',
        'contact': 'எங்களை தொடர்பு கொள்ளுங்கள்',
        'email': 'மின்னஞ்சல்: support@aayu.dev',
        'website': 'வலைதளம்: www.aayu.dev',
        'visitGithub': 'GitHub சுயவிவரத்தைப் பார்வையிடு',
        'openSourceNotice': 'இந்த பயன்பாடு Flutter உடன் கட்டமைக்கப்பட்டு பல்வேறு திறந்த மூல நூலகங்களைப் பயன்படுத்துகிறது.',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }

  Future<void> _openGitHub() async {
    final url = Uri.parse('https://github.com/HMAHD');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openEmail() async {
    final url = Uri.parse('mailto:support@aayu.dev');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWebsite() async {
    final url = Uri.parse('https://www.aayu.dev');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedText();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          texts['title']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // App Logo & Info Card
            _buildAppInfoCard(texts),
            
            const SizedBox(height: 32),
            
            // Features Section
            _buildFeaturesSection(texts),
            
            const SizedBox(height: 32),
            
            // Developer Section
            _buildDeveloperSection(texts),
            
            const SizedBox(height: 32),
            
            // Contact Section
            _buildContactSection(texts),
            
            const SizedBox(height: 32),
            
            // Legal Section
            _buildLegalSection(texts),
            
            const SizedBox(height: 24),
            
            // Made with love
            Center(
              child: Text(
                texts['madeWith']!,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard(Map<String, String> texts) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0086FF),
                  const Color(0xFF00B894),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0086FF).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'ආ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'NotoSerifSinhala',
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App Name
          Text(
            texts['appName']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            texts['subtitle']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              color: const Color(0xFF6B7280),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0086FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              texts['version']!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                color: const Color(0xFF0086FF),
                fontWeight: FontWeight.w600,
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          Text(
            texts['description']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              color: const Color(0xFF4B5563),
              height: 1.5,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(Map<String, String> texts) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['features']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(texts['featureGrowth']!),
          _buildFeatureItem(texts['featureVaccines']!),
          _buildFeatureItem(texts['featureNutrition']!),
          _buildFeatureItem(texts['featureMultilingual']!),
          _buildFeatureItem(texts['featureOffline']!),
          _buildFeatureItem(texts['featureSecure']!),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        feature,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          color: const Color(0xFF4B5563),
          height: 1.5,
          fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
        ),
      ),
    );
  }

  Widget _buildDeveloperSection(Map<String, String> texts) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['developer']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 16),
          
          // Developer Avatar & Info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6),
                      const Color(0xFF06B6D4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'AH',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      texts['developerName']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      texts['developerRole']!,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
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
          
          // GitHub Button
          GestureDetector(
            onTap: _openGitHub,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF24292F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.code,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    texts['visitGithub']!,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(Map<String, String> texts) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            texts['contact']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 16),
          
          // Email
          GestureDetector(
            onTap: _openEmail,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0086FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    color: const Color(0xFF0086FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  texts['email']!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: const Color(0xFF4B5563),
                    fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Website
          GestureDetector(
            onTap: _openWebsite,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.language_outlined,
                    color: const Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  texts['website']!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                    color: const Color(0xFF4B5563),
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

  Widget _buildLegalSection(Map<String, String> texts) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLegalItem(texts['privacy']!),
          _buildDivider(),
          _buildLegalItem(texts['terms']!),
          _buildDivider(),
          _buildLegalItem(texts['licenses']!),
          const SizedBox(height: 16),
          Text(
            texts['openSourceNotice']!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              color: const Color(0xFF9CA3AF),
              fontStyle: FontStyle.italic,
              height: 1.4,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement navigation to respective legal pages
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  color: const Color(0xFF4B5563),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF9CA3AF),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFF3F4F6),
    );
  }
}