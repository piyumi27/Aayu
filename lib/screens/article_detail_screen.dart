import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../services/article_service.dart';
import '../utils/responsive_utils.dart';
import '../widgets/article_card.dart';

/// Screen for displaying full article content
class ArticleDetailScreen extends StatefulWidget {
  final String articleId;
  final String? locale;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
    this.locale,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  Article? article;
  String? content;
  List<Article> relatedArticles = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load article with content
      final loadedArticle =
          await ArticleService.getArticleWithContent(widget.articleId);
      final loadedRelated =
          await ArticleService.getRelatedArticles(widget.articleId);

      setState(() {
        article = loadedArticle;
        content = loadedArticle.content;
        relatedArticles = loadedRelated;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: article != null
            ? Text(
                widget.locale != null
                    ? article!.getLocalizedTitle(widget.locale!)
                    : article!.title,
                style: GoogleFonts.notoSerifSinhala(
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
        actions: [
          if (article != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareArticle(),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorWidget()
              : article != null && content != null
                  ? _buildArticleContent()
                  : const Center(child: Text('Article not found')),
    );
  }

  Widget _buildErrorWidget() {
    return ResponsiveLayout(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.getResponsiveIconSize(context, 64),
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16)),
            Text(
              'Failed to load article',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Text(
              error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),
            ElevatedButton(
              onPressed: _loadArticle,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleContent() {
    final theme = Theme.of(context);
    final textScale = ResponsiveUtils.getResponsiveTextScale(context);
    final category = ArticleCategory.getById(article!.category);
    final categoryColor = category?.color ?? theme.primaryColor;

    return ResponsiveLayout(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article header
            Container(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and metadata
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              ResponsiveUtils.getResponsiveSpacing(context, 12),
                          vertical:
                              ResponsiveUtils.getResponsiveSpacing(context, 6),
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(context),
                          ),
                          border:
                              Border.all(color: categoryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category?.id ?? ''),
                              size: ResponsiveUtils.getResponsiveIconSize(
                                  context, 18),
                              color: categoryColor,
                            ),
                            SizedBox(
                                width: ResponsiveUtils.getResponsiveSpacing(
                                    context, 6)),
                            Text(
                              category?.name ?? article!.category,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                        context, 14) *
                                    textScale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (article!.isFeatured)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getResponsiveSpacing(
                                context, 8),
                            vertical: ResponsiveUtils.getResponsiveSpacing(
                                context, 4),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.getResponsiveBorderRadius(
                                      context) *
                                  0.5,
                            ),
                          ),
                          child: Text(
                            'FEATURED',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                      context, 12) *
                                  textScale,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context, 16)),

                  // Title
                  Text(
                    widget.locale != null
                        ? article!.getLocalizedTitle(widget.locale!)
                        : article!.title,
                    style: GoogleFonts.notoSerifSinhala(
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 28) *
                              textScale,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context, 12)),

                  // Summary
                  Text(
                    widget.locale != null
                        ? article!.getLocalizedSummary(widget.locale!)
                        : article!.summary,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      fontSize:
                          ResponsiveUtils.getResponsiveFontSize(context, 16) *
                              textScale,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context, 16)),

                  // Author and metadata
                  Row(
                    children: [
                      CircleAvatar(
                        radius:
                            ResponsiveUtils.getResponsiveSpacing(context, 20),
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: ResponsiveUtils.getResponsiveIconSize(
                              context, 24),
                        ),
                      ),
                      SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                              context, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article!.author,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                        context, 14) *
                                    textScale,
                              ),
                            ),
                            Text(
                              '${article!.readTimeMinutes} min read • ${_formatDate(article!.publishDate)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                        context, 12) *
                                    textScale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                      height:
                          ResponsiveUtils.getResponsiveSpacing(context, 24)),
                ],
              ),
            ),

            // Featured image
            if (article!.featuredImage != null)
              Container(
                width: double.infinity,
                height: ResponsiveUtils.getResponsiveSpacing(context, 200),
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                  image: DecorationImage(
                    image: AssetImage(article!.featuredImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 24)),

            // Article content
            Container(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: MarkdownBody(
                data: content!,
                styleSheet: _buildMarkdownStyleSheet(context, textScale),
                onTapLink: (text, href, title) => _handleLinkTap(href),
                imageBuilder: (uri, title, alt) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                      vertical:
                          ResponsiveUtils.getResponsiveSpacing(context, 12),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      uri.toString(),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: ResponsiveUtils.getResponsiveSpacing(
                              context, 200),
                          color: theme.colorScheme.surface,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: ResponsiveUtils.getResponsiveIconSize(
                                      context, 48),
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                                SizedBox(
                                    height:
                                        ResponsiveUtils.getResponsiveSpacing(
                                            context, 8)),
                                Text(
                                  alt ?? 'Image not found',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Related articles
            if (relatedArticles.isNotEmpty) ...[
              SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
              Container(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Related Articles',
                      style: GoogleFonts.notoSerifSinhala(
                        fontSize:
                            ResponsiveUtils.getResponsiveFontSize(context, 24) *
                                textScale,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(
                        height:
                            ResponsiveUtils.getResponsiveSpacing(context, 16)),
                    ...relatedArticles.map((relatedArticle) => Padding(
                          padding: EdgeInsets.only(
                            bottom: ResponsiveUtils.getResponsiveSpacing(
                                context, 16),
                          ),
                          child: ArticleCard(
                            article: relatedArticle,
                            locale: widget.locale,
                            compact: true,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailScreen(
                                    articleId: relatedArticle.id,
                                    locale: widget.locale,
                                  ),
                                ),
                              );
                            },
                          ),
                        )),
                  ],
                ),
              ),
            ],

            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 32)),
          ],
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(
      BuildContext context, double textScale) {
    final theme = Theme.of(context);

    return MarkdownStyleSheet(
      h1: GoogleFonts.notoSerifSinhala(
        fontSize:
            ResponsiveUtils.getResponsiveFontSize(context, 24) * textScale,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      h2: GoogleFonts.notoSerifSinhala(
        fontSize:
            ResponsiveUtils.getResponsiveFontSize(context, 22) * textScale,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      h3: GoogleFonts.notoSerifSinhala(
        fontSize:
            ResponsiveUtils.getResponsiveFontSize(context, 20) * textScale,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        height: 1.3,
      ),
      p: theme.textTheme.bodyLarge?.copyWith(
        fontSize:
            ResponsiveUtils.getResponsiveFontSize(context, 16) * textScale,
        height: 1.6,
        color: theme.colorScheme.onSurface,
      ),
      listBullet: theme.textTheme.bodyLarge?.copyWith(
        fontSize:
            ResponsiveUtils.getResponsiveFontSize(context, 16) * textScale,
        height: 1.6,
        color: theme.colorScheme.onSurface,
      ),
      blockquote: theme.textTheme.bodyLarge?.copyWith(
        fontSize:
            ResponsiveUtils.getResponsiveFontSize(context, 16) * textScale,
        height: 1.6,
        color: theme.colorScheme.primary,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
        ),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      code: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surface,
        fontSize:
            ResponsiveUtils.getResponsiveFontSize(context, 14) * textScale,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
        ),
      ),
    );
  }

  void _handleLinkTap(String? href) async {
    if (href == null) return;

    if (href.startsWith('http')) {
      // External link
      final uri = Uri.parse(href);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      // Internal article link
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleDetailScreen(
            articleId: href,
            locale: widget.locale,
          ),
        ),
      );
    }
  }

  void _shareArticle() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality not implemented yet'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'nutrition':
        return Icons.restaurant;
      case 'health':
        return Icons.favorite;
      case 'development':
        return Icons.child_care;
      case 'activity':
        return Icons.sports_esports;
      case 'parenting':
        return Icons.family_restroom;
      case 'safety':
        return Icons.shield;
      default:
        return Icons.article;
    }
  }
}
