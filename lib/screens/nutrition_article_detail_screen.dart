import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/nutrition_content.dart';
import '../utils/responsive_utils.dart';

/// Professional nutrition article detail screen with Sri Lankan content
class NutritionArticleDetailScreen extends StatefulWidget {
  final String articleId;
  final String title;
  final String content;
  final IconData icon;
  final Color primaryColor;
  final int readTime;
  final List<String> tags;
  final NutritionContent? nutritionContent;

  const NutritionArticleDetailScreen({
    super.key,
    required this.articleId,
    required this.title,
    required this.content,
    required this.icon,
    required this.primaryColor,
    required this.readTime,
    required this.tags,
    this.nutritionContent,
  });

  @override
  State<NutritionArticleDetailScreen> createState() =>
      _NutritionArticleDetailScreenState();
}

class _NutritionArticleDetailScreenState
    extends State<NutritionArticleDetailScreen> {
  String _selectedLanguage = 'en';
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _loadBookmarkStatus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Load user language preference
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('selected_language') ?? 'en';
      });
    }
  }

  /// Load bookmark status for this article
  Future<void> _loadBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_articles') ?? [];
    if (mounted) {
      setState(() {
        _isBookmarked = bookmarks.contains(widget.articleId);
      });
    }
  }

  /// Toggle bookmark status
  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarked_articles') ?? [];

    if (_isBookmarked) {
      bookmarks.remove(widget.articleId);
    } else {
      bookmarks.add(widget.articleId);
    }

    await prefs.setStringList('bookmarked_articles', bookmarks);

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    // Show snackbar feedback
    final texts = _getLocalizedTexts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? texts['bookmarkAdded']! : texts['bookmarkRemoved']!,
            style: TextStyle(
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Share article
  void _shareArticle() {
    // Implement sharing functionality
    final texts = _getLocalizedTexts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          texts['shareFeatureComingSoon']!,
          style: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedTexts();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(texts),
          SliverToBoxAdapter(
            child: _buildArticleContent(texts),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(texts),
    );
  }

  /// Build sliver app bar with hero image
  Widget _buildSliverAppBar(Map<String, String> texts) {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.isSmallHeight(context) ? 200 : 250,
      pinned: true,
      stretch: true,
      backgroundColor: widget.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          onPressed: _toggleBookmark,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _shareArticle,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.primaryColor,
                widget.primaryColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                    height: 60), // Account for status bar and app bar
                Icon(
                  widget.icon,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 64),
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.readTime} ${texts['minRead']!}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build article content
  Widget _buildArticleContent(Map<String, String> texts) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 24),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                    height: 1.3,
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTagsRow(),
                const SizedBox(height: 24),
                if (widget.nutritionContent != null)
                  ..._buildRichContent()
                else
                  _buildArticleBody(),
                const SizedBox(height: 32),
                if (widget.nutritionContent == null) _buildRelatedTips(texts),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build tags row
  Widget _buildTagsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: widget.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: widget.primaryColor,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build article body content
  Widget _buildArticleBody() {
    // This would typically load rich content from a database
    // For demo purposes, showing structured content based on article type
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContentSection(
          'Introduction',
          'Proper nutrition during the first few years of life is crucial for optimal growth and development. Sri Lankan traditional foods offer excellent nutritional value when prepared appropriately for young children.',
        ),
        const SizedBox(height: 20),
        _buildContentSection(
          'Key Points',
          '• Always introduce new foods gradually\n• Use locally available ingredients like කිරි ගස් and මුං ආටා\n• Ensure proper cooking and hygiene\n• Monitor for allergic reactions\n• Maintain exclusive breastfeeding for first 6 months',
        ),
        const SizedBox(height: 20),
        _buildContentSection(
          'Preparation Tips',
          'When preparing traditional foods for babies, always ensure proper washing, cooking, and cooling. Mash or puree foods to appropriate consistency for your child\'s age and development stage.',
        ),
        const SizedBox(height: 20),
        _buildWarningBox(),
      ],
    );
  }

  /// Build content section
  Widget _buildContentSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
            color: const Color(0xFF4B5563),
            height: 1.6,
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
      ],
    );
  }

  /// Build warning/important info box
  Widget _buildWarningBox() {
    final texts = _getLocalizedTexts();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFF59E0B),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texts['importantNote']!,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w500,
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build related tips section
  Widget _buildRelatedTips(Map<String, String> texts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texts['relatedTips']!,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          Icons.schedule,
          texts['timingTip']!,
          texts['timingTipContent']!,
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          Icons.health_and_safety,
          texts['safetyTip']!,
          texts['safetyTipContent']!,
        ),
      ],
    );
  }

  /// Build individual tip card
  Widget _buildTipCard(IconData icon, String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: widget.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontFamily:
                        _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom action bar
  Widget _buildBottomActionBar(Map<String, String> texts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Navigate to related articles
              },
              icon: const Icon(Icons.library_books),
              label: Text(texts['moreArticles']!),
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.primaryColor,
                side: BorderSide(color: widget.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                // Navigate to tracking/measurement screen
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.add_circle_outline),
              label: Text(texts['trackProgress']!),
              style: FilledButton.styleFrom(
                backgroundColor: widget.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get localized texts
  Map<String, String> _getLocalizedTexts() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'minRead': 'min read',
        'bookmarkAdded': 'Article bookmarked',
        'bookmarkRemoved': 'Bookmark removed',
        'shareFeatureComingSoon': 'Sharing feature coming soon',
        'importantNote':
            'Important: Always consult with your pediatrician before making significant changes to your child\'s diet, especially if they have any health conditions or allergies.',
        'relatedTips': 'Related Tips',
        'timingTip': 'Timing Matters',
        'timingTipContent':
            'Introduce new foods when your child is alert and hungry, but not overly tired.',
        'safetyTip': 'Food Safety',
        'safetyTipContent':
            'Always ensure proper food hygiene and age-appropriate textures to prevent choking.',
        'moreArticles': 'More Articles',
        'trackProgress': 'Track Progress',
      },
      'si': {
        'minRead': 'මිනිත්තු',
        'bookmarkAdded': 'ලිපිය සටහන් කරන ලදී',
        'bookmarkRemoved': 'සටහන ඉවත් කරන ලදී',
        'shareFeatureComingSoon': 'බෙදාගැනීමේ විශේෂාංගය ළඟදීම',
        'importantNote':
            'වැදගත්: ඔබේ දරුවාගේ ආහාර වේලට සැලකිය යුතු වෙනස්කම් කිරීමට පෙර, විශේෂයෙන්ම ඔවුන්ට සෞඛ්‍ය තත්වයන් හෝ අසාත්මිකතා තිබේ නම්, සැමවිටම ඔබේ ළමා වෛද්‍යවරයා සමඟ සාකච්ඡා කරන්න.',
        'relatedTips': 'අදාළ උපදෙස්',
        'timingTip': 'වේලාව වැදගත්',
        'timingTipContent':
            'ඔබේ දරුවා අවදියෙන් හා බඩගිනියෙන් සිටින විට නව ආහාර හඳුන්වා දෙන්න, නමුත් අධික ලෙස වෙහෙසට පත් නොවන විට.',
        'safetyTip': 'ආහාර ආරක්ෂාව',
        'safetyTipContent':
            'හුස්ම හිරවීම වැළැක්වීම සඳහා සැමවිටම නිසි ආහාර සනීපාරක්ෂාව සහ වයසට සුදුසු වයනය සහතික කරන්න.',
        'moreArticles': 'තවත් ලිපි',
        'trackProgress': 'ප්‍රගතිය නිරීක්ෂණය',
      },
      'ta': {
        'minRead': 'நிமிடம்',
        'bookmarkAdded': 'கட்டுரை புத்தகக்குறியிடப்பட்டது',
        'bookmarkRemoved': 'புத்தகக்குறி அகற்றப்பட்டது',
        'shareFeatureComingSoon': 'பகிர்வு அம்சம் விரைவில் வருகிறது',
        'importantNote':
            'முக்கியம்: உங்கள் குழந்தையின் உணவில் குறிப்பிடத்தக்க மாற்றங்களைச் செய்வதற்கு முன், குறிப்பாக அவர்களுக்கு ஏதேனும் சுகாதார நிலைமைகள் அல்லது ஒவ்வாமைகள் இருந்தால், எப்போதும் உங்கள் குழந்தை மருத்துவரிடம் ஆலோசித்துக் கொள்ளுங்கள்.',
        'relatedTips': 'தொடர்புடைய குறிப்புகள்',
        'timingTip': 'நேரம் முக்கியம்',
        'timingTipContent':
            'உங்கள் குழந்தை எச்சரிக்கையாகவும் பசியாகவும் இருக்கும்போது புதிய உணவுகளை அறிமுகப்படுத்துங்கள், ஆனால் அதிகமாக சோர்வடையாத போது.',
        'safetyTip': 'உணவு பாதுகாப்பு',
        'safetyTipContent':
            'மூச்சு திணறலைத் தடுக்க எப்போதும் சரியான உணவு சுகாதாரம் மற்றும் வயதுக்கு ஏற்ற அமைப்புகளை உறுதிப்படுத்துங்கள்.',
        'moreArticles': 'மேலும் கட்டுரைகள்',
        'trackProgress': 'முன்னேற்றத்தைக் கண்காணிக்கவும்',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }

  /// Build rich content sections from NutritionContent model
  List<Widget> _buildRichContent() {
    if (widget.nutritionContent == null) return [];

    List<Widget> widgets = [];

    // Add content sections
    for (var section in widget.nutritionContent!.sections) {
      widgets.add(_buildRichContentSection(section));
      widgets.add(const SizedBox(height: 24));
    }

    // Add dietitian tips
    if (widget.nutritionContent!.dietitianTips.isNotEmpty) {
      for (var tip in widget.nutritionContent!.dietitianTips) {
        widgets.add(_buildDietitianTip(tip));
        widgets.add(const SizedBox(height: 16));
      }
    }

    // Add related articles
    if (widget.nutritionContent!.relatedArticles.isNotEmpty) {
      widgets.add(_buildRelatedArticles());
    }

    return widgets;
  }

  /// Build rich content section with different types
  Widget _buildRichContentSection(ContentSection section) {
    final theme = Theme.of(context);

    String sectionTitle = '';
    IconData sectionIcon = Icons.restaurant;
    Color sectionColor = widget.primaryColor;

    switch (section.type) {
      case ContentSectionType.animalProteins:
        sectionTitle = 'Animal Proteins';
        sectionIcon = Icons.pets;
        sectionColor = Colors.orange;
        break;
      case ContentSectionType.plantBasedOptions:
        sectionTitle = 'Plant-Based Options';
        sectionIcon = Icons.eco;
        sectionColor = Colors.green;
        break;
      case ContentSectionType.servingGuidelines:
        sectionTitle = 'Serving Guidelines';
        sectionIcon = Icons.schedule;
        sectionColor = Colors.blue;
        break;
      case ContentSectionType.introduction:
        sectionTitle = 'Introduction';
        sectionIcon = Icons.info;
        sectionColor = widget.primaryColor;
        break;
      case ContentSectionType.preparationTips:
        sectionTitle = 'Preparation Tips';
        sectionIcon = Icons.kitchen;
        sectionColor = Colors.purple;
        break;
      case ContentSectionType.safetyGuidelines:
        sectionTitle = 'Safety Guidelines';
        sectionIcon = Icons.security;
        sectionColor = Colors.red;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                sectionColor.withValues(alpha: 0.1),
                sectionColor.withValues(alpha: 0.05)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: sectionColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                sectionIcon,
                color: sectionColor,
                size: ResponsiveUtils.getResponsiveIconSize(context, 24),
              ),
              const SizedBox(width: 12),
              Text(
                sectionTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: sectionColor.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section Content
        if (section.servingGuidelines != null)
          _buildServingGuidelinesList(section.servingGuidelines!)
        else if (section.foodItems != null)
          _buildFoodItemsList(section.foodItems!, sectionColor),
      ],
    );
  }

  /// Build food items list
  Widget _buildFoodItemsList(List<FoodItem> foodItems, Color sectionColor) {
    final theme = Theme.of(context);

    return Column(
      children: foodItems
          .map((food) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: sectionColor.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: sectionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            food.nameKey, // Using nameKey for now, should be localized
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 16),
                              fontFamily: _selectedLanguage == 'si'
                                  ? 'NotoSerifSinhala'
                                  : null,
                            ),
                          ),
                        ),
                        if (food.sinhalaName != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${food.sinhalaName})',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 14),
                              fontFamily: _selectedLanguage == 'si'
                                  ? 'NotoSerifSinhala'
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      food.descriptionKey, // Using descriptionKey for now, should be localized
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 14),
                        height: 1.5,
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                    if (food.benefits.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                food.benefits.join(', '), // Join benefits list
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade700,
                                  fontSize:
                                      ResponsiveUtils.getResponsiveFontSize(
                                          context, 12),
                                  fontFamily: _selectedLanguage == 'si'
                                      ? 'NotoSerifSinhala'
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ))
          .toList(),
    );
  }

  /// Build serving guidelines list
  Widget _buildServingGuidelinesList(List<ServingGuideline> guidelines) {
    final theme = Theme.of(context);

    return Column(
      children: guidelines.map((guideline) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: guideline.color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: guideline.color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                guideline.icon,
                color: guideline.color,
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guideline
                          .titleKey, // Using titleKey for now, should be localized
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 14),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guideline
                          .descriptionKey, // Using descriptionKey for now, should be localized
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 13),
                        height: 1.4,
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
        );
      }).toList(),
    );
  }

  /// Build dietitian tip box
  Widget _buildDietitianTip(DietitianTip tip) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tip.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber.shade700,
                size: ResponsiveUtils.getResponsiveIconSize(context, 20),
              ),
              const SizedBox(width: 8),
              Text(
                tip.titleKey, // Using titleKey for now, should be localized
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.amber.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tip.contentKey, // Using contentKey for now, should be localized
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.amber.shade800,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              height: 1.5,
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '- ${tip.authorKey}', // Using authorKey for now, should be localized
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.amber.shade700,
              fontStyle: FontStyle.italic,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Build related articles carousel
  Widget _buildRelatedArticles() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Articles',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.nutritionContent!.relatedArticles.length,
            itemBuilder: (context, index) {
              final article = widget.nutritionContent!.relatedArticles[index];

              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article
                          .titleKey, // Using titleKey for now, should be localized
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 14),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${article.readTime} min read',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 12),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to related article
                        },
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Read →'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
