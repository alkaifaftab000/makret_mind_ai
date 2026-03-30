import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/screens/ai_studio/ai_studio_screen.dart';
import 'package:market_mind/screens/brand_details/brand_details_screen.dart';
import 'package:market_mind/screens/product/product_screen.dart';
import 'package:market_mind/screens/poster_generator/poster_main_screen.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/utils/app_transitions.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/image_utils.dart';
import 'package:market_mind/utils/permission_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BrandModel> _brands = [];
  bool _isLoading = true;

  // Search logic removed for simplified bento dashboard layout without forms
  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await brandService.getAllBrands();
      setState(() {
        _brands = brands;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading brands: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCreateBrandSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CreateBrandSheet(onBrandCreated: _onBrandCreated),
    );
  }

  void _onBrandCreated(BrandModel brand) {
    _loadBrands();
  }

  // Gradient palette for horizontal brand cards
  static const _cardGradients = [
    [Color(0xFF7b4397), Color(0xFFdc2430)],
    [Color(0xFF1CB5E0), Color(0xFF000851)],
    [Color(0xFF11998e), Color(0xFF38ef7d)],
    [Color(0xFFf7971e), Color(0xFFffd200)],
    [Color(0xFF4286f4), Color(0xFF373B44)],
    [Color(0xFFe96c8a), Color(0xFF7b4397)],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A), // Deep Slate
                  const Color(0xFF064E3B).withValues(alpha: 0.2), // Premium dark subtle green
                ]
              : [
                  const Color(0xFFFDF2F8), // Very light premium pink base
                  Colors.white,
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Let gradient shine through
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 68), // Hover above nav bar perfectly
          child: FloatingActionButton(
            onPressed: _showCreateBrandSheet,
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonText,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_rounded, size: 26),
          ),
        ),
        body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadBrands,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header
                    _HomeHeader(isDark: isDark),
                    const SizedBox(height: 24),

                    // Bento Grid replacing generic layout
                    const _BentoGrid(),
                    const SizedBox(height: 32),

                    // Trending Section
                    Text(
                      'Trending 🔥',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _TrendingCarousel(),
                    const SizedBox(height: 32),

                    // My Brands Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'My Brands 💼',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showCreateBrandSheet,
                          child: Text(
                            'Create +',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.buttonPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // My Brands Horizontal List
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_brands.isEmpty)
                      _EmptyBrandsPlaceholder(isDark: isDark, onCreateTap: _showCreateBrandSheet)
                    else
                      SizedBox(
                        height: 210,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _brands.length,
                          itemBuilder: (context, index) {
                            final brand = _brands[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: AspectRatio(
                                aspectRatio: 0.85, // creates a vertical card feel inside horizontal list
                                child: _HorizontalBrandCard(
                                  brand: brand,
                                  isDark: isDark,
                                  gradientColors: _cardGradients[index % _cardGradients.length],
                                  onTap: () async {
                                    final refresh = await Navigator.push<bool>(
                                      context,
                                      FadeSlideRoute(page: BrandDetailsScreen(brand: brand)),
                                    );
                                    if (refresh == true) _loadBrands();
                                  },
                                  onProductTap: () async {
                                    await Navigator.push(
                                      context,
                                      FadeSlideRoute(page: ProductScreen(brand: brand)),
                                    );
                                    _loadBrands();
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// ─────────────────────────────────────────────────────────────────────────────
// Bento Grid System
// ─────────────────────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  const _BentoGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // AI Studio - Top Wide Header Card
        _DashboardCard(
          title: 'AI Studio ✨',
          subtitle: 'Tap to create product visuals',
          icon: Icons.auto_awesome_rounded,
          gradientColors: const [Color(0xFF7b4397), Color(0xFF4286f4)], // Purple to blue
          height: 125, // Slightly taller for better icon/text fit
          bgImage: 'https://picsum.photos/seed/aistudio/600/300', // Premium background texture
          onTap: () => Navigator.push(context, FadeSlideRoute(page: const AIStudioScreen())),
        ),
        const SizedBox(height: 16),
        // Two Sub-cards in row with 1/3 and 2/3 ratio
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _DashboardCard(
                title: 'Video Ad\nGen',
                subtitle: 'Coming soon',
                icon: Icons.video_camera_back_rounded,
                gradientColors: const [Color(0xFFe96c8a), Color(0xFFdc2430)], // Pink/Red
                height: 125, // Increased height to prevent pixel overflow
                bgImage: 'https://picsum.photos/seed/videoad/300/300',
                onTap: () {}, // Dummy
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _DashboardCard(
                title: 'Ad Banner\nPost',
                subtitle: 'Tap to generate',
                icon: Icons.image_rounded,
                gradientColors: const [Color(0xFF1CB5E0), Color(0xFF000851)], // Cyan/Navy
                height: 125, // Increased height to prevent pixel overflow
                bgImage: 'https://picsum.photos/seed/bannerad/400/300',
                onTap: () => Navigator.push(context, FadeSlideRoute(page: const PosterMainScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final double height;
  final VoidCallback onTap;
  final String? bgImage;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.height,
    required this.onTap,
    this.bgImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: bgImage != null
              ? DecorationImage(
                  image: NetworkImage(bgImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    gradientColors.last.withValues(alpha: 0.65), // Heavy tint to ensure text remains perfectly readable
                    BlendMode.srcATop,
                  ),
                )
              : null,
          gradient: bgImage == null
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: height * 0.8,
                height: height * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.85),
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

// ─────────────────────────────────────────────────────────────────────────────
// Trending Carousel (Dummy Data)
// ─────────────────────────────────────────────────────────────────────────────

class _TrendingCarousel extends StatelessWidget {
  const _TrendingCarousel();

  @override
  Widget build(BuildContext context) {
    // Generate dummy trending scenes
    final dummyScenes = [
      {'title': 'Spring Collection', 'img': 'https://picsum.photos/seed/spring/400/400'},
      {'title': 'Neon Glow Ad', 'img': 'https://picsum.photos/seed/neonad/400/400'},
      {'title': 'Minimal Desk', 'img': 'https://picsum.photos/seed/desksetup/400/400'},
      {'title': 'Luxury Perfume', 'img': 'https://picsum.photos/seed/perfumex/400/400'},
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dummyScenes.length,
        itemBuilder: (context, index) {
          final scene = dummyScenes[index];
          return Container(
            width: 130, // Square-like rectangles
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(scene['img']!),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Text(
                    scene['title']!,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final bool isDark;
  const _HomeHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'), // Placeholder portrait
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            Text(
              'Jenny Wilson', // Placeholder name
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Notification bell
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider, width: 0.8),
            color: isDark ? AppColors.darkCard : Colors.white,
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            size: 20,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(width: 10),
        // Pro button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars_rounded,
                size: 16,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                'Pro',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal Brand Card (Migrated from Grid)
// ─────────────────────────────────────────────────────────────────────────────

class _HorizontalBrandCard extends StatelessWidget {
  final BrandModel brand;
  final bool isDark;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final VoidCallback onProductTap;

  const _HorizontalBrandCard({
    required this.brand,
    required this.isDark,
    required this.gradientColors,
    required this.onTap,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBackground(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brand.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: onProductTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.buttonPrimary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppStrings.createProduct,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    if (brand.imagePath.startsWith('http')) {
      return Image.network(
        brand.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _gradientFallback(),
      );
    }
    final imageFile = ImageUtils.loadImage(brand.imagePath);
    if (imageFile != null && imageFile.existsSync()) {
      return Image.file(imageFile, fit: BoxFit.cover);
    }
    return _gradientFallback();
  }

  Widget _gradientFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.business_center_rounded, size: 40, color: Colors.white.withValues(alpha: 0.4)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyBrandsPlaceholder extends StatelessWidget {
  final bool isDark;
  final VoidCallback onCreateTap;

  const _EmptyBrandsPlaceholder({required this.isDark, required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_business_rounded, size: 40, color: AppColors.buttonPrimary),
          ),
          const SizedBox(height: 12),
          Text(AppStrings.noBrandsYet, style: AppTextStyles.titleMedium(context, isDark)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onCreateTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.buttonText,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Create Brand'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CreateBrandSheet Updated for Pure Dropdown Interaction
// ─────────────────────────────────────────────────────────────────────────────

class CreateBrandSheet extends StatefulWidget {
  final Function(BrandModel) onBrandCreated;

  const CreateBrandSheet({required this.onBrandCreated, super.key});

  @override
  State<CreateBrandSheet> createState() => _CreateBrandSheetState();
}

class _CreateBrandSheetState extends State<CreateBrandSheet> {
  // We substitute controllers with local state variables perfectly fit for Dropdowns
  String? _selectedName;
  String? _selectedDescription;
  String? _selectedAudience;
  String? _selectedCategory;
  
  String? _selectedImagePath;
  bool _isSubmitting = false;

  final List<String> _nameOptions = ['Tech Innovations', 'Eco Fashion', 'Gamer Gear', 'MarketMind Alpha', 'Health Horizon'];
  final List<String> _descOptions = ['Modern tech products company', 'Sustainable and green clothing', 'High-end gaming peripherals', 'AI Driven marketing engine', 'Wellness and fitness tracking'];
  final List<String> _audienceOptions = ['Tech Enthusiasts, 18-35', 'Eco-conscious buyers', 'PC & Console Gamers', 'Enterprise B2B', 'Fitness Enthusiasts'];
  final List<String> _categoryOptions = ['Technology', 'Fashion', 'Gaming', 'Software', 'Health'];

  Future<void> _pickImage() async {
    try {
      final permissionGranted = await PermissionUtils.requestPhotosPermission();
      if (!permissionGranted) {
        if (mounted) AppNotification.warning(context, message: 'Permission required');
        return;
      }
      final imagePath = await ImageUtils.pickImage(source: ImageSource.gallery);
      if (imagePath != null) setState(() => _selectedImagePath = imagePath);
    } catch (e) {
      if (mounted) AppNotification.error(context, message: 'Failed to pick image.');
    }
  }

  Future<void> _submitBrand() async {
    if (_selectedName == null) {
      AppNotification.warning(context, message: 'Brand name is required');
      return;
    }
    if (_selectedImagePath == null) {
      AppNotification.warning(context, message: 'Brand logo is required');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final brand = await brandService.createBrandWithLogo(
        name: _selectedName!,
        logoFile: File(_selectedImagePath!),
        targetAudience: _selectedAudience,
        category: _selectedCategory,
      );

      if (mounted) {
        widget.onBrandCreated(brand);
        Navigator.pop(context);
        AppNotification.success(context, message: 'Brand created successfully!');
      }
    } catch (e) {
      if (mounted) AppNotification.error(context, message: 'Error creating brand.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create New Brand',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isSubmitting ? null : _pickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: _selectedImagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(_selectedImagePath!), fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            size: 40,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Brand Logo *',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _DropdownField(
              label: 'Brand Name *',
              hint: 'Select a brand name',
              value: _selectedName,
              options: _nameOptions,
              isDark: isDark,
              onChanged: (v) => setState(() => _selectedName = v),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Description',
              hint: 'Select a description scenario',
              value: _selectedDescription,
              options: _descOptions,
              isDark: isDark,
              onChanged: (v) => setState(() => _selectedDescription = v),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Target Audience',
              hint: 'Select an audience demographic',
              value: _selectedAudience,
              options: _audienceOptions,
              isDark: isDark,
              onChanged: (v) => setState(() => _selectedAudience = v),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'Category',
              hint: 'Select an industry category',
              value: _selectedCategory,
              options: _categoryOptions,
              isDark: isDark,
              onChanged: (v) => setState(() => _selectedCategory = v),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBrand,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: AppColors.buttonPrimary.withValues(alpha: 0.5),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.buttonText)),
                          )
                        : Text('Create', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          icon: Icon(Icons.arrow_drop_down_rounded, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          items: options.map((String opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(
                opt,
                style: AppTextStyles.fieldText(context, isDark),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          style: AppTextStyles.fieldText(context, isDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.fieldHint(context, isDark),
            filled: true,
            fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
