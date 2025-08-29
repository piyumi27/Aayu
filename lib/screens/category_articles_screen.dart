import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/article.dart';
import '../services/article_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/article_card.dart';
import 'article_detail_screen.dart';

/// Screen for displaying articles in a specific category
class CategoryArticlesScreen extends StatefulWidget {
  final ArticleCategory category;
  final String? locale;

  const CategoryArticlesScreen({
    super.key,
    required this.category,
    this.locale,
  });

  @override
  State<CategoryArticlesScreen> createState() => _CategoryArticlesScreenState();
}

class _CategoryArticlesScreenState extends State<CategoryArticlesScreen> {
  List<Article> articles = [];
  List<Article> filteredArticles = [];
  bool isLoading = true;
  String? error;
  String searchQuery = '';
  ArticleSortOption selectedSort = ArticleSortOption.newest;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final loadedArticles = await ArticleService.getArticlesByCategory(widget.category.id);
      
      setState(() {
        articles = loadedArticles;
        filteredArticles = loadedArticles;
        isLoading = false;
      });
      
      _applySortAndFilter();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _applySortAndFilter() {
    setState(() {
      filteredArticles = articles.where((article) {
        if (searchQuery.isEmpty) return true;
        
        final query = searchQuery.toLowerCase();
        final title = widget.locale != null 
            ? article.getLocalizedTitle(widget.locale!)
            : article.title;
        final summary = widget.locale != null
            ? article.getLocalizedSummary(widget.locale!)
            : article.summary;
            
        return title.toLowerCase().contains(query) ||
            summary.toLowerCase().contains(query) ||
            article.tags.any((tag) => tag.toLowerCase().contains(query)) ||
            article.author.toLowerCase().contains(query);
      }).toList();

      // Apply sorting
      switch (selectedSort) {
        case ArticleSortOption.newest:
          filteredArticles.sort((a, b) => b.publishDate.compareTo(a.publishDate));
          break;
        case ArticleSortOption.oldest:
          filteredArticles.sort((a, b) => a.publishDate.compareTo(b.publishDate));
          break;
        case ArticleSortOption.readTime:
          filteredArticles.sort((a, b) => a.readTimeMinutes.compareTo(b.readTimeMinutes));
          break;
        case ArticleSortOption.priority:
          filteredArticles.sort((a, b) => b.priorityValue.compareTo(a.priorityValue));
          break;
        case ArticleSortOption.alphabetical:
          filteredArticles.sort((a, b) {
            final titleA = widget.locale != null 
                ? a.getLocalizedTitle(widget.locale!)
                : a.title;
            final titleB = widget.locale != null
                ? b.getLocalizedTitle(widget.locale!)
                : b.title;
            return titleA.compareTo(titleB);
          });
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = widget.category.color;
    
    final displayName = widget.locale != null 
        ? widget.category.getLocalizedName(widget.locale!)
        : widget.category.name;
    final displayDescription = widget.locale != null
        ? widget.category.getLocalizedDescription(widget.locale!)
        : widget.category.description;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.category.icon,
              color: categoryColor,
              size: ResponsiveUtils.getResponsiveIconSize(context, 24),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Flexible(
              child: Text(
                displayName,
                style: GoogleFonts.notoSerifSinhala(
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: categoryColor.withOpacity(0.1),
        elevation: 0,
        actions: [
          PopupMenuButton<ArticleSortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (option) {
              setState(() {
                selectedSort = option;
              });
              _applySortAndFilter();
            },
            itemBuilder: (context) => ArticleSortOption.values.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      _getSortIcon(option),
                      size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                      color: selectedSort == option ? categoryColor : null,
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
                    Text(
                      _getSortLabel(option),
                      style: TextStyle(
                        color: selectedSort == option ? categoryColor : null,
                        fontWeight: selectedSort == option ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: ResponsiveLayout(
        child: Column(
          children: [
            // Category header with description
            Container(
              width: double.infinity,
              padding: ResponsiveUtils.getResponsivePadding(context),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: categoryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
                  
                  // Search bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                      _applySortAndFilter();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search articles...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: categoryColor,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                                _applySortAndFilter();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context),
                        ),
                        borderSide: BorderSide(color: categoryColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context),
                        ),
                        borderSide: BorderSide(color: categoryColor, width: 2),
                      ),
                      fillColor: theme.colorScheme.surface,
                      filled: true,
                    ),
                  ),
                ],
              ),
            ),

            // Articles count and sort info
            if (!isLoading && filteredArticles.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                child: Row(
                  children: [
                    Text(
                      '${filteredArticles.length} article${filteredArticles.length == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      'Sorted by ${_getSortLabel(selectedSort).toLowerCase()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? _buildErrorWidget()
                      : filteredArticles.isEmpty
                          ? _buildEmptyState()
                          : _buildArticlesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final theme = Theme.of(context);
    return Center(
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
            onPressed: _loadArticles,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isSearching = searchQuery.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.article_outlined,
            size: ResponsiveUtils.getResponsiveIconSize(context, 64),
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
          Text(
            isSearching ? 'No articles found' : 'No articles available',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
          Text(
            isSearching 
                ? 'Try adjusting your search terms'
                : 'Articles for this category are coming soon',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (isSearching) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                });
                _applySortAndFilter();
              },
              child: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    return ListView.builder(
      padding: ResponsiveUtils.getResponsivePadding(context),
      itemCount: filteredArticles.length,
      itemBuilder: (context, index) {
        final article = filteredArticles[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveUtils.getResponsiveSpacing(context, 16),
          ),
          child: ArticleCard(
            article: article,
            locale: widget.locale,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(
                    articleId: article.id,
                    locale: widget.locale,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _getSortIcon(ArticleSortOption option) {
    switch (option) {
      case ArticleSortOption.newest:
        return Icons.schedule;
      case ArticleSortOption.oldest:
        return Icons.history;
      case ArticleSortOption.readTime:
        return Icons.timer;
      case ArticleSortOption.priority:
        return Icons.priority_high;
      case ArticleSortOption.alphabetical:
        return Icons.sort_by_alpha;
    }
  }

  String _getSortLabel(ArticleSortOption option) {
    switch (option) {
      case ArticleSortOption.newest:
        return 'Newest first';
      case ArticleSortOption.oldest:
        return 'Oldest first';
      case ArticleSortOption.readTime:
        return 'Reading time';
      case ArticleSortOption.priority:
        return 'Priority';
      case ArticleSortOption.alphabetical:
        return 'Alphabetical';
    }
  }
}

enum ArticleSortOption {
  newest,
  oldest,
  readTime,
  priority,
  alphabetical,
}