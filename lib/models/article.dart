import 'package:flutter/material.dart';

class Article {
  final String id;
  final String title;
  final String summary;
  final String content; // Markdown content
  final String category;
  final List<String> tags;
  final String author;
  final DateTime publishDate;
  final int readTimeMinutes;
  final String? featuredImage;
  final ArticlePriority priority;
  final Map<String, String> localizedTitles; // For multi-language support
  final Map<String, String> localizedSummaries;
  final bool isFeatured;
  final List<String> relatedArticles; // IDs of related articles

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.tags,
    required this.author,
    required this.publishDate,
    required this.readTimeMinutes,
    this.featuredImage,
    this.priority = ArticlePriority.normal,
    this.localizedTitles = const {},
    this.localizedSummaries = const {},
    this.isFeatured = false,
    this.relatedArticles = const [],
  });

  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'general',
      tags: List<String>.from(map['tags'] ?? []),
      author: map['author'] ?? 'Aayu Team',
      publishDate: DateTime.parse(map['publishDate'] ?? DateTime.now().toIso8601String()),
      readTimeMinutes: map['readTimeMinutes'] ?? 5,
      featuredImage: map['featuredImage'],
      priority: ArticlePriority.values.firstWhere(
        (p) => p.toString().split('.').last == (map['priority'] ?? 'normal'),
        orElse: () => ArticlePriority.normal,
      ),
      localizedTitles: Map<String, String>.from(map['localizedTitles'] ?? {}),
      localizedSummaries: Map<String, String>.from(map['localizedSummaries'] ?? {}),
      isFeatured: map['isFeatured'] ?? false,
      relatedArticles: List<String>.from(map['relatedArticles'] ?? []),
    );
  }

  /// Factory constructor for JSON from articles index
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: '', // Content will be loaded separately from markdown file
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] as List),
      author: json['author'] as String,
      publishDate: DateTime.parse(json['publishDate'] as String),
      readTimeMinutes: json['readTimeMinutes'] as int,
      featuredImage: json['featuredImage'] as String?,
      priority: ArticlePriority.values.firstWhere(
        (p) => p.toString().split('.').last == (json['priority'] ?? 'normal'),
        orElse: () => ArticlePriority.normal,
      ),
      localizedTitles: Map<String, String>.from(
        json['localizedTitles'] as Map<String, dynamic>? ?? {},
      ),
      localizedSummaries: Map<String, String>.from(
        json['localizedSummaries'] as Map<String, dynamic>? ?? {},
      ),
      isFeatured: json['isFeatured'] as bool? ?? false,
      relatedArticles: List<String>.from(
        json['relatedArticles'] as List? ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'category': category,
      'tags': tags,
      'author': author,
      'publishDate': publishDate.toIso8601String(),
      'readTimeMinutes': readTimeMinutes,
      'featuredImage': featuredImage,
      'priority': priority.toString().split('.').last,
      'localizedTitles': localizedTitles,
      'localizedSummaries': localizedSummaries,
      'isFeatured': isFeatured,
      'relatedArticles': relatedArticles,
    };
  }

  String getLocalizedTitle(String language) {
    return localizedTitles[language] ?? title;
  }

  String getLocalizedSummary(String language) {
    return localizedSummaries[language] ?? summary;
  }

  /// Get the markdown file path for this article
  String get markdownPath => 'assets/articles/$category/$id.md';

  /// Get priority as integer for sorting
  int get priorityValue {
    switch (priority) {
      case ArticlePriority.high:
        return 3;
      case ArticlePriority.normal:
        return 2;
      case ArticlePriority.low:
        return 1;
    }
  }

  /// Create a copy with updated content
  Article copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? category,
    List<String>? tags,
    String? author,
    DateTime? publishDate,
    int? readTimeMinutes,
    String? featuredImage,
    ArticlePriority? priority,
    Map<String, String>? localizedTitles,
    Map<String, String>? localizedSummaries,
    bool? isFeatured,
    List<String>? relatedArticles,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      publishDate: publishDate ?? this.publishDate,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      featuredImage: featuredImage ?? this.featuredImage,
      priority: priority ?? this.priority,
      localizedTitles: localizedTitles ?? this.localizedTitles,
      localizedSummaries: localizedSummaries ?? this.localizedSummaries,
      isFeatured: isFeatured ?? this.isFeatured,
      relatedArticles: relatedArticles ?? this.relatedArticles,
    );
  }
}

enum ArticlePriority {
  high,    // Important articles (safety, urgent health info)
  normal,  // Regular articles
  low,     // Optional reading
}

class ArticleCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Map<String, String> localizedNames;
  final Map<String, String> localizedDescriptions;

  const ArticleCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.localizedNames = const {},
    this.localizedDescriptions = const {},
  });

  String getLocalizedName(String language) {
    return localizedNames[language] ?? name;
  }

  String getLocalizedDescription(String language) {
    return localizedDescriptions[language] ?? description;
  }

  static const List<ArticleCategory> defaultCategories = [
    ArticleCategory(
      id: 'nutrition',
      name: 'Nutrition',
      description: 'Healthy eating and feeding guides',
      icon: Icons.restaurant_menu,
      color: Color(0xFF4CAF50),
      localizedNames: {
        'si': 'පෝෂණය',
        'ta': 'ஊட்டச்சத்து',
      },
      localizedDescriptions: {
        'si': 'සෞඛ්‍ය සම්පන්න ආහාර සහ පෝෂණ මාර්ගෝපදේශ',
        'ta': 'ஆரோக்கியமான உணவு மற்றும் ஊட்டச்சத்து வழிகாட்டுதல்கள்',
      },
    ),
    ArticleCategory(
      id: 'health',
      name: 'Health',
      description: 'Medical care and health monitoring',
      icon: Icons.favorite,
      color: Color(0xFFE91E63),
      localizedNames: {
        'si': 'සෞඛ්‍යය',
        'ta': 'சுகாதாரம்',
      },
      localizedDescriptions: {
        'si': 'වෛද්‍ය සත්කාර සහ සෞඛ්‍ය නිරීක්ෂණය',
        'ta': 'மருத்துவ பராமரிப்பு மற்றும் சுகாதார கண்காணிப்பு',
      },
    ),
    ArticleCategory(
      id: 'development',
      name: 'Development',
      description: 'Child growth and developmental milestones',
      icon: Icons.child_care,
      color: Color(0xFF2196F3),
      localizedNames: {
        'si': 'වර්ධනය',
        'ta': 'வளர்ச்சி',
      },
      localizedDescriptions: {
        'si': 'දරු වර්ධනය සහ වර්ධන සන්ධිස්ථාන',
        'ta': 'குழந்தை வளர்ச்சி மற்றும் வளர்ச்சி மைல்கற்கள்',
      },
    ),
    ArticleCategory(
      id: 'activity',
      name: 'Activities',
      description: 'Fun activities and exercises',
      icon: Icons.sports_esports,
      color: Color(0xFFFF9800),
      localizedNames: {
        'si': 'ක්‍රියාකාරකම්',
        'ta': 'செயல்பாடுகள்',
      },
      localizedDescriptions: {
        'si': 'විනෝදජනක ක්‍රියාකාරකම් සහ ව්‍යායාම',
        'ta': 'வேடிக்கையான செயல்பாடுகள் மற்றும் பயிற்சிகள்',
      },
    ),
    ArticleCategory(
      id: 'parenting',
      name: 'Parenting',
      description: 'Parenting tips and guidance',
      icon: Icons.family_restroom,
      color: Color(0xFF9C27B0),
      localizedNames: {
        'si': 'මාපියකම',
        'ta': 'பெற்றோர்',
      },
      localizedDescriptions: {
        'si': 'මාපිය උපදෙස් සහ මාර්ගෝපදේශ',
        'ta': 'பெற்றோர் குறிப்புகள் மற்றும் வழிகாட்டுதல்',
      },
    ),
    ArticleCategory(
      id: 'safety',
      name: 'Safety',
      description: 'Child safety and emergency information',
      icon: Icons.security,
      color: Color(0xFFF44336),
      localizedNames: {
        'si': 'ආරක්‍ෂාව',
        'ta': 'பாதுகாப்பு',
      },
      localizedDescriptions: {
        'si': 'දරු ආරක්‍ෂාව සහ හදිසි තොරතුරු',
        'ta': 'குழந்தை பாதுகாப்பு மற்றும் அவசரகால தகவல்',
      },
    ),
  ];

  static ArticleCategory? getById(String id) {
    return defaultCategories.cast<ArticleCategory?>().firstWhere(
      (category) => category?.id == id,
      orElse: () => null,
    );
  }
}

/// Articles index model for managing the collection of articles
class ArticlesIndex {
  final String version;
  final DateTime lastUpdated;
  final List<Article> articles;

  const ArticlesIndex({
    required this.version,
    required this.lastUpdated,
    required this.articles,
  });

  factory ArticlesIndex.fromJson(Map<String, dynamic> json) {
    return ArticlesIndex(
      version: json['version'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      articles: (json['articles'] as List)
          .map((article) => Article.fromJson(article as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'articles': articles.map((article) => article.toMap()).toList(),
    };
  }

  /// Get articles by category
  List<Article> getByCategory(String categoryId) {
    return articles
        .where((article) => article.category == categoryId)
        .toList();
  }

  /// Get featured articles
  List<Article> getFeaturedArticles() {
    return articles
        .where((article) => article.isFeatured)
        .toList()
      ..sort((a, b) => b.priorityValue.compareTo(a.priorityValue));
  }

  /// Search articles by query
  List<Article> search(String query) {
    if (query.isEmpty) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return articles.where((article) {
      return article.title.toLowerCase().contains(lowercaseQuery) ||
          article.summary.toLowerCase().contains(lowercaseQuery) ||
          article.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
          article.author.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get related articles for a given article
  List<Article> getRelatedArticles(String articleId) {
    final article = articles.firstWhere(
      (a) => a.id == articleId,
      orElse: () => throw ArgumentError('Article not found: $articleId'),
    );
    
    return article.relatedArticles
        .map((id) {
          try {
            return articles.firstWhere((a) => a.id == id);
          } catch (e) {
            return null;
          }
        })
        .where((article) => article != null)
        .cast<Article>()
        .toList();
  }

  /// Get recent articles (sorted by publish date)
  List<Article> getRecentArticles({int limit = 10}) {
    final sortedArticles = List<Article>.from(articles)
      ..sort((a, b) => b.publishDate.compareTo(a.publishDate));
    return sortedArticles.take(limit).toList();
  }

  /// Find article by ID
  Article? findById(String id) {
    try {
      return articles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }
}