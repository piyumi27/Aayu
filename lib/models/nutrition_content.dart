import 'package:flutter/material.dart';

/// Comprehensive nutrition content model for detailed articles
class NutritionContent {
  final String id;
  final String titleKey;
  final String excerptKey;
  final List<String> ageGroups;
  final List<String> categories;
  final IconData icon;
  final Color primaryColor;
  final int readTime;
  final List<String> tags;
  final List<ContentSection> sections;
  final List<DietitianTip> dietitianTips;
  final List<RelatedArticle> relatedArticles;

  NutritionContent({
    required this.id,
    required this.titleKey,
    required this.excerptKey,
    required this.ageGroups,
    required this.categories,
    required this.icon,
    required this.primaryColor,
    required this.readTime,
    required this.tags,
    required this.sections,
    required this.dietitianTips,
    required this.relatedArticles,
  });

  String getLocalizedTitle(Map<String, String> texts) {
    return texts[titleKey] ?? titleKey;
  }

  String getLocalizedExcerpt(Map<String, String> texts) {
    return texts[excerptKey] ?? excerptKey;
  }
}

/// Content section model for rich article content
class ContentSection {
  final String titleKey;
  final String contentKey;
  final IconData? icon;
  final Color? backgroundColor;
  final List<FoodItem>? foodItems;
  final List<ServingGuideline>? servingGuidelines;
  final ContentSectionType type;

  ContentSection({
    required this.titleKey,
    required this.contentKey,
    this.icon,
    this.backgroundColor,
    this.foodItems,
    this.servingGuidelines,
    required this.type,
  });

  String getLocalizedTitle(Map<String, String> texts) {
    return texts[titleKey] ?? titleKey;
  }

  String getLocalizedContent(Map<String, String> texts) {
    return texts[contentKey] ?? contentKey;
  }
}

/// Content section types
enum ContentSectionType {
  introduction,
  animalProteins,
  plantBasedOptions,
  servingGuidelines,
  preparationTips,
  safetyGuidelines,
}

/// Food item model with Sri Lankan context
class FoodItem {
  final String nameKey;
  final String descriptionKey;
  final String? sinhalaName;
  final String? tamilName;
  final IconData icon;
  final Color color;
  final String servingSize;
  final List<String> benefits;

  FoodItem({
    required this.nameKey,
    required this.descriptionKey,
    this.sinhalaName,
    this.tamilName,
    required this.icon,
    required this.color,
    required this.servingSize,
    required this.benefits,
  });

  String getLocalizedName(Map<String, String> texts) {
    return texts[nameKey] ?? nameKey;
  }

  String getLocalizedDescription(Map<String, String> texts) {
    return texts[descriptionKey] ?? descriptionKey;
  }
}

/// Serving guideline model
class ServingGuideline {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  ServingGuideline({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
  });

  String getLocalizedTitle(Map<String, String> texts) {
    return texts[titleKey] ?? titleKey;
  }

  String getLocalizedDescription(Map<String, String> texts) {
    return texts[descriptionKey] ?? descriptionKey;
  }
}

/// Dietitian tip model
class DietitianTip {
  final String authorKey;
  final String titleKey;
  final String contentKey;
  final String avatarAsset;
  final Color backgroundColor;

  DietitianTip({
    required this.authorKey,
    required this.titleKey,
    required this.contentKey,
    required this.avatarAsset,
    required this.backgroundColor,
  });

  String getLocalizedAuthor(Map<String, String> texts) {
    return texts[authorKey] ?? authorKey;
  }

  String getLocalizedTitle(Map<String, String> texts) {
    return texts[titleKey] ?? titleKey;
  }

  String getLocalizedContent(Map<String, String> texts) {
    return texts[contentKey] ?? contentKey;
  }
}

/// Related article model
class RelatedArticle {
  final String id;
  final String titleKey;
  final String readTime;
  final IconData icon;
  final Color primaryColor;

  RelatedArticle({
    required this.id,
    required this.titleKey,
    required this.readTime,
    required this.icon,
    required this.primaryColor,
  });

  String getLocalizedTitle(Map<String, String> texts) {
    return texts[titleKey] ?? titleKey;
  }
}

