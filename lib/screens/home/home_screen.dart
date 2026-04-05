import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/screens/brand_details/brand_details_screen.dart';
import 'package:market_mind/screens/product/poster_config_screen.dart';
import 'package:market_mind/screens/product/product_screen.dart';
import 'package:market_mind/screens/product/video_config_screen.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/image_utils.dart';
import 'package:market_mind/utils/permission_utils.dart';
import 'package:market_mind/services/app_options_service.dart';

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
      // Fetch options + data in parallel
      final results = await Future.wait([
        brandService.getAllBrands(),
        productService.getAllProducts(),
        appOptionsService.fetchOptions(),
      ]);
      final brands = results[0] as List<BrandModel>;
      final allProducts = results[1] as List<ProductModel>;

      setState(() {
        _brands = brands;
        _filteredBrands = brands;
        _videoProducts = allProducts.where((p) => p.hasVideos).toList();
        _posterProducts = allProducts.where((p) => p.hasPosters).toList();
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
                        Navigator.pop(context); // close brand picker
                        _showProductPickerForBrand(brand, productType);
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

  /// After brand is selected, show its products and route to config screen
  void _showProductPickerForBrand(BrandModel brand, String productType) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load products for this brand
    List<ProductModel> products = [];
    try {
      products = await productService.getProductsByBrand(brand.id);
    } catch (_) {}

    if (!mounted) return;

    if (products.isEmpty) {
      AppNotification.info(context,
          message: 'No products yet. Create a product first from Brand tab.');
      // Navigate to product screen for this brand
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductScreen(brand: brand),
        ),
      ).then((_) => _loadData());
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Container(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
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
                'Select Product',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                productType == 'video'
                    ? 'Choose a product to generate a video ad'
                    : 'Choose a product to generate a poster',
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
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context); // close product picker
                        _navigateToConfigScreen(product, productType);
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
                          child: product.images.isNotEmpty &&
                                  product.images.first.startsWith('http')
                              ? Image.network(
                                  product.images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: isDark
                                        ? AppColors.darkCardAlt
                                        : AppColors.lightCardAlt,
                                    child: const Icon(
                                      Icons.image_rounded,
                                      size: 20,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: isDark
                                      ? AppColors.darkCardAlt
                                      : AppColors.lightCardAlt,
                                  child: const Icon(
                                    Icons.image_rounded,
                                    size: 20,
                                  ),
                                ),
                        ),
                      ),
                      title: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      subtitle: Text(
                        '${product.images.length} images',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                      trailing: Icon(
                        productType == 'video'
                            ? Icons.videocam_rounded
                            : Icons.image_rounded,
                        size: 18,
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

  void _navigateToConfigScreen(ProductModel product, String productType) {
    if (productType == 'poster') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PosterConfigScreen(product: product),
        ),
      ).then((_) => _loadData());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoConfigScreen(product: product),
        ),
      ).then((_) => _loadData());
    }
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
    return _buildProductList(_videoProducts, isDark, Icons.play_circle_fill_rounded, 'video');
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
    return _buildProductList(_posterProducts, isDark, Icons.image_rounded, 'poster');
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
  Widget _buildProductList(List<ProductModel> products, bool isDark, IconData typeIcon, String productType) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductTile(
          product: product,
          isDark: isDark,
          typeIcon: typeIcon,
          productType: productType,
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
  final String productType;

  const _ProductTile({
    required this.product,
    required this.isDark,
    required this.typeIcon,
    required this.productType,
  });

  Color get _statusColor {
    // Determine overall status based on latest generations
    final posterStatus = product.latestPoster?.status ?? 'none';
    final videoStatus = product.latestVideo?.status ?? 'none';
    
    if (posterStatus == 'failed' || videoStatus == 'failed') return Colors.redAccent;
    if (posterStatus == 'processing' || videoStatus == 'processing') return const Color(0xFFFDAA5E);
    if (posterStatus == 'completed' || videoStatus == 'completed') return const Color(0xFF00B894);
    
    return Colors.grey;
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
          child: product.images.isNotEmpty && product.images.first.startsWith('http')
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.images.first,
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
              '${product.images.length} images',
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
        onTap: () {
          if (productType == 'video') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VideoConfigScreen(product: product),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PosterConfigScreen(product: product),
              ),
            );
          }
        },
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
        // Tapping the card opens the Products screen
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductScreen(brand: brand)),
        );
        onRefresh();
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
                        // Tapping Info opens Brand details
                        final shouldRefresh = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => BrandDetailsScreen(brand: brand)),
                        );
                        if (shouldRefresh == true) {
                          onRefresh();
                        }
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
                        'Info',
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

