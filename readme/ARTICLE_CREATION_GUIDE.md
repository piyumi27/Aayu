# Article Creation Guide for Aayu App

This guide explains how to add new articles to the Aayu app's offline blog system. All articles are stored locally and work completely offline.

## 📁 Directory Structure

```
assets/articles/
├── articles_index.json          # Master index of all articles
├── images/                      # Article images and assets
├── nutrition/                   # Nutrition-related articles
├── health/                      # Health and medical articles
├── development/                 # Child development articles
├── activity/                    # Activities and exercises
├── parenting/                   # Parenting tips and guides
└── safety/                      # Safety and emergency info
```

## 🆕 Adding a New Article

### Step 1: Create the Markdown File

1. **Choose the appropriate category folder** (nutrition, health, development, etc.)
2. **Create a new `.md` file** with a descriptive filename (use kebab-case)
3. **Write your article content** in Markdown format

**Example filename:** `toddler-nutrition-guide.md`

### Step 2: Add Article Metadata to Index

Open `assets/articles/articles_index.json` and add your article to the `articles` array:

```json
{
  "id": "toddler-nutrition-guide",
  "title": "Complete Nutrition Guide for Toddlers",
  "summary": "Everything you need to know about feeding your 1-3 year old child",
  "category": "nutrition",
  "tags": ["toddler", "nutrition", "feeding", "1-3-years"],
  "author": "Dr. Your Name",
  "publishDate": "2025-01-30T00:00:00.000Z",
  "readTimeMinutes": 12,
  "featuredImage": "assets/articles/images/toddler-nutrition.jpg",
  "priority": "normal",
  "isFeatured": false,
  "localizedTitles": {
    "si": "කුඩා දරුවන් සඳහා සම්පූර්ණ පෝෂණ මාර්ගෝපදේශය",
    "ta": "சிறு குழந்தைகளுக்கான முழுமையான ஊட்டச்சத்து வழிகாட்டி"
  },
  "localizedSummaries": {
    "si": "ඔබේ 1-3 වයස් දරුවා පෝෂණය කිරීම ගැන ඔබ දැන ගත යුතු සියල්ල",
    "ta": "உங்கள் 1-3 வயது குழந்தையை உணவளிப்பது பற்றி நீங்கள் தெரிந்து கொள்ள வேண்டியது எல்லாம்"
  },
  "relatedArticles": ["first-foods-introduction", "picky-eater-solutions"]
}
```

### Step 3: Update pubspec.yaml (if needed)

If you're adding new asset directories, update `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/articles/
    - assets/articles/images/
    - assets/articles/nutrition/
    - assets/articles/health/
    # Add new directories here
```

### Step 4: Add Dependencies (if needed)

Add the flutter_markdown dependency if not already present:

```yaml
dependencies:
  flutter_markdown: ^0.6.18
```

## 📝 Article Metadata Fields

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique identifier (same as filename without .md) | `"breastfeeding-basics"` |
| `title` | String | Article title in English | `"Breastfeeding Basics"` |
| `summary` | String | Brief description (1-2 sentences) | `"Essential guide for new mothers..."` |
| `category` | String | Category ID from available categories | `"nutrition"` |
| `tags` | Array | Searchable keywords | `["breastfeeding", "newborn"]` |
| `author` | String | Author name | `"Dr. Priya Silva"` |
| `publishDate` | String | ISO date string | `"2025-01-15T00:00:00.000Z"` |
| `readTimeMinutes` | Number | Estimated reading time | `8` |

### Optional Fields

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `featuredImage` | String | Path to header image | `null` |
| `priority` | String | "high", "normal", "low" | `"normal"` |
| `isFeatured` | Boolean | Show in featured section | `false` |
| `localizedTitles` | Object | Translated titles | `{}` |
| `localizedSummaries` | Object | Translated summaries | `{}` |
| `relatedArticles` | Array | Related article IDs | `[]` |

## 📂 Available Categories

| ID | Name | Description | Icon | Color |
|----|------|-------------|------|-------|
| `nutrition` | Nutrition | Feeding and dietary guides | 🍽️ | Green |
| `health` | Health | Medical care and monitoring | ❤️ | Pink |
| `development` | Development | Growth milestones | 👶 | Blue |
| `activity` | Activities | Play and exercises | 🎮 | Orange |
| `parenting` | Parenting | Tips and guidance | 👨‍👩‍👧‍👦 | Purple |
| `safety` | Safety | Safety and emergencies | 🛡️ | Red |

## ✍️ Writing Guidelines

### Article Structure

```markdown
# Article Title

