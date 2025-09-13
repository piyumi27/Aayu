import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/article.dart';

class ArticleService {
  static const String _articlesBasePath = 'assets/articles';
  static const String _articlesIndexPath = '$_articlesBasePath/articles_index.json';
  
  // Cache for loaded articles
  static final Map<String, Article> _articleCache = {};
  static final Map<String, String> _contentCache = {};
  static List<Article>? _allArticlesCache;
  static ArticlesIndex? _articlesIndexCache;

  /// Load articles index from the JSON file
  static Future<ArticlesIndex> loadArticlesIndex() async {
    if (_articlesIndexCache != null) {
      return _articlesIndexCache!;
    }

    try {
      final String indexContent = await rootBundle.loadString(_articlesIndexPath);
      final Map<String, dynamic> indexData = json.decode(indexContent);
      
      _articlesIndexCache = ArticlesIndex.fromJson(indexData);
      
      // Cache individual articles
      for (final article in _articlesIndexCache!.articles) {
        _articleCache[article.id] = article;
      }
      
      return _articlesIndexCache!;
    } catch (e) {
      print('Error loading articles index: $e');
      // Return empty index as fallback
      return ArticlesIndex(
        version: '1.0.0',
        lastUpdated: DateTime.now(),
        articles: const [],
      );
    }
  }

  /// Load all articles from the index file
  static Future<List<Article>> loadAllArticles() async {
    if (_allArticlesCache != null) {
      return _allArticlesCache!;
    }

    try {
      final index = await loadArticlesIndex();
      final articles = List<Article>.from(index.articles);

      // Sort by priority and date
      articles.sort((a, b) {
        // First sort by priority (high priority first)
        final priorityComparison = b.priorityValue.compareTo(a.priorityValue);
        if (priorityComparison != 0) return priorityComparison;
        
        // Then by date (newest first)
        return b.publishDate.compareTo(a.publishDate);
      });

      _allArticlesCache = articles;
      return articles;
    } catch (e) {
      print('Error loading articles: $e');
      return [];
    }
  }

  /// Load article content (markdown) from file
  static Future<String> loadArticleContent(String articleId) async {
    if (_contentCache.containsKey(articleId)) {
      return _contentCache[articleId]!;
    }

    try {
      // Find the article to get its category
      final article = await getArticleById(articleId);
      if (article == null) {
        throw Exception('Article not found: $articleId');
      }

      final String contentPath = '$_articlesBasePath/${article.category}/$articleId.md';
      final String content = await rootBundle.loadString(contentPath);
      
      _contentCache[articleId] = content;
      return content;
    } catch (e) {
      print('Error loading article content for $articleId: $e');
      return '# Article Not Found\n\nSorry, this article could not be loaded.';
    }
  }

  /// Get article by ID
  static Future<Article?> getArticleById(String articleId) async {
    if (_articleCache.containsKey(articleId)) {
      return _articleCache[articleId];
    }

    // Load all articles if not cached
    await loadAllArticles();
    return _articleCache[articleId];
  }

  /// Get articles by category
  static Future<List<Article>> getArticlesByCategory(String category) async {
    final articles = await loadAllArticles();
    return articles.where((article) => article.category == category).toList();
  }

  /// Get featured articles
  static Future<List<Article>> getFeaturedArticles() async {
    final articles = await loadAllArticles();
    return articles.where((article) => article.isFeatured).toList();
  }

  /// Search articles by title, summary, or tags
  static Future<List<Article>> searchArticles(String query) async {
    if (query.trim().isEmpty) return [];

    final articles = await loadAllArticles();
    final lowercaseQuery = query.toLowerCase();

    return articles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
          article.summary.toLowerCase().contains(lowercaseQuery) ||
          article.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get articles by tags
  static Future<List<Article>> getArticlesByTags(List<String> tags) async {
    final articles = await loadAllArticles();
    return articles.where((article) {
      return tags.any((tag) => article.tags.contains(tag));
    }).toList();
  }

  /// Get related articles for a given article
  static Future<List<Article>> getRelatedArticles(String articleId) async {
    final article = await getArticleById(articleId);
    if (article == null) return [];

    // Get explicitly related articles
    final explicitlyRelated = <Article>[];
    for (final relatedId in article.relatedArticles) {
      final relatedArticle = await getArticleById(relatedId);
      if (relatedArticle != null) {
        explicitlyRelated.add(relatedArticle);
      }
    }

    if (explicitlyRelated.isNotEmpty) {
      return explicitlyRelated;
    }

    // Find articles with similar tags or same category
    final allArticles = await loadAllArticles();
    final similarArticles = allArticles.where((other) {
      if (other.id == articleId) return false;
      
      // Same category gets priority
      if (other.category == article.category) return true;
      
      // Articles with shared tags
      final sharedTags = article.tags.where((tag) => other.tags.contains(tag));
      return sharedTags.isNotEmpty;
    }).take(5).toList();

    return similarArticles;
  }

  /// Get all available categories
  static List<ArticleCategory> getAllCategories() {
    return ArticleCategory.defaultCategories;
  }

  /// Get category by ID
  static ArticleCategory? getCategoryById(String categoryId) {
    try {
      return ArticleCategory.defaultCategories
          .firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get article with loaded content
  static Future<Article> getArticleWithContent(String articleId) async {
    final article = await getArticleById(articleId);
    if (article == null) {
      throw ArgumentError('Article not found: $articleId');
    }

    final content = await loadArticleContent(articleId);
    return article.copyWith(content: content);
  }

  /// Clear cache (useful for development/testing)
  static void clearCache() {
    _articleCache.clear();
    _contentCache.clear();
    _allArticlesCache = null;
    _articlesIndexCache = null;
  }

  /// Get priority weight for sorting
  static int _getPriorityWeight(ArticlePriority priority) {
    switch (priority) {
      case ArticlePriority.high:
        return 3;
      case ArticlePriority.normal:
        return 2;
      case ArticlePriority.low:
        return 1;
    }
  }

  /// Validate article structure (for development)
  static Future<List<String>> validateArticles() async {
    final errors = <String>[];
    
    try {
      final articles = await loadAllArticles();
      
      for (final article in articles) {
        // Check required fields
        if (article.id.isEmpty) {
          errors.add('Article missing ID: ${article.title}');
        }
        
        if (article.title.isEmpty) {
          errors.add('Article missing title: ${article.id}');
        }
        
        if (article.category.isEmpty) {
          errors.add('Article missing category: ${article.id}');
        }
        
        // Check if content file exists
        try {
          await loadArticleContent(article.id);
        } catch (e) {
          errors.add('Content file missing for article: ${article.id}');
        }
        
        // Check if featured image exists (if specified)
        if (article.featuredImage != null) {
          try {
            await rootBundle.load(article.featuredImage!);
          } catch (e) {
            errors.add('Featured image missing: ${article.featuredImage} for article: ${article.id}');
          }
        }
      }
    } catch (e) {
      errors.add('Failed to validate articles: $e');
    }
    
    return errors;
  }
}