/// Comprehensive nutrition content database
class NutritionContentDatabase {
  static NutritionContent getProteinSourcesContent() {
    return NutritionContent(
      id: 'protein_sources_12_23m',
      titleKey: 'proteinSources12To23Title',
      excerptKey: 'proteinSources12To23Excerpt',
      ageGroups: ['12-23 months'],
      categories: ['healthy_foods', 'meal_ideas'],
      icon: Icons.restaurant,
      primaryColor: const Color(0xFF059669),
      readTime: 8,
      tags: ['protein', 'toddler', 'growth', 'sri lankan foods'],
      sections: [
        ContentSection(
          titleKey: 'introductionTitle',
          contentKey: 'proteinIntroductionContent',
          type: ContentSectionType.introduction,
        ),
        ContentSection(
          titleKey: 'animalProteinsTitle',
          contentKey: 'animalProteinsContent',
          icon: Icons.egg,
          backgroundColor: const Color(0xFFFEF3C7),
          type: ContentSectionType.animalProteins,
          foodItems: [
            FoodItem(
              nameKey: 'eggsTitle',
              descriptionKey: 'eggsDescription',
              sinhalaName: 'බිත්තර',
              tamilName: 'முட்டை',
              icon: Icons.egg_outlined,
              color: const Color(0xFFF59E0B),
              servingSize: '1/2 to 1 egg',
              benefits: ['Complete protein', 'Brain development', 'Easy to digest'],
            ),
            FoodItem(
              nameKey: 'fishTitle',
              descriptionKey: 'fishDescription',
              sinhalaName: 'මාලු',
              tamilName: 'மீன்',
              icon: Icons.set_meal,
              color: const Color(0xFF0891B2),
              servingSize: '2-3 tablespoons',
              benefits: ['Omega-3', 'High protein', 'Brain development'],
            ),
            FoodItem(
              nameKey: 'chickenTitle',
              descriptionKey: 'chickenDescription',
              sinhalaName: 'කුකුළු මස්',
              tamilName: 'கோழி இறைச்சி',
              icon: Icons.dinner_dining,
              color: const Color(0xFFDC2626),
              servingSize: '2-3 tablespoons',
              benefits: ['Lean protein', 'Iron', 'B vitamins'],
            ),
            FoodItem(
              nameKey: 'yogurtTitle',
              descriptionKey: 'yogurtDescription',
              sinhalaName: 'දැඹරි',
              tamilName: 'தயிர்',
              icon: Icons.local_drink,
              color: const Color(0xFF7C3AED),
              servingSize: '1/4 to 1/2 cup',
              benefits: ['Probiotics', 'Calcium', 'Protein'],
            ),
          ],
        ),
        ContentSection(
          titleKey: 'plantBasedOptionsTitle',
          contentKey: 'plantBasedOptionsContent',
          icon: Icons.eco,
          backgroundColor: const Color(0xFFD1FAE5),
          type: ContentSectionType.plantBasedOptions,
          foodItems: [
            FoodItem(
              nameKey: 'lentilsTitle',
              descriptionKey: 'lentilsDescription',
              sinhalaName: 'පරිප්ප',
              tamilName: 'பருப்பு',
              icon: Icons.grain,
              color: const Color(0xFF059669),
              servingSize: '2-4 tablespoons',
              benefits: ['Plant protein', 'Fiber', 'Iron'],
            ),
            FoodItem(
              nameKey: 'chickpeasTitle',
              descriptionKey: 'chickpeasDescription',
              sinhalaName: 'කඩල',
              tamilName: 'கொண்டைக்கடலை',
              icon: Icons.circle,
              color: const Color(0xFFCA8A04),
              servingSize: '2-3 tablespoons',
              benefits: ['Protein', 'Fiber', 'Folate'],
            ),
            FoodItem(
              nameKey: 'greenGramTitle',
              descriptionKey: 'greenGramDescription',
              sinhalaName: 'මුං ආටා',
              tamilName: 'பச்சை பயறு',
              icon: Icons.local_florist,
              color: const Color(0xFF16A34A),
              servingSize: '2-3 tablespoons',
              benefits: ['Easy digestion', 'Protein', 'Vitamins'],
            ),
            FoodItem(
              nameKey: 'sesameTitle',
              descriptionKey: 'sesameDescription',
              sinhalaName: 'තල',
              tamilName: 'எள்',
              icon: Icons.blur_circular,
              color: const Color(0xFF92400E),
              servingSize: '1 teaspoon paste',
              benefits: ['Healthy fats', 'Calcium', 'Protein'],
            ),
          ],
        ),
        ContentSection(
          titleKey: 'servingGuidelinesTitle',
          contentKey: 'servingGuidelinesContent',
          icon: Icons.restaurant_menu,
          backgroundColor: const Color(0xFFFECDD3),
          type: ContentSectionType.servingGuidelines,
          servingGuidelines: [
            ServingGuideline(
              titleKey: 'dailyPortionsTitle',
              descriptionKey: 'dailyPortionsDescription',
              icon: Icons.schedule,
              color: const Color(0xFFDC2626),
            ),
            ServingGuideline(
              titleKey: 'mixingFoodsTitle',
              descriptionKey: 'mixingFoodsDescription',
              icon: Icons.blender,
              color: const Color(0xFF059669),
            ),
            ServingGuideline(
              titleKey: 'textureTitle',
              descriptionKey: 'textureDescription',
              icon: Icons.touch_app,
              color: const Color(0xFF7C3AED),
            ),
          ],
        ),
      ],
      dietitianTips: [
        DietitianTip(
          authorKey: 'drEmilyChakma',
          titleKey: 'startWithOneEggTip',
          contentKey: 'startWithOneEggTipContent',
          avatarAsset: 'assets/avatars/doctor1.png',
          backgroundColor: const Color(0xFFFEF3C7),
        ),
        DietitianTip(
          authorKey: 'drSamalPerera',
          titleKey: 'introduceProvidesGraduallyTip',
          contentKey: 'introduceProvidesGraduallyTipContent',
          avatarAsset: 'assets/avatars/doctor2.png',
          backgroundColor: const Color(0xFFE0E7FF),
        ),
      ],
      relatedArticles: [
        RelatedArticle(
          id: 'first_foods_sl',
          titleKey: 'firstFoodsForBaby',
          readTime: '5 min',
          icon: Icons.child_care,
          primaryColor: const Color(0xFFF59E0B),
        ),
        RelatedArticle(
          id: 'healthy_snacks',
          titleKey: 'healthySnacks',
          readTime: '4 min',
          icon: Icons.apple,
          primaryColor: const Color(0xFF10B981),
        ),
        RelatedArticle(
          id: 'meal_planning',
          titleKey: 'mealPlanning',
          readTime: '7 min',
          icon: Icons.calendar_today,
          primaryColor: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  /// Get localized content texts
  static Map<String, String> getLocalizedTexts(String language) {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'proteinSources12To23Title': 'Protein Sources for 12-23 m Kids',
        'proteinSources12To23Excerpt': 'Toddlers between 12-23 months need quality protein for growth. Here are the best local protein sources for Sri Lankan families.',
        
        // Section titles
        'introductionTitle': 'Why Protein Matters',
        'animalProteinsTitle': 'Animal Proteins',
        'plantBasedOptionsTitle': 'Plant-Based Options',
        'servingGuidelinesTitle': 'Serving Guidelines',
        
        // Content
        'proteinIntroductionContent': 'Toddlers between 12-23 months need quality protein for proper growth and brain development. Protein helps build muscles, organs, and supports immune function. Sri Lankan cuisine offers excellent protein sources that are both nutritious and culturally appropriate.',
        'animalProteinsContent': 'Animal proteins provide complete amino acid profiles essential for toddler development. Here are the best options available in Sri Lanka:',
        'plantBasedOptionsContent': 'Plant-based proteins are excellent for variety and digestibility. These traditional Sri Lankan options are perfect for toddlers:',
        'servingGuidelinesContent': 'Follow these guidelines to ensure your toddler gets adequate protein without overwhelming their small stomach:',
        
        // Animal proteins
        'eggsTitle': 'Eggs',
        'eggsDescription': 'Scrambled, boiled, or in curry',
        'fishTitle': 'Fish',
        'fishDescription': 'Small pieces of tuna or salmon',
        'chickenTitle': 'Chicken',
        'chickenDescription': 'Soft, well-cooked pieces',
        'yogurtTitle': 'Yogurt and milk products',
        'yogurtDescription': 'Natural yogurt without added sugar',
        
        // Plant-based options
        'lentilsTitle': 'Red lentils (dhal)',
        'lentilsDescription': 'Easy to digest and versatile',
        'chickpeasTitle': 'Chickpeas',
        'chickpeasDescription': 'Mashed or in curry',
        'greenGramTitle': 'Green gram',
        'greenGramDescription': 'As porridge or soup',
        'sesameTitle': 'Sesame seeds',
        'sesameDescription': 'Ground into paste',
        
        // Serving guidelines
        'dailyPortionsTitle': 'Serve 2-3 small portions daily',
        'dailyPortionsDescription': 'Spread protein intake across meals and snacks',
        'mixingFoodsTitle': 'Mix with familiar foods like rice',
        'mixingFoodsDescription': 'Combine proteins with rice or bread for better acceptance',
        'textureTitle': 'Ensure proper cooking and soft texture',
        'textureDescription': 'All proteins should be well-cooked and age-appropriate texture',
        
        // Dietitian tips
        'drEmilyChakma': 'Dr. Emily Chakma, Pediatric Nutritionist',
        'drSamalPerera': 'Dr. Samal Perera, Pediatrician',
        'startWithOneEggTip': 'Start with one egg per day for toddlers',
        'startWithOneEggTipContent': 'Mix with rice for better acceptance and introduce gradually to check for allergies.',
        'introduceProvidesGraduallyTip': 'Introduce new proteins gradually',
        'introduceProvidesGraduallyTipContent': 'Watch for signs that your baby is ready for solid foods around 4-6 months: good head control, sitting with support, and showing interest in food.',
        
        // Related articles
        'firstFoodsForBaby': 'First Foods for Baby',
        'healthySnacks': 'Healthy Snacks',
        'mealPlanning': 'Meal Planning',
      },
      'si': {
        'proteinSources12To23Title': '12-23 මාස දරුවන් සඳහා ප්‍රෝටීන් ප්‍රභව',
        'proteinSources12To23Excerpt': '12-23 මාස අතර කුඩා දරුවන්ට වර්ධනය සඳහා ගුණාත්මක ප්‍රෝටීන් අවශ්‍ය වේ. ශ්‍රී ලාංකික පවුල් සඳහා හොඳම දේශීය ප්‍රෝටීන් ප්‍රභව මෙන්න.',
        
        // Section titles
        'introductionTitle': 'ප්‍රෝටීන් වැදගත් වන්නේ ඇයි',
        'animalProteinsTitle': 'සත්ව ප්‍රෝටීන්',
        'plantBasedOptionsTitle': 'ශාක පදනම් කළ විකල්ප',
        'servingGuidelinesTitle': 'සේවා කිරීමේ මාර්ගෝපදේශ',
        
        // Content
        'proteinIntroductionContent': '12-23 මාස අතර කුඩා දරුවන්ට නිසි වර්ධනය සහ මොළයේ සංවර්ධනය සඳහා ගුණාත්මක ප්‍රෝටීන් අවශ්‍ය වේ. ප්‍රෝටීන් මාංශ පේශි, අවයව ගොඩනැගීමට සහ ප්‍රතිශක්තිකරණ කාර්යයට උපකාර කරයි.',
        'animalProteinsContent': 'සත්ව ප්‍රෝටීන් කුඩා දරුවන්ගේ සංවර්ධනයට අවශ්‍ය සම්පූර්ණ ඇමයිනෝ අම්ල පැතිකඩ සපයයි:',
        'plantBasedOptionsContent': 'ශාක පදනම් ප්‍රෝටීන් විවිධත්වය සහ ජීර්ණය සඳහා විශිෂ්ටයි. මෙම සම්ප්‍රදායික ශ්‍රී ලාංකික විකල්ප කුඩා දරුවන්ට පරිපූර්ණයි:',
        'servingGuidelinesContent': 'ඔබේ කුඩා දරුවාට ඔවුන්ගේ කුඩා ගරුත්වය අධිකම නොකර ප්‍රමාණවත් ප්‍රෝටීන් ලැබෙන බව සහතික කිරීමට මෙම මාර්ගෝපදේශ අනුගමනය කරන්න:',
        
        // Animal proteins
        'eggsTitle': 'බිත්තර',
        'eggsDescription': 'කලවම්, තම්බපු හෝ කරියේ',
        'fishTitle': 'මාලු',
        'fishDescription': 'ටූනා හෝ සැමන් කුඩා කැබලි',
        'chickenTitle': 'කුකුළු මස්',
        'chickenDescription': 'මෘදු, හොඳින් පිසින ලද කැබලි',
        'yogurtTitle': 'දැඹරි සහ කිරි නිෂ්පාදන',
        'yogurtDescription': 'සීනි නොමැති ස්වාභාවික දැඹරි',
        
        // Plant-based options
        'lentilsTitle': 'රතු පරිප්ප',
        'lentilsDescription': 'ජීර්ණයට පහසු සහ බහුකාර්ය',
        'chickpeasTitle': 'කඩල',
        'chickpeasDescription': 'තලා හෝ කරියේ',
        'greenGramTitle': 'මුං ආටා',
        'greenGramDescription': 'කදිල හෝ සුප් ලෙස',
        'sesameTitle': 'තල',
        'sesameDescription': 'පේස්ට් බවට අඹරා',
        
        // Serving guidelines
        'dailyPortionsTitle': 'දිනකට කුඩා කොටස් 2-3ක් දෙන්න',
        'dailyPortionsDescription': 'ප්‍රෝටීන් ප්‍රමාණය ආහාර වේල් සහ සුළු කෑම අතරට බෙදන්න',
        'mixingFoodsTitle': 'බත් වැනි හුරුපුරුදු ආහාර සමඟ මිශ්‍ර කරන්න',
        'mixingFoodsDescription': 'වඩා හොඳ පිළිගැනීම සඳහා ප්‍රෝටීන් බත් හෝ පාන් සමඟ ඒකාබද්ධ කරන්න',
        'textureTitle': 'නිසි පිසීම සහ මෘදු වයනය සහතික කරන්න',
        'textureDescription': 'සියලුම ප්‍රෝටීන් හොඳින් පිසින ලද සහ වයසට සුදුසු වයනයක් තිබිය යුතුයි',
        
        // Dietitian tips
        'drEmilyChakma': 'වෛද්‍ය එමිලි චක්‍රමා, ළමා පෝෂණවේදියෙකු',
        'drSamalPerera': 'වෛද්‍ය සමල් පෙරේරා, ළමා වෛද්‍යවරයෙකු',
        'startWithOneEggTip': 'කුඩා දරුවන් සඳහා දිනකට බිත්තරයක් ගෙන් ආරම්භ කරන්න',
        'startWithOneEggTipContent': 'වඩා හොඳ පිළිගැනීම සඳහා බත් සමඟ මිශ්‍ර කර අසාත්මිකතා පරීක්ෂා කිරීමට ක්‍රමයෙන් හඳුන්වා දෙන්න.',
        'introduceProvidesGraduallyTip': 'නව ප්‍රෝටීන් ක්‍රමයෙන් හඳුන්වා දෙන්න',
        'introduceProvidesGraduallyTipContent': '4-6 මාස පමණ වන විට ඔබේ දරුවා ඝන ආහාර සඳහා සූදානම්ව ඇති සංඥා නිරීක්ෂණය කරන්න: හොඳ හිස පාලනය, ආධාරයෙන් වාඩි වීම සහ ආහාර කෙරෙහි උනන්දුව.',
        
        // Related articles
        'firstFoodsForBaby': 'ළදරුවා සඳහා ප්‍රථම ආහාර',
        'healthySnacks': 'සෞඛ්‍යම්‍ය සුළු කෑම',
        'mealPlanning': 'ආහාර සැලසුම්',
      },
      'ta': {
        'proteinSources12To23Title': '12-23 மாத குழந்தைகளுக்கான புரத மூலங்கள்',
        'proteinSources12To23Excerpt': '12-23 மாதங்களுக்கு இடையிலான குழந்தைகளுக்கு வளர்ச்சிக்கு தரமான புரதம் தேவை. இலங்கை குடும்பங்களுக்கான சிறந்த உள்ளூர் புரத மூலங்கள் இங்கே.',
        
        // Section titles
        'introductionTitle': 'புரதம் ஏன் முக்கியம்',
        'animalProteinsTitle': 'விலங்கு புரதங்கள்',
        'plantBasedOptionsTitle': 'தாவர அடிப்படையிலான விருப்பங்கள்',
        'servingGuidelinesTitle': 'பரிமாறும் வழிகாட்டுதல்கள்',
        
        // Content
        'proteinIntroductionContent': '12-23 மாதங்களுக்கு இடையிலான குழந்தைகளுக்கு சரியான வளர்ச்சி மற்றும் மூளை வளர்ச்சிக்கு தரமான புரதம் தேவை. புரதம் தசைகள், உறுப்புகளை உருவாக்க உதவுகிறது மற்றும் நோய் எதிர்ப்பு சக்தியை ஆதரிக்கிறது.',
        'animalProteinsContent': 'விலங்கு புரதங்கள் குழந்தை வளர்ச்சிக்கு அவசியமான முழுமையான அமினோ அமில விவரத்தை வழங்குகின்றன:',
        'plantBasedOptionsContent': 'தாவர அடிப்படையிலான புரதங்கள் பல்வேறு மற்றும் செரிமானத்திற்கு சிறந்தவை. இந்த பாரம்பரிய இலங்கை விருப்பங்கள் குழந்தைகளுக்கு சிறந்தவை:',
        'servingGuidelinesContent': 'உங்கள் குழந்தையின் சிறிய வயிறை அழுத்தாமல் போதுமான புரதம் பெறுவதை உறுதிசெய்ய இந்த வழிகாட்டுதல்களைப் பின்பற்றவும்:',
        
        // Animal proteins
        'eggsTitle': 'முட்டைகள்',
        'eggsDescription': 'கிளறிய, வேகவைத்த அல்லது கறியில்',
        'fishTitle': 'மீன்',
        'fishDescription': 'டுனா அல்லது சால்மன் சிறிய துண்டுகள்',
        'chickenTitle': 'கோழி',
        'chickenDescription': 'மென்மையான, நன்கு சமைத்த துண்டுகள்',
        'yogurtTitle': 'தயிர் மற்றும் பால் பொருட்கள்',
        'yogurtDescription': 'சர்க்கரை சேர்க்காத இயற்கை தயிர்',
        
        // Plant-based options
        'lentilsTitle': 'சிவப்பு பருப்பு (தால்)',
        'lentilsDescription': 'செரிமானம் எளிது மற்றும் பல்துறை',
        'chickpeasTitle': 'கொண்டைக்கடலை',
        'chickpeasDescription': 'பிசைந்த அல்லது கறியில்',
        'greenGramTitle': 'பச்சை பயறு',
        'greenGramDescription': 'கஞ்சி அல்லது சூப் ஆக',
        'sesameTitle': 'எள்',
        'sesameDescription': 'பேஸ்ட் ஆக அரைத்து',
        
        // Serving guidelines
        'dailyPortionsTitle': 'நாளொன்றுக்கு 2-3 சிறிய பகுதிகள் பரிமாறவும்',
        'dailyPortionsDescription': 'புரத உட்கொள்ளல் உணவுகள் மற்றும் தின்பண்டங்களில் பரப்பவும்',
        'mixingFoodsTitle': 'சாதம் போன்ற பழக்கமான உணவுகளுடன் கலக்கவும்',
        'mixingFoodsDescription': 'சிறந்த ஏற்றுக்கொள்ளலுக்காக புரதங்களை சாதம் அல்லது ரொட்டியுடன் சேர்க்கவும்',
        'textureTitle': 'சரியான சமையல் மற்றும் மென்மையான அமைப்பை உறுதிசெய்யவும்',
        'textureDescription': 'அனைத்து புரதங்களும் நன்கு சமைக்கப்பட்ட மற்றும் வயதுக்கு ஏற்ற அமைப்பில் இருக்க வேண்டும்',
        
        // Dietitian tips
        'drEmilyChakma': 'டாக்டர் எமிலி சக்ரமா, குழந்தை ஊட்டச்சத்து நிபுணர்',
        'drSamalPerera': 'டாக்டர் சமல் பெரேரா, குழந்தைகள் மருத்துவர்',
        'startWithOneEggTip': 'குழந்தைகளுக்கு நாளொன்றுக்கு ஒரு முட்டையுடன் தொடங்குங்கள்',
        'startWithOneEggTipContent': 'சிறந்த ஏற்றுக்கொள்ளலுக்காக சாதத்துடன் கலந்து ஒவ்வாமைகளை சரிபார்க்க படிப்படியாக அறிமுகப்படுத்துங்கள்.',
        'introduceProvidesGraduallyTip': 'புதிய புரதங்களை படிப்படியாக அறிமுகப்படுத்துங்கள்',
        'introduceProvidesGraduallyTipContent': '4-6 மாதங்களில் உங்கள் குழந்தை திட உணவுக்கு தயாராக இருப்பதற்கான அறிகுறிகளை கவனியுங்கள்: நல்ல தலை கட்டுப்பாடு, ஆதரவுடன் உட்காருதல், மற்றும் உணவில் ஆர்வம்.',
        
        // Related articles
        'firstFoodsForBaby': 'குழந்தைக்கான முதல் உணவுகள்',
        'healthySnacks': 'ஆரோக்கியமான தின்பண்டங்கள்',
        'mealPlanning': 'உணவு திட்டமிடல்',
      },
    };
    
    return texts[language] ?? texts['en']!;
  }
}