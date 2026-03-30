import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/product/product_generation_screen.dart';
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
    final product = ProductModel(
      id: 'template_${template.id}',
      brandId: 'template_brand',
      name: template.name,
      type: 'video',
      imagePaths: List<String>.generate(3, (index) => 'template_$index'),
      prompt: template.config.prompt,
      tone: template.config.tone,
      modelType: template.config.modelType,
      audioType: template.config.audioType,
      aspectRatio: template.config.aspectRatio,
      customAspectRatio: null,
      videoLength: template.config.videoLength,
      status: 'final_ready',
      scenes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductGenerationScreen(
          product: product,
          startWithFinal: true,
          overrideFinalAsset: template.thumbnail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ]
                      : [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile & Upgrade Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Upgrade',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
    // Headline
                    Text(
                      'Create Stunning Product Videos\nInstantly',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Hero Buttons Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                children: [
                  // Large Hero Buttons (2 per row)
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeroButton(
                          context,
                          'Image to\nVideo',
                          Icons.image_search,
                          isDark,
                          onTap: () {
                            // Action for Image to Video
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHeroButton(
                          context,
                          'All\nTemplates',
                          Icons.grid_3x3,
                          isDark,
                          onTap: () {
                            setState(() => _selectedCategory = 'All');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Action Buttons Row (3 smaller ones)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActionButton(
                          context,
                          'Text to Video',
                          Icons.text_fields,
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          context,
                          'Multi-Elements',
                          Icons.dashboard_customize,
                          isDark,
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          context,
                          'Lip Sync',
                          Icons.record_voice_over,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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

            // Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Effects & Templates',
                    style: GoogleFonts.poppins(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'More',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6366F1),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Grid of Templates
            _filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        AppStrings.noTemplatesFound,
                        style: GoogleFonts.poppins(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                      itemBuilder: (_, index) {
                        final template = _filtered[index];
                        return _buildTemplateCard(isDark, template);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isDark, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? const Color(0xFF2E3B52) : const Color(0xFFF3E8FF),
              isDark ? const Color(0xFF1F2937) : const Color(0xFFE9D5FF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkCardAlt : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                child: Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 60,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          template.category,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.schedule,
                        size: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        template.config.videoLength,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
