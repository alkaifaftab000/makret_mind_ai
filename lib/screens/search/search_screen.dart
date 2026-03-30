import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/brand_details/brand_details_screen.dart';
import 'package:market_mind/screens/product/product_description_screen.dart';
import 'package:market_mind/screens/product/product_screen.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/utils/image_utils.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<BrandModel> _brands = [];
  List<ProductModel> _products = [];
  List<ProductModel> _posters = [];
  final List<String> _recentSearches = [];

  final List<String> _trendingSearches = [
    'Wireless Earbuds',
    'Running Shoes',
    'Laptop Stand',
    'Water Bottle',
    'Yoga Mat',
  ];

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Shoes',
    'Electronics',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final brands = await brandService.getAllBrands();
      final products = await productService.getAllProducts();

      if (!mounted) return;
      setState(() {
        _brands = brands;
        _products = products.where((p) => p.type == 'video').toList();
        _posters = products.where((p) => p.type == 'poster').toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _brands = [];
        _products = [];
        _posters = [];
        _isLoading = false;
      });
    }
  }

  void _addRecentSearch(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _recentSearches.removeWhere((s) => s.toLowerCase() == query.toLowerCase());
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    });
  }

  void _removeRecentSearch(String query) {
    setState(() {
      _recentSearches.removeWhere((s) => s.toLowerCase() == query.toLowerCase());
    });
  }

  void _clearAllRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  String get _query => _searchController.text.trim().toLowerCase();

  List<BrandModel> get _filteredBrands {
    if (_query.isEmpty) return [];
    return _brands
        .where(
          (b) =>
              b.name.toLowerCase().contains(_query) ||
              (b.description?.toLowerCase().contains(_query) ?? false),
        )
        .toList();
  }

  List<ProductModel> get _filteredProducts {
    if (_query.isEmpty) return [];
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_query) ||
              p.prompt.toLowerCase().contains(_query),
        )
        .toList();
  }

  List<ProductModel> get _filteredPosters {
    if (_query.isEmpty) return [];
    return _posters
        .where(
          (p) =>
              p.name.toLowerCase().contains(_query) ||
              p.prompt.toLowerCase().contains(_query),
        )
        .toList();
  }

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
                  const Color(0xFF0F172A), 
                  const Color(0xFF064E3B).withValues(alpha: 0.2),
                ]
              : [
                  const Color(0xFFFDF2F8),
                  Colors.white,
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      _buildSearchBar(isDark),
                      const SizedBox(height: 24),

                      // Show discovery UI when search is empty
                      if (_query.isEmpty) ...[
                        // Recent Searches Section
                        if (_recentSearches.isNotEmpty)
                          _buildRecentSearchesSection(isDark),

                        if (_recentSearches.isNotEmpty)
                          const SizedBox(height: 32),

                        // Trending Searches Section
                        _buildTrendingSearchesSection(isDark),
                        const SizedBox(height: 32),

                        // Popular Category Section
                        _buildPopularCategorySection(isDark),
                      ] else ...[
                        // Show search results
                        if (_filteredBrands.isEmpty &&
                            _filteredProducts.isEmpty &&
                            _filteredPosters.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'No results found',
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ),
                        if (_filteredBrands.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Brands',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredBrands.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                            itemBuilder: (_, index) => _BrandCard(
                              brand: _filteredBrands[index],
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (_filteredProducts.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Videos',
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                            itemBuilder: (_, index) => _ProductCard(
                              product: _filteredProducts[index],
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (_filteredPosters.isNotEmpty) ...[
                          _SectionHeader(title: 'Posters', isDark: isDark),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredPosters.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.85,
                                ),
                            itemBuilder: (_, index) => _ProductCard(
                              product: _filteredPosters[index],
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.buttonPrimary.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.search,
              color: AppColors.buttonPrimary,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _addRecentSearch(value);
                }
              },
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search Product, Brands...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {});
                },
                child: Icon(
                  Icons.close,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Search',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _clearAllRecentSearches,
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches
              .map(
                (search) => GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          search,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _removeRecentSearch(search),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTrendingSearchesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trending Searches',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              'See all',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.buttonPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            _trendingSearches.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  _searchController.text = _trendingSearches[index];
                  _addRecentSearch(_trendingSearches[index]);
                  setState(() {});
                },
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.buttonPrimary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.buttonPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _trendingSearches[index],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.trending_up,
                      color: const Color(0xFFFFA500),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularCategorySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Popular Category',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              'See all',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.buttonPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (_, index) => GestureDetector(
            onTap: () {
              _searchController.text = _categories[index];
              _addRecentSearch(_categories[index]);
              setState(() {});
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8DAEF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.sectionTitle(context, isDark));
  }
}

class _BrandCard extends StatelessWidget {
  final BrandModel brand;
  final bool isDark;

  const _BrandCard({required this.brand, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BrandDetailsScreen(brand: brand)),
        );
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductScreen(brand: brand),
                          ),
                        );
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
                        'Create Product',
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
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade300,
          child: Center(
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 48,
              color: Colors.grey.shade600,
            ),
          ),
        ),
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

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isDark;

  const _ProductCard({required this.product, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDescriptionScreen(product: product),
          ),
        );
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
              child: _buildProductImage(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
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
                  Row(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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

  Widget _buildProductImage() {
    if (product.imagePaths.isNotEmpty &&
        product.imagePaths.first.startsWith('http')) {
      return Image.network(
        product.imagePaths.first,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade300,
          child: Center(
            child: Icon(
              Icons.image_not_supported_rounded,
              size: 48,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    if (product.imagePaths.isNotEmpty) {
      final imageFile = ImageUtils.loadImage(product.imagePaths.first);
      if (imageFile != null && imageFile.existsSync()) {
        return Image.file(
          imageFile,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }

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
