import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/responsive_utils.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _selectedLanguage = 'en';
  final Map<String, bool> _expandedSections = {};
  
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }
  
  @override
  void dispose() {
    // Clear any pending state updates
    _expandedSections.clear();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'en';
      });
    }
  }

  Map<String, dynamic> _getLocalizedContent() {
    final Map<String, Map<String, dynamic>> content = {
      'en': {
        'title': 'Help & Support',
        'faqTitle': 'Frequently Asked Questions',
        'contactTitle': 'Contact Support',
        'phoneLabel': 'Call PHM',
        'emailLabel': 'Email',
        'whatsappLabel': 'WhatsApp',
        'appVersion': 'ආයු Version 1.0.0',
        'phoneNumber': '+94 11 2691111',
        'emailAddress': 'support@health.gov.lk',
        'whatsappNumber': '+94 77 1234567',
        'categories': [
          {
            'title': '🍼 Nutrition & Feeding',
            'faqs': [
              {
                'question': 'When should I start giving solid foods to my baby?',
                'answer': 'According to Sri Lankan health guidelines, you should start introducing solid foods at 6 months while continuing breastfeeding. Begin with rice porridge (කැඳ), mashed vegetables, and fruits. Start with small amounts and gradually increase.',
              },
              {
                'question': 'What traditional Sri Lankan foods are good for babies?',
                'answer': 'Excellent first foods include:\n• Rice porridge (සහල් කැඳ) with breast milk\n• Mashed papaya (පැපොල්)\n• Mashed avocado (අලිගැට පේර)\n• Soft-cooked red rice\n• Mashed banana (කෙසෙල්)\n• Vegetable broth with lentils (පරිප්පු)\nAlways ensure foods are well-cooked and mashed to prevent choking.',
              },
              {
                'question': 'How much water should my child drink daily?',
                'answer': 'Water needs vary by age:\n• 6-12 months: 120-240ml daily\n• 1-3 years: 900ml-1.3L daily\n• 4-8 years: 1.3L-1.7L daily\nIn hot weather, increase water intake. King coconut water (තැඹිලි) is also excellent for hydration.',
              },
              {
                'question': 'My child is not gaining weight properly. What should I do?',
                'answer': 'First, track growth using the app\'s measurement feature. Common solutions include:\n• Increase feeding frequency\n• Add energy-dense foods like coconut milk\n• Ensure protein intake (fish, eggs, lentils)\n• Consult your PHM if weight gain doesn\'t improve\n• Rule out underlying health issues',
              },
            ],
          },
          {
            'title': '📊 Growth & Development',
            'faqs': [
              {
                'question': 'How often should I measure my child\'s weight and height?',
                'answer': 'Recommended measurement frequency:\n• 0-12 months: Monthly\n• 1-2 years: Every 2 months\n• 2-5 years: Every 3 months\n• 5+ years: Every 6 months\nThe app will remind you when measurements are due.',
              },
              {
                'question': 'What are normal growth rates for Sri Lankan children?',
                'answer': 'Average growth rates:\n• Birth-6 months: 600-800g weight gain/month\n• 6-12 months: 400-500g/month\n• 1-2 years: 200-300g/month\n• Height increases ~25cm in first year\nUse the app\'s growth charts to track against WHO standards adapted for Sri Lanka.',
              },
              {
                'question': 'When should I be concerned about my child\'s development?',
                'answer': 'Consult your PHM if your child:\n• Hasn\'t doubled birth weight by 5 months\n• Shows no weight gain for 2+ months\n• Falls below growth curve lines\n• Misses developmental milestones\n• Shows signs of malnutrition\nThe app will alert you to concerning patterns.',
              },
              {
                'question': 'How do I use the growth charts in the app?',
                'answer': 'To use growth charts:\n1. Add measurements regularly\n2. View charts in Growth section\n3. Check position relative to standard curves\n4. Green zone = normal, Yellow = monitor, Red = consult PHM\n5. Export charts for clinic visits',
              },
            ],
          },
          {
            'title': '💉 Vaccinations & Health',
            'faqs': [
              {
                'question': 'What is the Sri Lankan vaccination schedule?',
                'answer': 'Key vaccinations (EPI Schedule):\n• Birth: BCG, Hepatitis B\n• 2 months: Pentavalent, OPV, fIPV\n• 4 months: Pentavalent, OPV\n• 6 months: Pentavalent, OPV\n• 9 months: MMR\n• 12 months: Live JE\n• 18 months: DPT, OPV, MMR\nThe app tracks all vaccinations and sends reminders.',
              },
              {
                'question': 'What should I do if my child misses a vaccination?',
                'answer': 'If a vaccination is missed:\n1. Contact your PHM immediately\n2. Schedule catch-up vaccination\n3. Update the app with new date\n4. Don\'t skip - delayed is better than missing\n5. Bring Child Health Development Record to clinic',
              },
              {
                'question': 'How do I handle common childhood illnesses?',
                'answer': 'For common issues:\n• Fever: Paracetamol as prescribed, lukewarm sponging\n• Diarrhea: Continue breastfeeding, ORS solution, zinc supplements\n• Cough/Cold: Warm fluids, steam inhalation, avoid antibiotics unless prescribed\n• Always consult PHM if symptoms persist >3 days or worsen',
              },
              {
                'question': 'When should I take my child to the hospital?',
                'answer': 'Seek immediate medical care if:\n• High fever >39°C not responding to medication\n• Difficulty breathing or blue lips\n• Severe dehydration (no tears, dry mouth)\n• Unconsciousness or seizures\n• Persistent vomiting\n• Severe allergic reactions\nCall 1990 for emergency ambulance',
              },
            ],
          },
          {
            'title': '📱 Using the App',
            'faqs': [
              {
                'question': 'How do I add multiple children to the app?',
                'answer': 'To add children:\n1. Go to Home screen\n2. Tap the + button\n3. Enter child details\n4. Add photo (optional)\n5. Save profile\n6. Switch between children using dropdown\nNo limit on number of children you can track.',
              },
              {
                'question': 'How do I export data for clinic visits?',
                'answer': 'To export records:\n1. Go to child\'s profile\n2. Select Export Data\n3. Choose format (PDF/Excel)\n4. Select date range\n5. Share via email or WhatsApp\nPHMs can scan QR code for instant access.',
              },
              {
                'question': 'Is my data safe and private?',
                'answer': 'Your data is protected:\n• Encrypted storage on device\n• Optional cloud backup with encryption\n• No data sharing without consent\n• Complies with health data regulations\n• You can delete all data anytime\n• Only you and authorized PHM can access',
              },
              {
                'question': 'How do I change the app language?',
                'answer': 'To change language:\n1. Go to Settings\n2. Tap Language option\n3. Select Sinhala, Tamil, or English\n4. App updates immediately\n5. All content translates\nYour preference is saved automatically.',
              },
            ],
          },
          {
            'title': '🥗 Special Dietary Needs',
            'faqs': [
              {
                'question': 'How do I manage food allergies in my child?',
                'answer': 'For food allergies:\n• Introduce new foods one at a time\n• Wait 3-5 days between new foods\n• Common allergens: eggs, milk, peanuts, seafood\n• Keep food diary in app notes\n• Carry antihistamine if prescribed\n• Inform PHM and update child profile',
              },
              {
                'question': 'What foods help prevent malnutrition?',
                'answer': 'Nutrient-rich local foods:\n• Protein: Fish, chicken, eggs, lentils, soy\n• Iron: Liver, red meat, green leaves (කොළ ගෝවා)\n• Vitamin A: Papaya, mango, carrots, sweet potato\n• Calcium: Milk, yogurt, small fish with bones\n• Energy: Coconut, avocado, ghee\nUse app\'s nutrition guide for meal planning.',
              },
              {
                'question': 'How do I encourage a picky eater?',
                'answer': 'Tips for picky eaters:\n• Offer foods 10-15 times before giving up\n• Make meals colorful and fun\n• Let child help with cooking\n• Don\'t force - create positive associations\n• Mix new foods with favorites\n• Set regular meal times\n• Be a good role model\n• Avoid distractions during meals',
              },
            ],
          },
          {
            'title': '👶 Newborn Care',
            'faqs': [
              {
                'question': 'How often should I breastfeed my newborn?',
                'answer': 'Breastfeeding guidelines:\n• First month: 8-12 times/day (every 2-3 hours)\n• Feed on demand when baby shows hunger cues\n• Each session: 10-15 minutes per breast\n• Night feeding is important\n• Exclusive breastfeeding for 6 months\n• Continue with solids until 2+ years',
              },
              {
                'question': 'What are danger signs in newborns?',
                'answer': 'Seek immediate help if baby:\n• Won\'t feed or feeds poorly\n• Has fever or feels cold\n• Breathing difficulties\n• Yellowing of skin/eyes after day 3\n• Excessive crying or unusually quiet\n• Umbilical cord redness/pus\n• Less than 6 wet diapers/day\nCall PHM or go to hospital immediately.',
              },
              {
                'question': 'How do I care for the umbilical cord?',
                'answer': 'Umbilical cord care:\n• Keep dry and clean\n• Fold diaper below cord\n• Clean with cooled boiled water if soiled\n• Don\'t apply anything unless prescribed\n• Falls off naturally in 5-15 days\n• Small bleeding when falls off is normal\n• See PHM if red, swollen, or has discharge',
              },
            ],
          },
        ],
        'noAnswer': 'Didn\'t find your answer?',
        'contactSupport': 'Contact your nearest PHM office or MOH for personalized assistance.',
      },
      'si': {
        'title': 'උදව් සහ සහාය',
        'faqTitle': 'නිතර අසන ප්‍රශ්න',
        'contactTitle': 'සහාය අමතන්න',
        'phoneLabel': 'PHM අමතන්න',
        'emailLabel': 'ඊමේල්',
        'whatsappLabel': 'WhatsApp',
        'appVersion': 'ආයු Version 1.0.0',
        'phoneNumber': '+94 11 2691111',
        'emailAddress': 'support@health.gov.lk',
        'whatsappNumber': '+94 77 1234567',
        'categories': [
          {
            'title': '🍼 පෝෂණය සහ ආහාර',
            'faqs': [
              {
                'question': 'දරුවාට ඝන ආහාර දීම ආරම්භ කළ යුත්තේ කවදාද?',
                'answer': 'ශ්‍රී ලංකා සෞඛ්‍ය මාර්ගෝපදේශ අනුව, මාස 6 දී ඝන ආහාර හඳුන්වා දීම ආරම්භ කළ යුතු අතර මව්කිරි දීම දිගටම කරගෙන යා යුතුය. සහල් කැඳ, මෙලෙන ලද එළවළු සහ පලතුරු වලින් ආරම්භ කරන්න.',
              },
              {
                'question': 'ළදරුවන් සඳහා හොඳ සාම්ප්‍රදායික ශ්‍රී ලාංකීය ආහාර මොනවාද?',
                'answer': 'විශිෂ්ට පළමු ආහාර:\n• මව්කිරි සමඟ සහල් කැඳ\n• මෙලෙන ලද පැපොල්\n• මෙලෙන ලද අලිගැට පේර\n• මෘදු පිසූ රතු සහල්\n• මෙලෙන ලද කෙසෙල්\n• පරිප්පු සමඟ එළවළු සුප්\nආහාර හොඳින් පිසූ සහ මෙලෙන ලද බව සහතික කරගන්න.',
              },
            ],
          },
        ],
        'noAnswer': 'ඔබේ පිළිතුර සොයාගත නොහැකිද?',
        'contactSupport': 'පුද්ගලික සහාය සඳහා ඔබේ ළඟම PHM කාර්යාලය හෝ MOH අමතන්න.',
      },
      'ta': {
        'title': 'உதவி மற்றும் ஆதரவு',
        'faqTitle': 'அடிக்கடி கேட்கப்படும் கேள்விகள்',
        'contactTitle': 'ஆதரவைத் தொடர்பு கொள்ளுங்கள்',
        'phoneLabel': 'PHM அழைக்க',
        'emailLabel': 'மின்னஞ்சல்',
        'whatsappLabel': 'WhatsApp',
        'appVersion': 'ආයු Version 1.0.0',
        'phoneNumber': '+94 11 2691111',
        'emailAddress': 'support@health.gov.lk',
        'whatsappNumber': '+94 77 1234567',
        'categories': [
          {
            'title': '🍼 ஊட்டச்சத்து மற்றும் உணவு',
            'faqs': [
              {
                'question': 'எனது குழந்தைக்கு திட உணவுகளை எப்போது தொடங்க வேண்டும்?',
                'answer': 'இலங்கை சுகாதார வழிகாட்டுதல்களின்படி, 6 மாதங்களில் திட உணவுகளை அறிமுகப்படுத்த தொடங்க வேண்டும். அரிசி கஞ்சி, மசித்த காய்கறிகள் மற்றும் பழங்களுடன் தொடங்குங்கள்.',
              },
              {
                'question': 'குழந்தைகளுக்கு நல்ல பாரம்பரிய இலங்கை உணவுகள் என்ன?',
                'answer': 'சிறந்த முதல் உணவுகள்:\n• தாய்ப்பாலுடன் அரிசி கஞ்சி\n• மசித்த பப்பாளி\n• மசித்த வெண்ணெய் பழம்\n• மென்மையாக சமைத்த சிவப்பு அரிசி\n• மசித்த வாழைப்பழம்\n• பருப்புடன் காய்கறி சூப்',
              },
            ],
          },
        ],
        'noAnswer': 'உங்கள் பதிலைக் கண்டுபிடிக்க முடியவில்லையா?',
        'contactSupport': 'தனிப்பட்ட உதவிக்கு உங்கள் அருகிலுள்ள PHM அலுவலகம் அல்லது MOH ஐ தொடர்பு கொள்ளுங்கள்.',
      },
    };
    return content[_selectedLanguage] ?? content['en']!;
  }

  @override
  Widget build(BuildContext context) {
    final content = _getLocalizedContent();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          content['title'],
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                content['faqTitle'],
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                  fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ),
            
            // FAQ Categories
            ...List.generate(
              content['categories'].length,
              (categoryIndex) => _buildFAQCategory(
                content['categories'][categoryIndex],
                categoryIndex,
              ),
            ),
            
            // Didn't find answer section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF007BFF).withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content['noAnswer'],
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF007BFF),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content['contactSupport'],
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                      color: const Color(0xFF6B7280),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contact Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content['contactTitle'],
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                      fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Contact Methods Row
                  ResponsiveUtils.isSmallWidth(context)
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _buildContactMethod(
                                  icon: Icons.phone,
                                  label: content['phoneLabel'],
                                  value: content['phoneNumber'],
                                  color: const Color(0xFF007BFF),
                                  onTap: () => _launchPhone(content['phoneNumber']),
                                ),
                              ),
                              Expanded(
                                child: _buildContactMethod(
                                  icon: Icons.email,
                                  label: content['emailLabel'],
                                  value: content['emailAddress'],
                                  color: const Color(0xFF007BFF),
                                  onTap: () => _launchEmail(content['emailAddress']),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildContactMethod(
                            icon: Icons.message,
                            label: content['whatsappLabel'],
                            value: content['whatsappNumber'],
                            color: const Color(0xFF28A745),
                            onTap: () => _launchWhatsApp(content['whatsappNumber']),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildContactMethod(
                              icon: Icons.phone,
                              label: content['phoneLabel'],
                              value: content['phoneNumber'],
                              color: const Color(0xFF007BFF),
                              onTap: () => _launchPhone(content['phoneNumber']),
                            ),
                          ),
                          Expanded(
                            child: _buildContactMethod(
                              icon: Icons.email,
                              label: content['emailLabel'],
                              value: content['emailAddress'],
                              color: const Color(0xFF007BFF),
                              onTap: () => _launchEmail(content['emailAddress']),
                            ),
                          ),
                          Expanded(
                            child: _buildContactMethod(
                              icon: Icons.message,
                              label: content['whatsappLabel'],
                              value: content['whatsappNumber'],
                              color: const Color(0xFF28A745),
                              onTap: () => _launchWhatsApp(content['whatsappNumber']),
                            ),
                          ),
                        ],
                      ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Footer with App Version
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFFF69B4),
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content['appVersion'],
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                      color: const Color(0xFF9CA3AF),
                      fontFamily: 'NotoSerifSinhala',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with ❤️ for Sri Lankan parents',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCategory(Map<String, dynamic> category, int categoryIndex) {
    final isExpanded = _expandedSections['category_$categoryIndex'] ?? false;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (mounted) {
                setState(() {
                  _expandedSections['category_$categoryIndex'] = !isExpanded;
                });
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category['title'],
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF007BFF),
                        fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.expand_more,
                      color: Color(0xFF007BFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            ...List.generate(
              category['faqs'].length,
              (faqIndex) => _buildFAQItem(
                category['faqs'][faqIndex],
                categoryIndex,
                faqIndex,
                faqIndex == category['faqs'].length - 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    Map<String, String> faq,
    int categoryIndex,
    int faqIndex,
    bool isLast,
  ) {
    final key = 'faq_${categoryIndex}_$faqIndex';
    final isExpanded = _expandedSections[key] ?? false;
    
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (mounted) {
              setState(() {
                _expandedSections[key] = !isExpanded;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      child: Icon(
                        isExpanded ? Icons.help : Icons.help_outline,
                        size: 20,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faq['question']!,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A1A),
                              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                              height: 1.4,
                            ),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            Text(
                              faq['answer']!,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                                color: const Color(0xFF6B7280),
                                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: const Color(0xFFE0E0E0),
          ),
      ],
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
                fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('Could not launch phone dialer');
      }
    } catch (e) {
      _showSnackBar('Could not launch phone dialer');
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Aayu App Support Request',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('Could not launch email client');
      }
    } catch (e) {
      _showSnackBar('Could not launch email client');
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$cleanNumber?text=Hello, I need help with the Aayu app');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not launch WhatsApp');
      }
    } catch (e) {
      _showSnackBar('Could not launch WhatsApp');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}