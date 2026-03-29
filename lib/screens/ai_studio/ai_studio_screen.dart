import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../main.dart'; // To access MainApp.toggleTheme
import '../../utils/app_transitions.dart';
import 'create_scene_screen.dart';
import 'scene_preview_screen.dart';

class AIStudioScreen extends StatefulWidget {
  const AIStudioScreen({super.key});

  @override
  State<AIStudioScreen> createState() => _AIStudioScreenState();
}

class _AIStudioScreenState extends State<AIStudioScreen> {
  final PageController _pageController = PageController();
  int _currentCarouselIndex = 0;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Trends',
    'E-commerce',
    'Minimal',
    'Dark',
    'Neon'
  ];

  final List<Map<String, String>> _featuredScenes = [
    {
      'title': 'Luxury Perfume Scene',
      'image': 'https://picsum.photos/seed/luxury/800/800',
    },
    {
      'title': 'Minimalist Tech Desk',
      'image': 'https://picsum.photos/seed/tech/800/800',
    },
    {
      'title': 'Neon Cyberpunk Vape',
      'image': 'https://picsum.photos/seed/neon/800/800',
    },
  ];

  final List<Map<String, String>> _sceneTemplates = [
    {
      'title': 'Clean Studio',
      'image': 'https://picsum.photos/seed/clean/400/500',
    },
    {
      'title': 'Earthy & Organic',
      'image': 'https://picsum.photos/seed/earthy/400/500',
    },
    {
      'title': 'Silk Drapes',
      'image': 'https://picsum.photos/seed/silk/400/500',
    },
    {
      'title': 'Moody Shadows',
      'image': 'https://picsum.photos/seed/moody/400/500',
    },
    {
      'title': 'Vibrant Pedestal',
      'image': 'https://picsum.photos/seed/vibrant/400/500',
    },
    {
      'title': 'Nature Background',
      'image': 'https://picsum.photos/seed/nature/400/500',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(context, isDark),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100), // Space for floating CTA
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildFeaturedCarousel(isDark),
              const SizedBox(height: 12),
              _buildPageIndicator(isDark),
              const SizedBox(height: 24),
              _buildCategoryChips(isDark),
              const SizedBox(height: 24),
              _buildSceneGrid(isDark),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _FloatingCreateButton(isDark: isDark),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('AI Studio', style: AppTextStyles.screenTitle(context, isDark)),
      actions: [
        IconButton(
          onPressed: () => MainApp.toggleTheme(context),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.generating_tokens_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '100',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCarousel(bool isDark) {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentCarouselIndex = index);
        },
        itemCount: _featuredScenes.length,
        itemBuilder: (context, index) {
          final scene = _featuredScenes[index];
          return _FeaturedCarouselCard(
            title: scene['title']!,
            imageUrl: scene['image']!,
            isDark: isDark,
            onTryNow: () => _navigateToPreview(scene['title']!, scene['image']!),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _featuredScenes.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentCarouselIndex == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentCarouselIndex == index
                ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                : AppColors.divider.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CategoryChip(
              label: cat,
              isSelected: _selectedCategory == cat,
              isDark: isDark,
              onTap: () => setState(() => _selectedCategory = cat),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSceneGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _sceneTemplates.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, index) {
          final template = _sceneTemplates[index];
          return _SceneGridCard(
            title: template['title']!,
            imageUrl: template['image']!,
            isDark: isDark,
            onTap: () => _navigateToPreview(template['title']!, template['image']!),
          );
        },
      ),
    );
  }

  void _navigateToPreview(String title, String imageUrl) {
    // Adding minor description just for demo
    const description = "A highly detailed, cinematic scene designed specifically for showcasing premium products in an aspirational setting.";
    
    Navigator.push(
      context,
      FadeSlideRoute(
        page: ScenePreviewScreen(
          title: title,
          imageUrl: imageUrl,
          description: description,
        ),
      ),
    );
  }
}

class _FeaturedCarouselCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isDark;
  final VoidCallback onTryNow;

  const _FeaturedCarouselCard({
    required this.title,
    required this.imageUrl,
    required this.isDark,
    required this.onTryNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
            stops: const [0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onTryNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Try Now',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? (isDark ? AppColors.textPrimaryDark : AppColors.buttonPrimary)
        : Colors.transparent;
        
    final textColor = isSelected
        ? (isDark ? AppColors.darkBackground : AppColors.buttonText)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.divider.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _SceneGridCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isDark;
  final VoidCallback onTap;

  const _SceneGridCard({
    required this.title,
    required this.imageUrl,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(12),
          alignment: Alignment.bottomLeft,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingCreateButton extends StatelessWidget {
  final bool isDark;

  const _FloatingCreateButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 68), // Shifted down along with the nav bar
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF9061F9), // Purple matching the provided image reference
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9061F9).withValues(alpha: 0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            Navigator.push(
              context,
              FadeSlideRoute(page: const CreateSceneScreen()),
            );
          },
          child: const Center(
            child: Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 38, // Large prominent plus sign
            ),
          ),
        ),
      ),
    );
  }
}
