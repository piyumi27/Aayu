import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/article.dart';
import '../utils/responsive_utils.dart';

/// Card widget for displaying article summary
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback? onTap;
  final String? locale;
  final bool showFeaturedBadge;
  final bool compact;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.locale,
    this.showFeaturedBadge = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = ResponsiveUtils.getResponsiveTextScale(context);
    final isSmallScreen = ResponsiveUtils.isSmallWidth(context);

    // Get localized title and summary
    final displayTitle =
        locale != null ? article.getLocalizedTitle(locale!) : article.title;
    final displaySummary =
        locale != null ? article.getLocalizedSummary(locale!) : article.summary;

    // Get category info
    final category = ArticleCategory.getById(article.category);
    final categoryColor = category?.color ?? theme.primaryColor;

    return Card(
      elevation: ResponsiveUtils.getResponsiveElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
          child: compact
              ? _buildCompactLayout(
                  context,
                  theme,
                  textScale,
                  displayTitle,
                  displaySummary,
                  categoryColor,
                  category,
                  isSmallScreen,
                )
              : _buildFullLayout(
                  context,
                  theme,
                  textScale,
                  displayTitle,
                  displaySummary,
                  categoryColor,
                  category,
                  isSmallScreen,
                ),
        ),
      ),
    );
  }

  Widget _buildFullLayout(
    BuildContext context,
    ThemeData theme,
    double textScale,
    String displayTitle,
    String displaySummary,
    Color categoryColor,
    ArticleCategory? category,
    bool isSmallScreen,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured image if available
        if (article.featuredImage != null && !isSmallScreen)
          Container(
            height: ResponsiveUtils.getResponsiveSpacing(context, 120),
            width: double.infinity,
            margin: EdgeInsets.only(
              bottom: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
              ),
              color: theme.colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
              ),
              child: Image.asset(
                article.featuredImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(article.category),
                        size:
                            ResponsiveUtils.getResponsiveIconSize(context, 48),
                        color: categoryColor.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Header row with category and badges
        Row(
          children: [
            // Category chip
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 8),
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 4),
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                  ),
                  border: Border.all(color: categoryColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category?.id ?? ''),
                      size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                      color: categoryColor,
                    ),
                    SizedBox(
                        width:
                            ResponsiveUtils.getResponsiveSpacing(context, 4)),
                    Flexible(
                      child: Text(
                        category?.name ?? article.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 12) *
                              textScale,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),

            // Featured badge
            if (article.isFeatured && showFeaturedBadge)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getResponsiveSpacing(context, 6),
                  vertical: ResponsiveUtils.getResponsiveSpacing(context, 2),
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context) * 0.25,
                  ),
                ),
                child: Text(
                  'FEATURED',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize:
                        ResponsiveUtils.getResponsiveFontSize(context, 10) *
                            textScale,
                  ),
                ),
              ),

            // Priority indicator
            if (article.priority == ArticlePriority.high)
              Container(
                margin: EdgeInsets.only(
                  left: ResponsiveUtils.getResponsiveSpacing(context, 4),
                ),
                child: Icon(
                  Icons.priority_high,
                  color: theme.colorScheme.error,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                ),
              ),
          ],
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),

        // Title
        Text(
          displayTitle,
          style: GoogleFonts.notoSerifSinhala(
            fontSize:
                ResponsiveUtils.getResponsiveFontSize(context, 18) * textScale,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            height: 1.3,
          ),
          maxLines: isSmallScreen ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),

        // Summary
        Text(
          displaySummary,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize:
                ResponsiveUtils.getResponsiveFontSize(context, 14) * textScale,
            height: 1.4,
          ),
          maxLines: isSmallScreen ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12)),

        // Footer with author and read time
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: ResponsiveUtils.getResponsiveIconSize(context, 16),
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            Expanded(
              child: Text(
                article.author,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12) *
                      textScale,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8)),
            Icon(
              Icons.access_time,
              size: ResponsiveUtils.getResponsiveIconSize(context, 16),
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
            Text(
              '${article.readTimeMinutes}min',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12) *
                    textScale,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    ThemeData theme,
    double textScale,
    String displayTitle,
    String displaySummary,
    Color categoryColor,
    ArticleCategory? category,
    bool isSmallScreen,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail image
        if (article.featuredImage != null)
          Container(
            width: ResponsiveUtils.getResponsiveSpacing(context, 80),
            height: ResponsiveUtils.getResponsiveSpacing(context, 80),
            margin: EdgeInsets.only(
              right: ResponsiveUtils.getResponsiveSpacing(context, 12),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
              ),
              color: theme.colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
              ),
              child: Image.asset(
                article.featuredImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(article.category),
                        size:
                            ResponsiveUtils.getResponsiveIconSize(context, 32),
                        color: categoryColor.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and badges
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            ResponsiveUtils.getResponsiveSpacing(context, 6),
                        vertical:
                            ResponsiveUtils.getResponsiveSpacing(context, 2),
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.25,
                        ),
                      ),
                      child: Text(
                        category?.name ?? article.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context, 10) *
                              textScale,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                  if (article.isFeatured && showFeaturedBadge)
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 16),
                    ),
                ],
              ),

              SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 6)),

              // Title
              Text(
                displayTitle,
                style: GoogleFonts.notoSerifSinhala(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16) *
                      textScale,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 4)),

              // Summary (shorter for compact)
              Text(
                displaySummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12) *
                      textScale,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(context, 6)),

              // Read time
              Text(
                '${article.readTimeMinutes} min read',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11) *
                      textScale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
