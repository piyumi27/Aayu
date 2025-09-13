import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/article.dart';
import '../services/article_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/article_card.dart';
import '../widgets/category_grid.dart';
import '../widgets/notifications/notification_badge.dart';
import 'article_detail_screen.dart';
import 'category_articles_screen.dart';

/// Learn screen with offline blog system
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  List<Article> featuredArticles = [];
  List<Article> recentArticles = [];
  Map<String, int> categoryArticleCounts = {};
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  List<Article> searchResults = [];
  bool isSearching = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load articles in parallel
      final futures = await Future.wait([
        ArticleService.getFeaturedArticles(),
        ArticleService.loadAllArticles(),
      ]);

      final featured = futures[0];
      final allArticles = futures[1];

      // Calculate category counts
      final counts = <String, int>{};
      for (final article in allArticles) {
        counts[article.category] = (counts[article.category] ?? 0) + 1;
      }

      // Get recent articles
      final recent = allArticles.take(10).toList();

      setState(() {
        featuredArticles = featured;
        recentArticles = recent;
        categoryArticleCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) async {
    setState(() {
      searchQuery = query;
      isSearching = query.isNotEmpty;
    });

    if (query.isNotEmpty) {
      try {
        final results = await ArticleService.searchArticles(query);
        setState(() {
          searchResults = results;
        });
      } catch (e) {
        // Handle search error
        setState(() {
          searchResults = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Learn',
          style: GoogleFonts.notoSerifSinhala(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          SmartNotificationBadge(
            child: IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: ResponsiveUtils.getResponsiveIconSize(context, 24),
              ),
              tooltip: 'Notifications',
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            ResponsiveUtils.getResponsiveSpacing(context, 120),
          ),
          child: Column(
            children: [
              // Search bar
              Container(
                margin: ResponsiveUtils.getResponsivePadding(context),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search articles, topics, or categories...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _onSearchChanged(''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                    ),
                    fillColor: theme.colorScheme.surface,
                    filled: true,
                  ),
                ),
              ),

              // Tab bar (only show if not searching)
              if (!isSearching)
                TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor:
                      theme.colorScheme.onSurface.withOpacity(0.6),
                  indicatorColor: theme.colorScheme.primary,
                  labelStyle: GoogleFonts.notoSerifSinhala(
                    fontWeight: FontWeight.w600,
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 16),
                  ),
                  tabs: const [
                    Tab(text: 'Featured'),
                    Tab(text: 'Categories'),
                    Tab(text: 'Recent'),
                  ],
                ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadContent,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? _buildErrorWidget()
                : isSearching
                    ? _buildSearchResults()
                    : _buildTabContent(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final theme = Theme.of(context);

    return ResponsiveLayout(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.getResponsiveIconSize(context, 64),
              color: theme.colorScheme.error,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Text(
              'Failed to load articles',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Text(
              error ?? 'Unknown error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            ElevatedButton(
              onPressed: _loadContent,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final theme = Theme.of(context);

    return ResponsiveLayout(
      child: searchResults.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: ResponsiveUtils.getResponsiveIconSize(context, 64),
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context, 16)),
                  Text(
                    'No articles found',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                  Text(
                    'Try adjusting your search terms',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: ResponsiveUtils.getResponsivePadding(context),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final article = searchResults[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  ),
                  child: ArticleCard(
                    article: article,
                    onTap: () => _navigateToArticle(article.id),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildFeaturedTab(),
        _buildCategoriesTab(),
        _buildRecentTab(),
      ],
    );
  }

  Widget _buildFeaturedTab() {
    if (featuredArticles.isEmpty) {
      return _buildEmptyState('No featured articles available');
    }

    return ResponsiveLayout(
      child: ListView.builder(
        padding: ResponsiveUtils.getResponsivePadding(context),
        itemCount: featuredArticles.length,
        itemBuilder: (context, index) {
          final article = featuredArticles[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
            ),
            child: ArticleCard(
              article: article,
              showFeaturedBadge: false, // Already in featured section
              onTap: () => _navigateToArticle(article.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return ResponsiveLayout(
      child: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse by Category',
              style: GoogleFonts.notoSerifSinhala(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            CategoryGrid(
              categories: ArticleCategory.defaultCategories,
              onCategoryTap: _navigateToCategory,
              articleCounts: categoryArticleCounts,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTab() {
    if (recentArticles.isEmpty) {
      return _buildEmptyState('No recent articles available');
    }

    return ResponsiveLayout(
      child: ListView.builder(
        padding: ResponsiveUtils.getResponsivePadding(context),
        itemCount: recentArticles.length,
        itemBuilder: (context, index) {
          final article = recentArticles[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
            ),
            child: ArticleCard(
              article: article,
              compact: true,
              onTap: () => _navigateToArticle(article.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final theme = Theme.of(context);

    return ResponsiveLayout(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: ResponsiveUtils.getResponsiveIconSize(context, 64),
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToArticle(String articleId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(
          articleId: articleId,
        ),
      ),
    );
  }

  void _navigateToCategory(ArticleCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryArticlesScreen(
          category: category,
        ),
      ),
    );
  }
}
