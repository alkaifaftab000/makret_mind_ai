import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/brand_details/brand_details_screen.dart';
import 'package:market_mind/screens/product/product_description_screen.dart';
import 'package:market_mind/screens/product/product_screen.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/utils/image_utils.dart';
import 'package:market_mind/utils/search_bar.dart';

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

  String get _query => _searchController.text.trim().toLowerCase();

  List<BrandModel> get _filteredBrands {
    if (_query.isEmpty) return _brands;
    return _brands
        .where(
          (b) =>
              b.name.toLowerCase().contains(_query) ||
              (b.description?.toLowerCase().contains(_query) ?? false),
        )
        .toList();
  }

  List<ProductModel> get _filteredProducts {
    if (_query.isEmpty) return _products;
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_query) ||
              p.prompt.toLowerCase().contains(_query),
        )
        .toList();
  }

  List<ProductModel> get _filteredPosters {
    if (_query.isEmpty) return _posters;
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
          'Search',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSearchBar(
                      controller: _searchController,
                      isDark: isDark,
                      hintText: 'Search brands, products, posters...',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    if (_filteredBrands.isEmpty &&
                        _filteredProducts.isEmpty &&
                        _filteredPosters.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(
                            _query.isEmpty
                                ? 'Search to get results'
                                : 'No results found',
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ),
                    if (_filteredBrands.isNotEmpty) ...[
                      _SectionHeader(title: 'Brands', isDark: isDark),
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
                      _SectionHeader(title: 'Products', isDark: isDark),
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
                ),
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
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
    final preview = product.imagePaths.isNotEmpty
        ? product.imagePaths.first
        : null;
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
              child: preview != null
                  ? Image.file(
                      File(preview),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Container(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_rounded),
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
                    Colors.black.withValues(alpha: 0.5),
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
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${product.type.toUpperCase()} • ${product.videoLength ?? '-'} • ${product.aspectRatio == 'custom' ? product.customAspectRatio ?? 'custom' : product.aspectRatio}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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
}