![Description](../images/featured-image.jpg)

Brief introduction paragraph that hooks the reader and explains what they'll learn.

## Main Section 1

Content with proper headings and subheadings...

### Subsection

More detailed content...

## Lists and Formatting

### Bullet Points
- Important point 1
- Important point 2  
- Important point 3

### Numbered Steps
1. First step
2. Second step
3. Third step

### Tables
| Age | Portion Size | Examples |
|-----|--------------|----------|
| 6-8 months | 2-3 tbsp | Rice cereal |
| 8-10 months | 4-6 tbsp | Mashed vegetables |

## Callout Boxes

> **Important Note:** Use blockquotes for important information that needs to stand out.

⚠️ **Warning:** Use warning symbols for safety information.

✅ **Tip:** Use checkmarks for helpful tips.

---

*Disclaimer text goes here.*

## Related Articles
- [Link to Related Article 1](article-id-1)
- [Link to Related Article 2](article-id-2)
```

### Writing Best Practices

#### 1. **Clear and Concise**
- Use simple, everyday language
- Avoid medical jargon (or explain it)
- Keep paragraphs short (2-4 sentences)

#### 2. **Culturally Appropriate**
- Include Sri Lankan context where relevant
- Use local food examples and measurements
- Reference local healthcare systems

#### 3. **Actionable Content**
- Provide specific, practical advice
- Include step-by-step instructions
- Use checklists and summaries

#### 4. **Visual Elements**
- Add relevant images and diagrams
- Use tables for organized information
- Include callout boxes for important notes

#### 5. **Multi-language Considerations**
- Write primarily in English
- Provide Sinhala and Tamil translations for key terms
- Use universal symbols and icons

## 🖼️ Adding Images

### Image Guidelines

1. **Format:** JPG or PNG
2. **Size:** Maximum 1MB per image
3. **Dimensions:** 800x600px for featured images
4. **Naming:** Use descriptive kebab-case names

### Image Placement

```markdown
![Alt text description](../images/image-filename.jpg)
```

### Adding New Images

1. Save image to `assets/articles/images/`
2. Reference in markdown: `![Description](../images/filename.jpg)`
3. Update `pubspec.yaml` if needed

## 🌐 Localization

### Adding Translations

For important articles, provide translations:

```json
"localizedTitles": {
  "si": "සිංහල මාතෘකාව",
  "ta": "தமிழ் தலைப்பு"
},
"localizedSummaries": {
  "si": "සිංහල සාරාංශය",
  "ta": "தமிழ் சுருக்கம்"
}
```

### Translation Guidelines

- **Key medical terms** should be translated
- **Instructions and warnings** are high priority
- **Cultural references** should be localized
- **Emergency information** must be translated

## 🏷️ Tagging Strategy

### Effective Tags

#### Age-Based Tags
- `newborn` (0-2 months)
- `infant` (2-12 months)
- `toddler` (1-3 years)
- `preschool` (3-5 years)

#### Topic-Based Tags
- `feeding`, `sleep`, `development`
- `safety`, `health`, `nutrition`
- `activities`, `milestones`

#### Urgency Tags
- `emergency`, `urgent`, `prevention`
- `routine`, `optional`, `seasonal`

### Tag Best Practices
- Use 3-7 tags per article
- Choose specific over general tags
- Maintain consistency across articles
- Consider search behavior

## 🔗 Linking Between Articles

### Internal Links
```markdown
[Article Title](article-id)
```

### Related Articles Section
Always include at the end:
```markdown
## Related Articles
- [Breastfeeding Basics](breastfeeding-basics)
- [First Foods Guide](first-foods-introduction)
```

## ⚠️ Content Guidelines

### Medical Disclaimer
Always include:
```markdown
---
*This article is for educational purposes only and should not replace professional medical advice. Always consult with your healthcare provider for personalized guidance.*
```

### Safety Information
- Use clear warning symbols: ⚠️
- Highlight emergency situations
- Provide emergency contact numbers
- Include "when to seek help" sections

### Evidence-Based Content
- Reference current medical guidelines
- Cite authoritative sources
- Update content regularly
- Note publication date

## 🧪 Testing Your Article

### Validation Checklist

#### Content ✅
- [ ] Clear, actionable information
- [ ] Culturally appropriate
- [ ] Evidence-based recommendations
- [ ] Proper grammar and spelling

#### Technical ✅
- [ ] Unique article ID
- [ ] Correct category assignment
- [ ] All required metadata fields
- [ ] Valid JSON in index file
- [ ] Images exist and load properly

#### User Experience ✅
- [ ] Engaging introduction
- [ ] Logical flow and structure
- [ ] Helpful headings and subheadings
- [ ] Clear calls-to-action
- [ ] Related articles linked

### Development Testing

```dart
// Add to your test environment
final validationErrors = await ArticleService.validateArticles();
if (validationErrors.isNotEmpty) {
  for (final error in validationErrors) {
    print('Validation Error: $error');
  }
}
```

## 📱 App Integration

### How Articles Appear in App

1. **Learn Screen:** Grid of categories and featured articles
2. **Category View:** List of articles in each category
3. **Article View:** Full markdown rendering with images
4. **Search:** Articles searchable by title, summary, and tags
5. **Related Articles:** Suggested reading at article end

### Automatic Features

- **Reading time estimation** based on word count
- **Search indexing** of titles, summaries, and tags
- **Category organization** with icons and colors
- **Related article suggestions** based on tags and category
- **Offline availability** - works without internet

## 🚀 Publishing Process

### Development Workflow

1. **Create article** in appropriate category folder
2. **Add metadata** to articles_index.json
3. **Test locally** using Flutter app
4. **Validate content** using validation tools
5. **Review and edit** for quality
6. **Update version** in articles_index.json
7. **Deploy** with app update

### Version Control

Track changes in `articles_index.json`:
```json
{
  "version": "1.1.0",
  "lastUpdated": "2025-01-30",
  "articles": [...]
}
```

## 📊 Content Strategy

### Article Planning

#### High Priority Articles
- **Safety information** (sleep safety, car seats)
- **Health emergencies** (fever, choking)
- **Nutrition basics** (breastfeeding, first foods)
- **Development milestones**

#### Regular Content
- **Seasonal topics** (monsoon health, holiday safety)
- **Age-specific guides** (month-by-month development)
- **Common concerns** (sleep issues, picky eating)
- **Cultural practices** (local foods, traditions)

#### Content Calendar
- **Monthly themes** (e.g., January = New Year safety)
- **Special events** (World Breastfeeding Week)
- **Seasonal relevance** (monsoon precautions)
- **Regular updates** (vaccination schedules)

## 🔧 Troubleshooting

### Common Issues

#### Article Not Showing
- Check `articles_index.json` syntax
- Verify article ID matches filename
- Ensure category exists
- Check pubspec.yaml asset declaration

#### Images Not Loading
- Verify image path in markdown
- Check image exists in assets/articles/images/
- Ensure proper image format (JPG/PNG)
- Check file size (under 1MB recommended)

#### Formatting Issues
- Check markdown syntax
- Verify proper heading structure
- Ensure consistent indentation
- Test with markdown preview tools

### Debug Commands

```bash
# Validate JSON syntax
python -m json.tool assets/articles/articles_index.json

