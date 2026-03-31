import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/services/product_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductModel _product;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _refreshProduct();
  }

  Future<void> _refreshProduct() async {
    setState(() => _isLoading = true);
    try {
      final updatedProduct = await ProductService().getProductById(_product.id);
      if (updatedProduct != null && mounted) {
        setState(() {
          _product = updatedProduct;
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF121214);
    final videos = _product.videoJobs;
    final posters = _product.posterJobs;

    final imageUrl = _product.imagePaths.isNotEmpty
        ? _product.imagePaths.first
        : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 20),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProduct,
                color: Colors.white,
                backgroundColor: const Color(0xFF1E1E24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Product Image Profile
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF27272A), width: 4),
                          image: imageUrl != null && imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: imageUrl.startsWith('http')
                                      ? NetworkImage(imageUrl) as ImageProvider
                                      : FileImage(File(imageUrl)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl == null || imageUrl.isEmpty
                            ? const Center(child: Icon(Icons.inventory_2_rounded, size: 40, color: Colors.white24))
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Product Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          _product.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.syne(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Configure summary
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          _product.prompt.isNotEmpty ? _product.prompt : 'A finely crafted product asset.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Badges
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Badge(text: _product.modelType),
                          const SizedBox(width: 8),
                          _Badge(text: _product.tone),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Sections
                      if (videos.isNotEmpty || _isLoading) ...[
                        _SectionHeader(
                          title: 'Product Videos',
                          trailing: '${videos.length} CLIPS',
                        ),
                        if (_isLoading && videos.isEmpty)
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

                      if (posters.isNotEmpty || _isLoading) ...[
                        _SectionHeader(title: 'Product Posters'),
                        if (_isLoading && posters.isEmpty)
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
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          color: const Color(0xFFA1A1AA),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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