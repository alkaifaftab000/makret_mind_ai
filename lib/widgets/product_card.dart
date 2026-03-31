import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isDark;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final preview = product.imagePaths.isNotEmpty
        ? product.imagePaths.first
        : null;
    return GestureDetector(
      onTap: onTap,
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
                  ? (preview.startsWith('http')
                        ? Image.network(
                            preview,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              child: const Center(
                                child: Icon(Icons.image_not_supported_rounded),
                              ),
                            ),
                          )
                        : Image.file(
                            File(preview),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ))
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
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.type.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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
}
