import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/nutrition_content.dart';
import '../providers/child_provider.dart';
import '../utils/responsive_utils.dart';
import '../widgets/safe_ink_well.dart';
import 'nutrition_article_detail_screen.dart';

/// Professional Nutrition Guide screen with Sri Lankan cultural context
class NutritionGuideScreen extends StatefulWidget {
  const NutritionGuideScreen({super.key});

  @override
  State<NutritionGuideScreen> createState() => _NutritionGuideScreenState();
}

class _NutritionGuideScreenState extends State<NutritionGuideScreen>
    with TickerProviderStateMixin {
  String _selectedLanguage = 'en';
  String _selectedAgeGroup = '6-11 months';
  String _selectedCategory = 'healthy_foods';
  final ScrollController _scrollController = ScrollController();
  late TabController _categoryTabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<NutritionArticle> _filteredArticles = [];

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: 4, vsync: this);
    _loadLanguage();
    _autoSelectAgeGroup();
    _loadArticles();
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
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

  /// Auto-select age group based on selected child's age
  void _autoSelectAgeGroup() {
    final provider = Provider.of<ChildProvider>(context, listen: false);
    final selectedChild = provider.selectedChild;

    if (selectedChild != null) {
      final now = DateTime.now();
      final ageInMonths =
          ((now.difference(selectedChild.birthDate).inDays) / 30).round();

      setState(() {
        _selectedAgeGroup = _getAgeGroupForMonths(ageInMonths);
      });
    }
  }

  /// Get appropriate age group based on child's age in months
  String _getAgeGroupForMonths(int months) {
    if (months <= 5) return '0-5 months';
    if (months <= 11) return '6-11 months';
    if (months <= 23) return '12-23 months';
    return '24-59 months';
  }

  /// Load articles based on current filters
  void _loadArticles() {
    setState(() {
      _filteredArticles =
          _getArticlesForAgeAndCategory(_selectedAgeGroup, _selectedCategory);
    });
  }

  /// Filter articles based on search query
  void _filterArticles(String query) {
    if (query.isEmpty) {
      _loadArticles();
      return;
    }

    final texts = _getLocalizedTexts();
    setState(() {
      _filteredArticles =
          _getArticlesForAgeAndCategory(_selectedAgeGroup, _selectedCategory)
              .where((article) =>
                  article
                      .getLocalizedTitle(texts)
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  article
                      .getLocalizedExcerpt(texts)
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  article.tags.any(
                      (tag) => tag.toLowerCase().contains(query.toLowerCase())))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getLocalizedTexts();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(texts),
      body: Column(
        children: [
          _buildStickyAgeDropdown(texts),
          _buildCategoryChips(texts),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadArticles();
              },
              child: _isSearching && _filteredArticles.isEmpty
                  ? _buildEmptySearchResults(texts)
                  : _buildArticleGrid(texts),
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar with search functionality
  PreferredSizeWidget _buildAppBar(Map<String, String> texts) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
                _loadArticles();
              },
            )
          : null,
      automaticallyImplyLeading: !_isSearching,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: texts['searchHint']!,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              style: TextStyle(
                color: const Color(0xFF1A1A1A),
                fontSize: 16,
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
              onChanged: _filterArticles,
            )
          : Text(
              texts['title']!,
              style: TextStyle(
                color: const Color(0xFF1A1A1A),
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1A1A1A)),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
          onPressed: () => _showMoreOptions(context),
        ),
      ],
    );
  }

  /// Build sticky age group dropdown
  Widget _buildStickyAgeDropdown(Map<String, String> texts) {
    return Container(
      color: Colors.white,
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedAgeGroup,
        decoration: InputDecoration(
          labelText: texts['selectAgeGroup']!,
          labelStyle: TextStyle(
            fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        items: [
          '0-5 months',
          '6-11 months',
          '12-23 months',
          '24-59 months',
        ].map((ageGroup) {
          return DropdownMenuItem(
            value: ageGroup,
            child: Text(
              texts[ageGroup.replaceAll(' ', '_').replaceAll('-', '_')]!,
              style: TextStyle(
                fontFamily:
                    _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedAgeGroup = value;
            });
            _loadArticles();
          }
        },
      ),
    );
  }

  /// Build category chips
  Widget _buildCategoryChips(Map<String, String> texts) {
    final categories = [
      {
        'id': 'healthy_foods',
        'icon': Icons.eco,
        'color': const Color(0xFF10B981)
      },
      {
        'id': 'meal_ideas',
        'icon': Icons.restaurant_menu,
        'color': const Color(0xFFF59E0B)
      },
      {
        'id': 'feeding_tips',
        'icon': Icons.lightbulb_outline,
        'color': const Color(0xFF8B5CF6)
      },
      {
        'id': 'common_issues',
        'icon': Icons.help_outline,
        'color': const Color(0xFFEF4444)
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = _selectedCategory == category['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : category['color'] as Color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      texts[category['id'] as String]!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected ? Colors.white : const Color(0xFF374151),
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.white,
                selectedColor: category['color'] as Color,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? category['color'] as Color
                      : const Color(0xFFE5E7EB),
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category['id'] as String;
                  });
                  _loadArticles();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Build article grid
  Widget _buildArticleGrid(Map<String, String> texts) {
    if (_filteredArticles.isEmpty) {
      return _buildEmptyState(texts);
    }

    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveUtils.getResponsiveColumnCount(context),
          crossAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
          mainAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
          childAspectRatio: ResponsiveUtils.isSmallWidth(context) ? 0.75 : 0.8,
        ),
        itemCount: _filteredArticles.length,
        itemBuilder: (context, index) {
          final article = _filteredArticles[index];
          return _buildArticleCard(article, texts);
        },
      ),
    );
  }

  /// Build individual article card
  Widget _buildArticleCard(
      NutritionArticle article, Map<String, String> texts) {
    return Card(
      elevation: ResponsiveUtils.getResponsiveElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context)),
      ),
      child: SafeInkWell(
        onTap: () => _openArticleDetail(article),
        borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context)),
                  topRight: Radius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context)),
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        article.primaryColor.withValues(alpha: 0.1),
                        article.primaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          article.icon,
                          size: ResponsiveUtils.getResponsiveIconSize(
                              context, 48),
                          color: article.primaryColor,
                        ),
                      ),
                      if (article.readTime > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${article.readTime}${texts['minRead']!}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.getLocalizedTitle(texts),
                      style: TextStyle(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                        fontFamily: _selectedLanguage == 'si'
                            ? 'NotoSerifSinhala'
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        article.getLocalizedExcerpt(texts),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context, 12),
                          color: const Color(0xFF6B7280),
                          height: 1.3,
                          fontFamily: _selectedLanguage == 'si'
                              ? 'NotoSerifSinhala'
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  /// Build empty state
  Widget _buildEmptyState(Map<String, String> texts) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            texts['noArticles']!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texts['tryDifferentCategory']!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty search results
  Widget _buildEmptySearchResults(Map<String, String> texts) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            texts['noSearchResults']!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texts['tryDifferentSearch']!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Show more options menu
  void _showMoreOptions(BuildContext context) {
    final texts = _getLocalizedTexts();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: Text(
                texts['savedArticles']!,
                style: TextStyle(
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to saved articles
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: Text(
                texts['feedback']!,
                style: TextStyle(
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Show feedback dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                texts['about']!,
                style: TextStyle(
                  fontFamily:
                      _selectedLanguage == 'si' ? 'NotoSerifSinhala' : null,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Show about dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Open article detail screen
  void _openArticleDetail(NutritionArticle article) {
    final texts = _getLocalizedTexts();

    // Get rich content for specific articles
    NutritionContent? nutritionContent;
    if (article.id == 'protein_sources_12_23m') {
      nutritionContent = NutritionContentDatabase.getProteinSourcesContent();
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NutritionArticleDetailScreen(
          articleId: article.id,
          title: article.getLocalizedTitle(texts),
          content: article.getLocalizedExcerpt(
              texts), // In real app, would load full content
          icon: article.icon,
          primaryColor: article.primaryColor,
          readTime: article.readTime,
          tags: article.tags,
          nutritionContent: nutritionContent,
        ),
      ),
    );
  }

  /// Get articles for specific age group and category
  List<NutritionArticle> _getArticlesForAgeAndCategory(
      String ageGroup, String category) {
    return _getSriLankanNutritionArticles()
        .where((article) =>
            article.ageGroups.contains(ageGroup) &&
            article.categories.contains(category))
        .toList();
  }

  /// Get Sri Lankan nutrition articles database
  List<NutritionArticle> _getSriLankanNutritionArticles() {
    return [
      // 0-5 months articles
      NutritionArticle(
        id: 'bf_benefits',
        titleKey: 'breastfeedingBenefits',
        excerptKey: 'breastfeedingBenefitsExcerpt',
        ageGroups: ['0-5 months'],
        categories: ['healthy_foods', 'feeding_tips'],
        icon: Icons.child_care,
        primaryColor: const Color(0xFF10B981),
        readTime: 5,
        tags: ['breastfeeding', 'immunity', 'bonding'],
      ),
      NutritionArticle(
        id: 'proper_latch',
        titleKey: 'properLatchTechnique',
        excerptKey: 'properLatchTechniqueExcerpt',
        ageGroups: ['0-5 months'],
        categories: ['feeding_tips'],
        icon: Icons.favorite,
        primaryColor: const Color(0xFFEC4899),
        readTime: 7,
        tags: ['breastfeeding', 'technique', 'comfort'],
      ),

      // 6-11 months articles
      NutritionArticle(
        id: 'first_foods_sl',
        titleKey: 'sriLankanFirstFoods',
        excerptKey: 'sriLankanFirstFoodsExcerpt',
        ageGroups: ['6-11 months'],
        categories: ['healthy_foods', 'meal_ideas'],
        icon: Icons.rice_bowl,
        primaryColor: const Color(0xFFF59E0B),
        readTime: 8,
        tags: ['කිරි ගස්', 'කරකැවූන් ගම්මිරිස්', 'first foods', 'weaning'],
      ),
      NutritionArticle(
        id: 'iron_rich_foods',
        titleKey: 'ironRichSriLankanFoods',
        excerptKey: 'ironRichSriLankanFoodsExcerpt',
        ageGroups: ['6-11 months', '12-23 months'],
        categories: ['healthy_foods'],
        icon: Icons.eco,
        primaryColor: const Color(0xFF059669),
        readTime: 6,
        tags: ['මුං ආටා', 'කරකඳ', 'iron', 'anemia prevention'],
      ),

      // 12-23 months articles
      NutritionArticle(
        id: 'family_meals',
        titleKey: 'adaptingFamilyMeals',
        excerptKey: 'adaptingFamilyMealsExcerpt',
        ageGroups: ['12-23 months', '24-59 months'],
        categories: ['meal_ideas', 'feeding_tips'],
        icon: Icons.family_restroom,
        primaryColor: const Color(0xFF8B5CF6),
        readTime: 10,
        tags: ['family meals', 'කරවල', 'පරිප්ප', 'self-feeding'],
      ),
      NutritionArticle(
        id: 'picky_eating',
        titleKey: 'dealingWithPickyEating',
        excerptKey: 'dealingWithPickyEatingExcerpt',
        ageGroups: ['12-23 months', '24-59 months'],
        categories: ['common_issues', 'feeding_tips'],
        icon: Icons.psychology,
        primaryColor: const Color(0xFFEF4444),
        readTime: 12,
        tags: ['picky eating', 'behavior', 'variety'],
      ),

      // Traditional Sri Lankan foods
      NutritionArticle(
        id: 'traditional_porridges',
        titleKey: 'traditionalSriLankanPorridges',
        excerptKey: 'traditionalSriLankanPorridgesExcerpt',
        ageGroups: ['6-11 months', '12-23 months'],
        categories: ['healthy_foods', 'meal_ideas'],
        icon: Icons.soup_kitchen,
        primaryColor: const Color(0xFF0891B2),
        readTime: 15,
        tags: ['කොල කොළ', 'කිරි ගස්', 'porridge', 'traditional'],
      ),
      NutritionArticle(
        id: 'local_fruits',
        titleKey: 'sriLankanFruitsForBabies',
        excerptKey: 'sriLankanFruitsForBabiesExcerpt',
        ageGroups: ['6-11 months', '12-23 months', '24-59 months'],
        categories: ['healthy_foods'],
        icon: Icons.apple,
        primaryColor: const Color(0xFFDC2626),
        readTime: 8,
        tags: ['කිරි ගස්', 'පේර', 'අරනේ', 'fruits', 'vitamins'],
      ),

      // Common feeding issues
      NutritionArticle(
        id: 'feeding_difficulties',
        titleKey: 'commonFeedingDifficulties',
        excerptKey: 'commonFeedingDifficultiesExcerpt',
        ageGroups: ['6-11 months', '12-23 months'],
        categories: ['common_issues'],
        icon: Icons.help_center,
        primaryColor: const Color(0xFFB91C1C),
        readTime: 9,
        tags: ['feeding problems', 'solutions', 'professional help'],
      ),

      // Protein sources for 12-23 months
      NutritionArticle(
        id: 'protein_sources_12_23m',
        titleKey: 'proteinSources12To23Title',
        excerptKey: 'proteinSources12To23Excerpt',
        ageGroups: ['12-23 months'],
        categories: ['healthy_foods', 'meal_ideas'],
        icon: Icons.fitness_center,
        primaryColor: const Color(0xFFEA580C),
        readTime: 8,
        tags: [
          'protein',
          'කිරි ගස්',
          'මුං ආටා',
          'animal protein',
          'plant protein'
        ],
      ),
    ];
  }

  /// Get localized texts
  Map<String, String> _getLocalizedTexts() {
    final Map<String, Map<String, String>> texts = {
      'en': {
        'title': 'Nutrition Guide',
        'searchHint': 'Search nutrition tips, foods...',
        'selectAgeGroup': 'Select Age Group',
        '0_5_months': '0-5 months (Breastfeeding)',
        '6_11_months': '6-11 months (First Foods)',
        '12_23_months': '12-23 months (Toddler)',
        '24_59_months': '24-59 months (Preschooler)',
        'healthy_foods': 'Healthy Foods',
        'meal_ideas': 'Meal Ideas',
        'feeding_tips': 'Feeding Tips',
        'common_issues': 'Common Issues',
        'minRead': ' min read',
        'noArticles': 'No articles found',
        'tryDifferentCategory': 'Try selecting a different category',
        'noSearchResults': 'No search results',
        'tryDifferentSearch': 'Try different search terms',
        'savedArticles': 'Saved Articles',
        'feedback': 'Send Feedback',
        'about': 'About Nutrition Guide',

        // Article titles and excerpts
        'breastfeedingBenefits': 'Benefits of Exclusive Breastfeeding',
        'breastfeedingBenefitsExcerpt':
            'Learn about the incredible benefits of breast milk for Sri Lankan babies in their first 6 months.',
        'properLatchTechnique': 'Proper Breastfeeding Latch',
        'properLatchTechniqueExcerpt':
            'Step-by-step guide to achieving comfortable and effective breastfeeding.',
        'sriLankanFirstFoods': 'Sri Lankan First Foods Guide',
        'sriLankanFirstFoodsExcerpt':
            'Traditional Lankan foods perfect for introducing solids: කිරි ගස්, rice water, and safe preparations.',
        'ironRichSriLankanFoods': 'Iron-Rich Lankan Foods',
        'ironRichSriLankanFoodsExcerpt':
            'Prevent anemia with locally available iron sources like මුං ආටා and කරකඳ.',
        'adaptingFamilyMeals': 'Adapting Family Rice & Curry',
        'adaptingFamilyMealsExcerpt':
            'How to modify traditional කරවල and පරිප්ප for toddlers safely.',
        'dealingWithPickyEating': 'Overcoming Picky Eating',
        'dealingWithPickyEatingExcerpt':
            'Practical strategies for encouraging variety in your child\'s diet.',
        'traditionalSriLankanPorridges': 'Traditional Lankan Porridges',
        'traditionalSriLankanPorridgesExcerpt':
            'Nutritious කොල කේඩ recipes perfect for growing babies.',
        'sriLankanFruitsForBabies': 'Local Fruits for Babies',
        'sriLankanFruitsForBabiesExcerpt':
            'Safe ways to introduce කිරි ගස්, පේර, and අරනේ to your little one.',
        'commonFeedingDifficulties': 'Feeding Problem Solutions',
        'commonFeedingDifficultiesExcerpt':
            'Expert advice for overcoming common feeding challenges in Sri Lankan context.',
        'proteinSources12To23Title': 'Protein Sources for 12-23 Month Kids',
        'proteinSources12To23Excerpt':
            'Complete guide to animal proteins, plant-based options, and serving guidelines with Sri Lankan traditional foods.',
      },
      'si': {
        'title': 'පෝෂණ මාර්ගෝපදේශය',
        'searchHint': 'පෝෂණ උපදෙස්, ආහාර සොයන්න...',
        'selectAgeGroup': 'වයස් කාණ්ඩය තෝරන්න',
        '0_5_months': '0-5 මාස (මව්කිරි)',
        '6_11_months': '6-11 මාස (ප්‍රථම ආහාර)',
        '12_23_months': '12-23 මාස (කුඩා දරුවන්)',
        '24_59_months': '24-59 මාස (පෙර පාසල්)',
        'healthy_foods': 'සෞඛ්‍ය ආහාර',
        'meal_ideas': 'ආහාර අදහස්',
        'feeding_tips': 'පෝෂණ උපදෙස්',
        'common_issues': 'පොදු ගැටලු',
        'minRead': ' මිනිත්තු',
        'noArticles': 'ලිපි හමු නොවිය',
        'tryDifferentCategory': 'වෙනත් කාණ්ඩයක් තෝරා බලන්න',
        'noSearchResults': 'සෙවීම් ප්‍රතිඵල නැත',
        'tryDifferentSearch': 'වෙනත් සෙවුම් වචන උත්සාහ කරන්න',
        'savedArticles': 'සුරකින ලද ලිපි',
        'feedback': 'ප්‍රතිපෝෂණ යවන්න',
        'about': 'පෝෂණ මාර්ගෝපදේශය පිළිබඳ',

        // Article titles and excerpts
        'breastfeedingBenefits': 'විශේෂිත මව්කිරි පාන ප්‍රතිලාභ',
        'breastfeedingBenefitsExcerpt':
            'ශ්‍රී ලාංකික ළදරුවන්ට මව්කිරි දීමේ අප්‍රතිම ප්‍රතිලාභ ගැන ඉගෙන ගන්න.',
        'properLatchTechnique': 'නිවැරදි මව්කිරි දීමේ ක්‍රමය',
        'properLatchTechniqueExcerpt':
            'සුවපහසු හා ඵලදායී මව්කිරි දීම සඳහා පියවරෙන් පියවර මාර්ගෝපදේශය.',
        'sriLankanFirstFoods': 'ශ්‍රී ලාංකික ප්‍රථම ආහාර මාර්ගෝපදේශය',
        'sriLankanFirstFoodsExcerpt':
            'ඝන ආහාර හඳුන්වා දීම සඳහා සම්ප්‍රදායික ලාංකික ආහාර: කිරි ගස්, බත් වතුර සහ ආරක්ෂිත සැකසීම්.',
        'ironRichSriLankanFoods': 'යකඩ බහුල ලාංකික ආහාර',
        'ironRichSriLankanFoodsExcerpt':
            'මුං ආටා සහ කරකඳ වැනි දේශීයව ලබා ගත හැකි යකඩ ප්‍රභවයන් සමඟ රක්තහීනතාවය වළක්වන්න.',
        'adaptingFamilyMeals': 'පවුලේ බත් කරී අනුවර්තනය',
        'adaptingFamilyMealsExcerpt':
            'කුඩා දරුවන් සඳහා සම්ප්‍රදායික කරවල සහ පරිප්ප ආරක්ෂිතව වෙනස් කරන්නේ කෙසේද.',
        'dealingWithPickyEating': 'ආහාර තේරීමේ ගැටලු ජයගැනීම',
        'dealingWithPickyEatingExcerpt':
            'ඔබේ දරුවාගේ ආහාර වේලේ විවිධත්වය දිරිමත් කිරීම සඳහා ප්‍රායෝගික උපාය මාර්ග.',
        'traditionalSriLankanPorridges': 'සම්ප්‍රදායික ලාංකික කොල කේඩ',
        'traditionalSriLankanPorridgesExcerpt':
            'වැඩෙන ළදරුවන් සඳහා පෝෂ්‍යදායී කොල කේඩ වට්ටෝරු.',
        'sriLankanFruitsForBabies': 'ළදරුවන් සඳහා දේශීය පලතුරු',
        'sriLankanFruitsForBabiesExcerpt':
            'ඔබේ කුඩා දරුවාට කිරි ගස්, පේර, සහ අරනේ හඳුන්වා දීමේ ආරක්ෂිත ක්‍රම.',
        'commonFeedingDifficulties': 'ආහාර ගැටලු විසඳුම්',
        'commonFeedingDifficultiesExcerpt':
            'ශ්‍රී ලාංකික සන්දර්භය තුළ පොදු ආහාර දීමේ අභියෝග ජයගැනීම සඳහා ප්‍රවීණ උපදෙස්.',
        'proteinSources12To23Title':
            '12-23 මාස වයස් දරුවන් සඳහා ප්‍රෝටීන් ප්‍රභව',
        'proteinSources12To23Excerpt':
            'සත්ව ප්‍රෝටීන්, ශාක ජාතීය විකල්ප, සහ ශ්‍රී ලාංකික සම්ප්‍රදායික ආහාර සමඟ සේවන මාර්ගෝපදේශය.',
      },
      'ta': {
        'title': 'ஊட்டச்சத்து வழிகாட்டி',
        'searchHint': 'ஊட்டச்சத்து குறிப்புகள், உணவுகளை தேடுங்கள்...',
        'selectAgeGroup': 'வயது குழுவை தேர்ந்தெடுக்கவும்',
        '0_5_months': '0-5 மாதங்கள் (தாய்ப்பால்)',
        '6_11_months': '6-11 மாதங்கள் (முதல் உணவுகள்)',
        '12_23_months': '12-23 மாதங்கள் (சிறு குழந்தை)',
        '24_59_months': '24-59 மாதங்கள் (பள்ளிக்கு முந்தைய)',
        'healthy_foods': 'ஆரோக்கியமான உணவுகள்',
        'meal_ideas': 'உணவு யோசனைகள்',
        'feeding_tips': 'உணவளிக்கும் குறிப்புகள்',
        'common_issues': 'பொதுவான பிரச்சினைகள்',
        'minRead': ' நிமிடம் படிப்பு',
        'noArticles': 'கட்டுரைகள் கிடைக்கவில்லை',
        'tryDifferentCategory': 'வேறு வகையை தேர்ந்தெடுத்து முயற்சி செய்யுங்கள்',
        'noSearchResults': 'தேடல் முடிவுகள் இல்லை',
        'tryDifferentSearch': 'வேறு தேடல் சொற்களை முயற்சி செய்யுங்கள்',
        'savedArticles': 'சேமிக்கப்பட்ட கட்டுரைகள்',
        'feedback': 'கருத்து அனுப்பவும்',
        'about': 'ஊட்டச்சத்து வழிகாட்டி பற்றி',

        // Article titles and excerpts
        'breastfeedingBenefits': 'பிரத்யேக தாய்ப்பாலின் நன்மைகள்',
        'breastfeedingBenefitsExcerpt':
            'இலங்கை குழந்தைகளுக்கு தாய்ப்பாலின் அற்புதமான நன்மைகளைப் பற்றி அறியுங்கள்.',
        'properLatchTechnique': 'சரியான தாய்ப்பால் கொடுக்கும் முறை',
        'properLatchTechniqueExcerpt':
            'வசதியான மற்றும் திறமையான தாய்ப்பால் கொடுப்பதற்கான படிப்படியான வழிகாட்டி.',
        'sriLankanFirstFoods': 'இலங்கை முதல் உணவுகள் வழிகாட்டி',
        'sriLankanFirstFoodsExcerpt':
            'திட உணவுகளை அறிமுகப்படுத்துவதற்கான பாரம்பரிய இலங்கை உணவுகள்: கிரி கஸ், சாதம் தண்ணீர், மற்றும் பாதுகாப்பான தயாரிப்புகள்.',
        'ironRichSriLankanFoods': 'இரும்புச்சத்து நிறைந்த இலங்கை உணவுகள்',
        'ironRichSriLankanFoodsExcerpt':
            'மூங் ஆடா மற்றும் கரகட் போன்ற உள்நாட்டில் கிடைக்கும் இரும்பு மூலங்களுடன் இரத்த சோகையைத் தடுக்கவும்.',
        'adaptingFamilyMeals': 'குடும்ப சாதம் மற்றும் கறியை மாற்றியமைத்தல்',
        'adaptingFamilyMealsExcerpt':
            'குழந்தைகளுக்கு பாரம்பரிய கரவல் மற்றும் பரிப்பை பாதுகாப்பாக மாற்றுவது எப்படி.',
        'dealingWithPickyEating':
            'தேர்ந்தெடுத்து சாப்பிடும் பழக்கத்தை சமாளித்தல்',
        'dealingWithPickyEatingExcerpt':
            'உங்கள் குழந்தையின் உணவில் பல்வேறு வகைகளை ஊக்குவிப்பதற்கான நடைமுறை உத்திகள்.',
        'traditionalSriLankanPorridges': 'பாரம்பரிய இலங்கை கஞ்சி',
        'traditionalSriLankanPorridgesExcerpt':
            'வளரும் குழந்தைகளுக்கு ஏற்ற சத்தான கொல் கேட வகைகள்.',
        'sriLankanFruitsForBabies': 'குழந்தைகளுக்கான உள்ளூர் பழங்கள்',
        'sriLankanFruitsForBabiesExcerpt':
            'உங்கள் சிறு குழந்தைக்கு கிரி கஸ், பேர், மற்றும் அரனே அறிமுகப்படுத்தும் பாதுகாப்பான வழிகள்.',
        'commonFeedingDifficulties': 'உணவு பிரச்சினை தீர்வுகள்',
        'commonFeedingDifficultiesExcerpt':
            'இலங்கை சூழலில் பொதுவான உணவு கொடுக்கும் சவால்களை சமாளிப்பதற்கான நிபுணர் அறிவுரை.',
        'proteinSources12To23Title': '12-23 மாத குழந்தைகளுக்கான புரத ஆதாரங்கள்',
        'proteinSources12To23Excerpt':
            'விலங்கு புரதங்கள், தாவர அடிப்படையிலான விருப்பங்கள், மற்றும் இலங்கை பாரம்பரிய உணவுகளுடன் வழங்கும் வழிகாட்டுதல்கள்.',
      },
    };
    return texts[_selectedLanguage] ?? texts['en']!;
  }
}

/// Nutrition article model
class NutritionArticle {
  final String id;
  final String titleKey;
  final String excerptKey;
  final List<String> ageGroups;
  final List<String> categories;
  final IconData icon;
  final Color primaryColor;
  final int readTime;
  final List<String> tags;

  NutritionArticle({
    required this.id,
    required this.titleKey,
    required this.excerptKey,
    required this.ageGroups,
    required this.categories,
    required this.icon,
    required this.primaryColor,
    required this.readTime,
    required this.tags,
  });

  String getLocalizedTitle(Map<String, String> texts) {
    return texts[titleKey] ?? titleKey;
  }

  String getLocalizedExcerpt(Map<String, String> texts) {
    return texts[excerptKey] ?? excerptKey;
  }
}
