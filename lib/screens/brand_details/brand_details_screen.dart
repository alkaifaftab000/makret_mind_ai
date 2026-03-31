import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/screens/product/product_details_screen.dart';
import 'package:market_mind/screens/brand_details/brand_service.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/utils/app_notification.dart';

class BrandDetailsScreen extends StatefulWidget {
  final BrandModel brand;

  const BrandDetailsScreen({super.key, required this.brand});

  @override
  State<BrandDetailsScreen> createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  late BrandModel _brand;
  bool _isDeleting = false;

  List<ProductModel> _products = [];
  bool _isLoadingProducts = true;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _brand = widget.brand;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProductsByBrand(_brand.id);
      if (mounted) {
        setState(() {
          _products = products;
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProducts = false;
        });
        AppNotification.error(context, message: 'Failed to load products');
      }
    }
  }

  Widget _buildBrandLogo() {
    Widget imageWidget;
    if (_brand.imagePath.startsWith('http')) {
      imageWidget = Image.network(
        _brand.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.business, color: Colors.white54, size: 50),
      );
    } else {
      final file = File(_brand.imagePath);
      if (file.existsSync()) {
        imageWidget = Image.file(file, fit: BoxFit.cover);
      } else {
        imageWidget = const Icon(
          Icons.business,
          color: Colors.white54,
          size: 50,
        );
      }
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1E24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(color: Colors.white12, width: 1.5),
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF121214);

    final videos = _products.expand((p) => p.videoJobs).toList();
    final posters = _products.expand((p) => p.posterJobs).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      _brand.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _RoundIconButton(icon: Icons.more_vert_rounded, onTap: () {}),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildBrandLogo(),
                    const SizedBox(height: 24),
                    Text(
                      _brand.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _brand.tagline ??
                          'Effortless Beauty. Everyday Confidence.',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFA78BFA),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        _brand.description ??
                            'A modern brand focused on simple, effective, and premium products designed for everyday use.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFA1A1AA),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _brand.websiteUrl ?? 'www.brand.com',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF38BDF8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ActionButton(
                          icon: Icons.language_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _ActionButton(
                          icon: Icons.camera_alt_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _ActionButton(icon: Icons.share_rounded, onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 40),
                    if (_products.isNotEmpty) ...[
                      _SectionHeader(title: 'Products', trailing: '${_products.length} ITEMS'),
                      SizedBox(
                        height: 240,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(product: _products[index]),
                                    ),
                                  );
                                },
                                child: _FeaturedProductCard(product: _products[index], width: 320),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                    if (videos.isNotEmpty || _isLoadingProducts) ...[
                      _SectionHeader(
                        title: 'AI Studio Videos',
                        trailing: '${videos.length} CLIPS',
                      ),
                      if (_isLoadingProducts)
                        const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: videos.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: _VideoCard(job: videos[index]),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 40),
                    ],
                    if (posters.isNotEmpty || _isLoadingProducts) ...[
                      _SectionHeader(title: 'Brand Posters'),
                      if (_isLoadingProducts)
                        const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.7,
                                ),
                            itemCount: posters.length,
                            itemBuilder: (context, index) {
                              return _PosterCard(job: posters[index]);
                            },
                          ),
                        ),
                      const SizedBox(height: 60),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E24),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF27272A),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  final ProductModel product;
  final double width;

  const _FeaturedProductCard({required this.product, this.width = double.infinity});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imagePaths.isNotEmpty
        ? product.imagePaths.first
        : null;

    return Container(
      width: width,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF1E1E24),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? (imageUrl.startsWith('http')
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Image.file(File(imageUrl), fit: BoxFit.cover))
                : const Icon(Icons.image, color: Colors.white24, size: 60),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'BEST SELLER',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFDDD6FE),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'View Details',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final VideoJob job;

  const _VideoCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final String? finalUrl = job.finalVideoUrl;

    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E1E24),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: finalUrl != null && finalUrl.isNotEmpty
                ? Image.network(finalUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.video_library, color: Colors.white24))
                : const Icon(Icons.video_library, color: Colors.white24),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.3),
            ),
            child: const Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Text(
              job.status.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  final PosterJob job;

  const _PosterCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final String? resultUrl = job.resultUrl;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1E1E24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: resultUrl != null && resultUrl.isNotEmpty
            ? Image.network(resultUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.white24))
            : const Icon(Icons.image, color: Colors.white24),
      ),
    );
  }
}
