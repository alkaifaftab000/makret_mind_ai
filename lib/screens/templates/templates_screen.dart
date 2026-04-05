import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/utils/search_bar.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Medicine',
    'Healthcare',
    'Cosmetic',
    'Jewelry',
    'Makeup',
  ];

  final List<_Template> _templates = [
    _Template(
      id: '1',
      name: 'Medicine Product Showcase',
      category: 'Medicine',
      thumbnail: 'assets/video/short_clip3.mp4',
      config: _VideoConfig(
        prompt: 'Professional medicine product presentation',
        tone: 'Professional',
        modelType: 'Standard',
        audioType: 'Background Music',
        aspectRatio: '16:9',
        videoLength: '30s',
      ),
    ),
    _Template(
      id: '2',
      name: 'Healthcare Service',
      category: 'Healthcare',
      thumbnail: 'assets/video/short_clip3.mp4',
      config: _VideoConfig(
        prompt: 'Healthcare service promotion video',
        tone: 'Caring',
        modelType: 'Enhanced',
        audioType: 'Narration',
        aspectRatio: '9:16',
        videoLength: '15s',
      ),
    ),
    _Template(
      id: '3',
      name: 'Cosmetic Product Demo',
      category: 'Cosmetic',
      thumbnail: 'assets/video/short_clip3.mp4',
      config: _VideoConfig(
        prompt: 'Beautiful cosmetic product demonstration',
        tone: 'Engaging',
        modelType: 'Premium',
        audioType: 'Upbeat Music',
        aspectRatio: '1:1',
        videoLength: '20s',
      ),
    ),
    _Template(
      id: '4',
      name: 'Jewelry Collection',
      category: 'Jewelry',
      thumbnail: 'assets/video/short_clip3.mp4',
      config: _VideoConfig(
        prompt: 'Elegant jewelry showcase',
        tone: 'Luxury',
        modelType: 'Premium',
        audioType: 'Classical Music',
        aspectRatio: '16:9',
        videoLength: '30s',
      ),
    ),
    _Template(
      id: '5',
      name: 'Makeup Tutorial',
      category: 'Makeup',
      thumbnail: 'assets/video/short_clip3.mp4',
      config: _VideoConfig(
        prompt: 'Step-by-step makeup application',
        tone: 'Friendly',
        modelType: 'Standard',
        audioType: 'Narration',
        aspectRatio: '9:16',
        videoLength: '45s',
      ),
    ),
    _Template(
      id: '6',
      name: 'Wellness Product',
      category: 'Healthcare',
      thumbnail: 'assets/video/short_clip3.mp4',
      config: _VideoConfig(
        prompt: 'Wellness and health product benefits',
        tone: 'Motivating',
        modelType: 'Enhanced',
        audioType: 'Background Music',
        aspectRatio: '16:9',
        videoLength: '20s',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Template> get _filtered {
    var items = _templates;

    if (_selectedCategory != 'All') {
      items = items.where((t) => t.category == _selectedCategory).toList();
    }

    if (_searchController.text.isNotEmpty) {
      items = items
          .where(
            (t) => t.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    return items;
  }

  void _viewTemplate(_Template template) {
    // Templates are demo content — show a preview snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Template preview: ${template.name}',
          style: GoogleFonts.poppins(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
        title: Text(
          AppStrings.templatesTitle,
          style: AppTextStyles.screenTitle(context, isDark),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: AppSearchBar(
              controller: _searchController,
              isDark: isDark,
              hintText: AppStrings.searchTemplatesHint,
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Category Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.buttonPrimary
                              : (isDark ? AppColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: !isSelected
                              ? Border.all(color: AppColors.divider, width: 0.6)
                              : null,
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.buttonText
                                : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Grid of Templates
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      AppStrings.noTemplatesFound,
                      style: GoogleFonts.poppins(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: GridView.builder(
                      itemCount: _filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemBuilder: (_, index) {
                        final template = _filtered[index];
                        return _buildTemplateCard(isDark, template);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(bool isDark, _Template template) {
    return GestureDetector(
      onTap: () => _viewTemplate(template),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 54,
                    color: AppColors.buttonPrimary,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitleOnImage(context),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${template.category.toUpperCase()} • ${template.config.videoLength} • ${template.config.aspectRatio}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardSubtitleOnImage(
                      context,
                    ).copyWith(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Template {
  final String id;
  final String name;
  final String category;
  final String thumbnail;
  final _VideoConfig config;

  _Template({
    required this.id,
    required this.name,
    required this.category,
    required this.thumbnail,
    required this.config,
  });
}

class _VideoConfig {
  final String prompt;
  final String tone;
  final String modelType;
  final String audioType;
  final String aspectRatio;
  final String videoLength;

  _VideoConfig({
    required this.prompt,
    required this.tone,
    required this.modelType,
    required this.audioType,
    required this.aspectRatio,
    required this.videoLength,
  });
}