// ─── Create Brand Bottom Sheet ────────────────────────────────────
class CreateBrandSheet extends StatefulWidget {
  final Function(BrandModel) onBrandCreated;

  const CreateBrandSheet({required this.onBrandCreated, super.key});

  @override
  State<CreateBrandSheet> createState() => _CreateBrandSheetState();
}

class _CreateBrandSheetState extends State<CreateBrandSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taglineController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  final _brandVoiceController = TextEditingController();
  final _colorPrimaryController = TextEditingController();
  final _colorSecondaryController = TextEditingController();
  final _colorAccentController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _youtubeController = TextEditingController();

  String? _selectedImagePath;
  bool _isSubmitting = false;
  bool _showAdvanced = false;

  final Set<String> _selectedAudiences = {};
  final Set<String> _selectedCategories = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _taglineController.dispose();
    _websiteUrlController.dispose();
    _brandVoiceController.dispose();
    _colorPrimaryController.dispose();
    _colorSecondaryController.dispose();
    _colorAccentController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // Try picking directly — image_picker handles permissions internally
      final imagePath = await ImageUtils.pickImage(source: ImageSource.gallery);
      if (imagePath != null) {
        setState(() => _selectedImagePath = imagePath);
        return;
      }

      // If null, user cancelled or permission was denied
      // Try requesting permission explicitly as fallback
      final granted = await PermissionUtils.requestPhotosPermission();
      if (!granted && mounted) {
        AppNotification.warning(context,
            message: 'Gallery permission required. Tap to open settings.');
        await PermissionUtils.openSettings();
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
      // Permission might be denied — try requesting
      final granted = await PermissionUtils.requestPhotosPermission();
      if (!granted && mounted) {
        AppNotification.warning(context,
            message: 'Please allow photo access in Settings');
        await PermissionUtils.openSettings();
      } else if (granted) {
        // Retry after permission granted
        final imagePath = await ImageUtils.pickImage(source: ImageSource.gallery);
        if (imagePath != null && mounted) {
          setState(() => _selectedImagePath = imagePath);
        }
      }
    }
  }

  Map<String, String?>? _buildColorPalette() {
    final p = _colorPrimaryController.text.trim();
    final s = _colorSecondaryController.text.trim();
    final a = _colorAccentController.text.trim();
    if (p.isEmpty && s.isEmpty && a.isEmpty) return null;
    return {
      if (p.isNotEmpty) 'primary': p,
      if (s.isNotEmpty) 'secondary': s,
      if (a.isNotEmpty) 'accent': a,
    };
  }

  Map<String, String?>? _buildSocialLinks() {
    final ig = _instagramController.text.trim();
    final tt = _tiktokController.text.trim();
    final fb = _facebookController.text.trim();
    final tw = _twitterController.text.trim();
    final yt = _youtubeController.text.trim();
    if (ig.isEmpty && tt.isEmpty && fb.isEmpty && tw.isEmpty && yt.isEmpty) return null;
    return {
      if (ig.isNotEmpty) 'instagram': ig,
      if (tt.isNotEmpty) 'tiktok': tt,
      if (fb.isNotEmpty) 'facebook': fb,
      if (tw.isNotEmpty) 'twitter': tw,
      if (yt.isNotEmpty) 'youtube': yt,
    };
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
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        tagline: _taglineController.text.trim().isEmpty
            ? null
            : _taglineController.text.trim(),
        websiteUrl: _websiteUrlController.text.trim().isEmpty
            ? null
            : _websiteUrlController.text.trim(),
        brandVoice: _brandVoiceController.text.trim().isEmpty
            ? null
            : _brandVoiceController.text.trim(),
        targetAudience: _selectedAudiences.isEmpty
            ? null
            : _selectedAudiences.toList(),
        category: _selectedCategories.isEmpty
            ? null
            : _selectedCategories.toList(),
        colorPalette: _buildColorPalette(),
        socialLinks: _buildSocialLinks(),
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
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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

            // ─── Image upload ─────────────────────────────────
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

            // ─── Brand Name ───────────────────────────────────
            _FormField(
              label: 'Brand Name *',
              hint: 'e.g., Tech Innovations',
              controller: _nameController,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // ─── Tagline ──────────────────────────────────────
            _FormField(
              label: 'Tagline',
              hint: 'e.g., Innovation meets style',
              controller: _taglineController,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // ─── Description ──────────────────────────────────
            _FormField(
              label: 'Description',
              hint: 'Tell us about your brand...',
              controller: _descriptionController,
              isDark: isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // ─── Target Audience (multi-select chips) ─────────
            _ChipSelectSection(
              label: 'Target Audience',
              options: appOptionsService.audienceOptions,
              selectedOptions: _selectedAudiences,
              isDark: isDark,
              displayLabels: appOptionsService.audienceLabels,
              onChanged: (selected) {
                setState(() {
                  if (_selectedAudiences.contains(selected)) {
                    _selectedAudiences.remove(selected);
                  } else {
                    _selectedAudiences.add(selected);
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // ─── Category (multi-select chips) ────────────────
            _ChipSelectSection(
              label: 'Category',
              options: appOptionsService.categoryOptions,
              selectedOptions: _selectedCategories,
              isDark: isDark,
              displayLabels: appOptionsService.categoryLabels,
              onChanged: (selected) {
                setState(() {
                  if (_selectedCategories.contains(selected)) {
                    _selectedCategories.remove(selected);
                  } else {
                    _selectedCategories.add(selected);
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // ─── Advanced Options Toggle ──────────────────────
            GestureDetector(
              onTap: () => setState(() => _showAdvanced = !_showAdvanced),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _showAdvanced ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.buttonPrimary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Advanced Options',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.buttonPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Brand Voice, Colors, Socials',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Advanced Fields (collapsible) ────────────────
            if (_showAdvanced) ...[
              const SizedBox(height: 16),

              // Brand Voice
              _FormField(
                label: 'Brand Voice',
                hint: 'e.g., Friendly, Professional, Bold',
                controller: _brandVoiceController,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Website URL
              _FormField(
                label: 'Website URL',
                hint: 'e.g., https://mybrand.com',
                controller: _websiteUrlController,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              // ─── Color Palette ────────────────────────────
              Text(
                'Color Palette',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      label: 'Primary',
                      hint: '#FF5733',
                      controller: _colorPrimaryController,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FormField(
                      label: 'Secondary',
                      hint: '#333333',
                      controller: _colorSecondaryController,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FormField(
                      label: 'Accent',
                      hint: '#00BCD4',
                      controller: _colorAccentController,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Social Links ─────────────────────────────
              Text(
                'Social Links',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 8),
              _FormField(
                label: 'Instagram',
                hint: 'https://instagram.com/mybrand',
                controller: _instagramController,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _FormField(
                label: 'TikTok',
                hint: 'https://tiktok.com/@mybrand',
                controller: _tiktokController,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _FormField(
                label: 'Facebook',
                hint: 'https://facebook.com/mybrand',
                controller: _facebookController,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _FormField(
                label: 'Twitter / X',
                hint: 'https://x.com/mybrand',
                controller: _twitterController,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _FormField(
                label: 'YouTube',
                hint: 'https://youtube.com/@mybrand',
                controller: _youtubeController,
                isDark: isDark,
              ),
            ],
            const SizedBox(height: 24),

            // ─── Buttons ──────────────────────────────────────
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

// ─── Multi-select chip section ────────────────────────────────────
class _ChipSelectSection extends StatelessWidget {
  final String label;
  final List<String> options;
  final Set<String> selectedOptions;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final Map<String, String>? displayLabels;

  const _ChipSelectSection({
    required this.label,
    required this.options,
    required this.selectedOptions,
    required this.isDark,
    required this.onChanged,
    this.displayLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            if (selectedOptions.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.buttonPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${selectedOptions.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.buttonText,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedOptions.contains(option);
            final chipLabel = displayLabels?[option] ?? option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.buttonPrimary
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.divider.withValues(alpha: 0.5),
                        ),
                ),
                child: Text(
                  chipLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.buttonText
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
