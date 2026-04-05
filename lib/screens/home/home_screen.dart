import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/screens/brand_details/brand_details_screen.dart';
import 'package:market_mind/screens/product/product_screen.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/image_utils.dart';
import 'package:market_mind/utils/permission_utils.dart';

// ─── Tab definition ───────────────────────────────────────────────
enum HomeTab { video, poster, aiStudio, brand }

const Map<HomeTab, String> _tabLabels = {
  HomeTab.video: 'Video',
  HomeTab.poster: 'Poster',
  HomeTab.aiStudio: 'AI Studio',
  HomeTab.brand: 'Brand',
};

const Map<HomeTab, IconData> _tabIcons = {
  HomeTab.video: Icons.videocam_rounded,
  HomeTab.poster: Icons.image_rounded,
  HomeTab.aiStudio: Icons.auto_awesome_rounded,
  HomeTab.brand: Icons.storefront_rounded,
};

// ─── Home Screen ──────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  HomeTab _activeTab = HomeTab.brand;
  List<BrandModel> _brands = [];
  List<BrandModel> _filteredBrands = [];
  List<ProductModel> _videoProducts = [];
  List<ProductModel> _posterProducts = [];
  bool _isLoading = true;

  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearch);

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScaleAnim = CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut);
    _fabAnimController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final brands = await brandService.getAllBrands();
      final allProducts = await productService.getAllProducts();

      setState(() {
        _brands = brands;
        _filteredBrands = brands;
        _videoProducts = allProducts.where((p) => p.type == 'video').toList();
        _posterProducts = allProducts.where((p) => p.type == 'poster').toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = _brands;
      } else {
        _filteredBrands = _brands
            .where((b) =>
                b.name.toLowerCase().contains(query) ||
                (b.description?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  void _switchTab(HomeTab tab) {
    if (tab == _activeTab) return;
    _fabAnimController.reset();
    setState(() => _activeTab = tab);
    _fabAnimController.forward();
    _searchController.clear();
  }

  bool get _hasBrands => _brands.isNotEmpty;

  void _onFabPressed() {
    switch (_activeTab) {
      case HomeTab.brand:
        _showCreateBrandSheet();
        break;
      case HomeTab.video:
        if (!_hasBrands) {
          AppNotification.warning(context,
              message: AppStrings.brandRequiredMessage);
          return;
        }
        _showBrandPickerThenNavigate('video');
        break;
      case HomeTab.poster:
        if (!_hasBrands) {
          AppNotification.warning(context,
              message: AppStrings.brandRequiredMessage);
          return;
        }
        _showBrandPickerThenNavigate('poster');
        break;
      case HomeTab.aiStudio:
        if (!_hasBrands) {
          AppNotification.warning(context,
              message: AppStrings.brandRequiredMessage);
          return;
        }
        AppNotification.info(context,
            message: 'AI Studio coming soon!');
        break;
    }
  }

  void _showBrandPickerThenNavigate(String productType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Container(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Select Brand',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Choose a brand to create ${productType == 'video' ? 'a video' : 'a poster'} for',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _brands.length,
                itemBuilder: (context, index) {
                  final brand = _brands[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductScreen(brand: brand),
                          ),
                        ).then((_) => _loadData());
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      tileColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: _buildBrandThumbnail(brand),
                        ),
                      ),
                      title: Text(
                        brand.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: Text(
                        '${brand.productions} products',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandThumbnail(BrandModel brand) {
    if (brand.imagePath.startsWith('http')) {
      return Image.network(brand.imagePath, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbFallback());
    }
    final file = ImageUtils.loadImage(brand.imagePath);
    if (file != null && file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return _thumbFallback();
  }

  Widget _thumbFallback() => Container(
        color: Colors.grey.shade300,
        child: Icon(Icons.storefront_rounded, color: Colors.grey.shade600, size: 22),
      );

  void _showCreateBrandSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CreateBrandSheet(onBrandCreated: (_) => _loadData()),
    );
  }

  String get _searchHint {
    switch (_activeTab) {
      case HomeTab.video:
        return AppStrings.searchVideosHint;
      case HomeTab.poster:
        return AppStrings.searchPostersHint;
      case HomeTab.aiStudio:
        return AppStrings.searchStudioHint;
      case HomeTab.brand:
        return AppStrings.searchBrandsHint;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                AppStrings.homeTitle,
                style: AppTextStyles.pageHeading(context, isDark),
              ),
              const SizedBox(height: 12),

              // Search bar
              TextField(
                controller: _searchController,
                style: AppTextStyles.fieldText(context, isDark),
                decoration: InputDecoration(
                  hintText: _searchHint,
                  hintStyle: AppTextStyles.fieldHint(context, isDark),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 14),

              // ─── Chip tabs ────────────────────────────────────
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: HomeTab.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tab = HomeTab.values[index];
                    final isActive = _activeTab == tab;

                    return GestureDetector(
                      onTap: () => _switchTab(tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.buttonPrimary
                              : (isDark ? AppColors.darkCard : AppColors.lightCard),
                          borderRadius: BorderRadius.circular(12),
                          border: isActive
                              ? null
                              : Border.all(
                                  color: AppColors.divider.withValues(alpha: 0.4),
                                ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Icon(
                              _tabIcons[tab],
                              size: 16,
                              color: isActive
                                  ? AppColors.buttonText
                                  : (isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _tabLabels[tab]!,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                color: isActive
                                    ? AppColors.buttonText
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ─── Tab content ──────────────────────────────────
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTabContent(isDark),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // ─── FAB ──────────────────────────────────────────────────
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: FloatingActionButton.extended(
          onPressed: _onFabPressed,
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(_fabIcon),
          label: Text(
            _fabLabel,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  IconData get _fabIcon {
    switch (_activeTab) {
      case HomeTab.video:
        return Icons.videocam_rounded;
      case HomeTab.poster:
        return Icons.image_rounded;
      case HomeTab.aiStudio:
        return Icons.auto_awesome_rounded;
      case HomeTab.brand:
        return Icons.add_rounded;
    }
  }

  String get _fabLabel {
    switch (_activeTab) {
      case HomeTab.video:
        return AppStrings.generateVideo;
      case HomeTab.poster:
        return AppStrings.generatePoster;
      case HomeTab.aiStudio:
        return AppStrings.goToAIStudio;
      case HomeTab.brand:
        return AppStrings.createBrand;
    }
  }

  Widget _buildTabContent(bool isDark) {
    switch (_activeTab) {
      case HomeTab.video:
        return _buildVideoTab(isDark);
      case HomeTab.poster:
        return _buildPosterTab(isDark);
      case HomeTab.aiStudio:
        return _buildAIStudioTab(isDark);
      case HomeTab.brand:
        return _buildBrandTab(isDark);
    }
  }

  // ─── Video tab ──────────────────────────────────────────────────
  Widget _buildVideoTab(bool isDark) {
    if (_videoProducts.isEmpty) {
      return _EmptyState(
        icon: Icons.videocam_off_rounded,
        title: AppStrings.noVideosYet,
        subtitle: _hasBrands
            ? AppStrings.noVideosSubtitle
            : AppStrings.brandRequiredMessage,
        isDark: isDark,
      );
    }
    return _buildProductList(_videoProducts, isDark, Icons.play_circle_fill_rounded);
  }

  // ─── Poster tab ─────────────────────────────────────────────────
  Widget _buildPosterTab(bool isDark) {
    if (_posterProducts.isEmpty) {
      return _EmptyState(
        icon: Icons.image_not_supported_rounded,
        title: AppStrings.noPostersYet,
        subtitle: _hasBrands
            ? AppStrings.noPostersSubtitle
            : AppStrings.brandRequiredMessage,
        isDark: isDark,
      );
    }
    return _buildProductList(_posterProducts, isDark, Icons.image_rounded);
  }

  // ─── AI Studio tab ─────────────────────────────────────────────
  Widget _buildAIStudioTab(bool isDark) {
    return _EmptyState(
      icon: Icons.auto_awesome_rounded,
      title: AppStrings.noStudioJobsYet,
      subtitle: _hasBrands
          ? AppStrings.noStudioJobsSubtitle
          : AppStrings.brandRequiredMessage,
      isDark: isDark,
    );
  }

  // ─── Brand tab (original brand grid) ───────────────────────────
  Widget _buildBrandTab(bool isDark) {
    if (_filteredBrands.isEmpty) {
      return _EmptyState(
        icon: Icons.add_business_rounded,
        title: AppStrings.noBrandsYet,
        subtitle: AppStrings.noBrandsSubtitle,
        isDark: isDark,
      );
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredBrands.length,
      itemBuilder: (context, index) {
        final brand = _filteredBrands[index];
        return _BrandCard(
          brand: brand,
          isDark: isDark,
          onRefresh: _loadData,
        );
      },
    );
  }

  // ─── Shared product list ────────────────────────────────────────
  Widget _buildProductList(List<ProductModel> products, bool isDark, IconData typeIcon) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductTile(
          product: product,
          isDark: isDark,
          typeIcon: typeIcon,
        );
      },
    );
  }
}

// ─── Product Tile ─────────────────────────────────────────────────
class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  final IconData typeIcon;

  const _ProductTile({
    required this.product,
    required this.isDark,
    required this.typeIcon,
  });

  Color get _statusColor {
    switch (product.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF00B894);
      case 'processing':
        return const Color(0xFFFDAA5E);
      case 'failed':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _statusColor.withValues(alpha: 0.15),
          ),
          child: product.imagePaths.isNotEmpty && product.imagePaths.first.startsWith('http')
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imagePaths.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(typeIcon, color: _statusColor, size: 24),
                  ),
                )
              : Icon(typeIcon, color: _statusColor, size: 24),
        ),
        title: Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              product.status[0].toUpperCase() + product.status.substring(1),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      ),
    );
  }
}

// ─── Empty state widget ───────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              size: 52,
              color: AppColors.buttonPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AppTextStyles.titleMedium(context, isDark),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall(context, isDark),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Brand Card (unchanged from original) ─────────────────────────
class _BrandCard extends StatelessWidget {
  final BrandModel brand;
  final bool isDark;
  final VoidCallback onRefresh;

  const _BrandCard({
    required this.brand,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final shouldRefresh = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => BrandDetailsScreen(brand: brand)),
        );
        if (shouldRefresh == true) {
          onRefresh();
        }
      },
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
              child: _buildBrandImage(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        brand.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${brand.productions} productions',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductScreen(brand: brand),
                          ),
                        );
                        onRefresh();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonText,
                        foregroundColor: AppColors.buttonPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        AppStrings.createProduct,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildBrandImage() {
    if (brand.imagePath.startsWith('http')) {
      return Image.network(
        brand.imagePath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
      );
    }

    final imageFile = ImageUtils.loadImage(brand.imagePath);
    if (imageFile != null && imageFile.existsSync()) {
      return Image.file(
        imageFile,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 48,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

// ─── Create Brand Bottom Sheet (unchanged) ────────────────────────
class CreateBrandSheet extends StatefulWidget {
  final Function(BrandModel) onBrandCreated;

  const CreateBrandSheet({required this.onBrandCreated, super.key});

  @override
  State<CreateBrandSheet> createState() => _CreateBrandSheetState();
}

class _CreateBrandSheetState extends State<CreateBrandSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _audienceController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _selectedImagePath;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _audienceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final permissionGranted = await PermissionUtils.requestPhotosPermission();
      if (!permissionGranted) {
        if (mounted) {
          AppNotification.warning(context,
              message: 'Permission required to access photos');
        }
        return;
      }
      final imagePath = await ImageUtils.pickImage(source: ImageSource.gallery);
      if (imagePath != null) {
        setState(() => _selectedImagePath = imagePath);
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(context,
            message: 'Failed to pick image. Please try again.');
      }
    }
  }

  Future<void> _submitBrand() async {
    if (_nameController.text.isEmpty) {
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
        name: _nameController.text.trim(),
        logoFile: File(_selectedImagePath!),
        targetAudience: _audienceController.text.isEmpty
            ? null
            : _audienceController.text.trim(),
        category: _categoryController.text.isEmpty
            ? null
            : _categoryController.text.trim(),
      );

      if (mounted) {
        widget.onBrandCreated(brand);
        Navigator.pop(context);
        AppNotification.success(context,
            message: 'Brand created successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(context,
            message: 'Error creating brand. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16, 16, 16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create New Brand',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
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
                        child: Image.file(
                          File(_selectedImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_rounded,
                            size: 40,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload Brand Logo *',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _FormField(
              label: 'Brand Name *',
              hint: 'e.g., Tech Innovations',
              controller: _nameController,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'Description',
              hint: 'Tell us about your brand...',
              controller: _descriptionController,
              isDark: isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'Target Audience',
              hint: 'e.g., Tech enthusiasts, 18-35',
              controller: _audienceController,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _FormField(
              label: 'Category',
              hint: 'e.g., Technology, Fashion',
              controller: _categoryController,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.buttonPrimary
                          .withValues(alpha: 0.5),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.buttonText,
                              ),
                            ),
                          )
                        : Text(
                            'Create',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isDark;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.isDark,
    this.maxLines = 1,
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
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : 3,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}