# Check asset loading in Flutter
flutter analyze
flutter run --debug
```

## 📈 Analytics and Feedback

### Tracking Article Performance
- Monitor which articles are most viewed
- Track user engagement time
- Identify popular search terms
- Note frequently accessed categories

### Content Improvement
- Regular content audits
- Update based on user feedback
- Refresh outdated information
- Add new topics based on user needs

---

## Quick Reference

### New Article Checklist
- [ ] Create .md file in correct category folder
- [ ] Add metadata to articles_index.json
- [ ] Include required images
- [ ] Add translations for key content
- [ ] Test in development environment
- [ ] Validate all links work
- [ ] Check formatting and readability
- [ ] Include medical disclaimer if applicable
- [ ] Add related articles section

### File Naming Conventions
- **Article files:** `kebab-case-title.md`
- **Image files:** `descriptive-name.jpg`
- **Article IDs:** Same as filename without extension

### Key Directories
```
assets/articles/
├── articles_index.json    # Add metadata here
├── images/               # Add images here  
├── nutrition/           # Nutrition articles
├── health/              # Health articles
├── development/         # Development articles
├── activity/            # Activity articles
├── parenting/           # Parenting articles
└── safety/              # Safety articles
```

---

*This guide should be updated whenever the article system is modified. Keep it in sync with the actual implementation.*