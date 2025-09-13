import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/article.dart';
import '../utils/responsive_utils.dart';

/// Grid widget for displaying article categories
class CategoryGrid extends StatelessWidget {
  final List<ArticleCategory> categories;
  final Function(ArticleCategory) onCategoryTap;
  final String? locale;
  final Map<String, int>? articleCounts;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.locale,
    this.articleCounts,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = ResponsiveUtils.getResponsiveColumnCount(context);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        childAspectRatio: 0.85, // Slightly taller aspect ratio for more height
        crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
        mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(context, 12),
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          onTap: () => onCategoryTap(category),
          locale: locale,
          articleCount: articleCounts?[category.id] ?? 0,
        );
      },
    );
  }
}

/// Individual category card
class CategoryCard extends StatelessWidget {
  final ArticleCategory category;
  final VoidCallback onTap;
  final String? locale;
  final int articleCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.locale,
    this.articleCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = ResponsiveUtils.getResponsiveTextScale(context);
    
    // Get localized name and description
    final displayName = locale != null 
        ? category.getLocalizedName(locale!)
        : category.name;
    final displayDescription = locale != null
        ? category.getLocalizedDescription(locale!)
        : category.description;
        
    // Use the category color directly
    final categoryColor = category.color;

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
        child: Container(
          padding: ResponsiveUtils.getResponsivePadding(context, scale: 0.75),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor.withOpacity(0.1),
                categoryColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              Container(
                padding: EdgeInsets.all(
                  ResponsiveUtils.getResponsiveSpacing(context, 12),
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24),
                  color: categoryColor,
                ),
              ),

              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8)),

              // Category name
              Flexible(
                child: Text(
                  displayName,
                  style: GoogleFonts.notoSerifSinhala(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14) * textScale,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 2)),

              // Description
              Flexible(
                child: Text(
                  displayDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10) * textScale,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Article count
              if (articleCount > 0) ...[
                SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveSpacing(context, 6),
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, 2),
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                    ),
                  ),
                  child: Text(
                    '$articleCount article${articleCount == 1 ? '' : 's'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 9) * textScale,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Simplified category chip for horizontal scrolling
class CategoryChip extends StatelessWidget {
  final ArticleCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final String? locale;
  final int articleCount;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.locale,
    this.articleCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = ResponsiveUtils.getResponsiveTextScale(context);
    
    final displayName = locale != null 
        ? category.getLocalizedName(locale!)
        : category.name;
        
    final categoryColor = category.color;

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        category.icon,
        size: ResponsiveUtils.getResponsiveIconSize(context, 18),
        color: isSelected ? Colors.white : categoryColor,
      ),
      label: Text(
        displayName,
        style: GoogleFonts.notoSerifSinhala(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14) * textScale,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : categoryColor,
        ),
      ),
      backgroundColor: categoryColor.withOpacity(0.1),
      selectedColor: categoryColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: categoryColor.withOpacity(isSelected ? 1.0 : 0.3),
        width: isSelected ? 2 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
    );
  }
}