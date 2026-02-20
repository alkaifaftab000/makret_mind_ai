import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/services/product_service.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<Map<String, dynamic>> _profileStats;

  @override
  void initState() {
    super.initState();
    _profileStats = _loadStats();
  }

  Future<Map<String, dynamic>> _loadStats() async {
    final brands = await brandService.getAllBrands();
    final allProducts = await productService.getAllProducts();

    int totalPosters = 0;
    for (final product in allProducts) {
      if (product.type == 'poster') {
        totalPosters++;
      }
    }

    return {
      'totalBrands': brands.length,
      'totalProducts': allProducts.length,
      'totalPosters': totalPosters,
      'brands': brands,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _profileStats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Center(
            child: Text('Unable to load profile', style: GoogleFonts.poppins()),
          );
        }

        final stats = snapshot.data!;
        final totalBrands = stats['totalBrands'] as int;
        final totalProducts = stats['totalProducts'] as int;
        final totalPosters = stats['totalPosters'] as int;

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Image Section
                SizedBox(
                  width: screenSize.width * 0.35,
                  height: screenSize.width * 0.35,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.buttonPrimary,
                          AppColors.buttonSecondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.buttonPrimary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: screenSize.width * 0.18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // User Name / Title
                Text(
                  'MarketMind User',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Content Creator',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Box
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider, width: 0.8),
                  ),
                  child: Column(
                    children: [
                      // Row 1: Brands and Products
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              isDark: isDark,
                              icon: Icons.storefront_rounded,
                              count: totalBrands.toString(),
                              label: 'Brands',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatItem(
                              isDark: isDark,
                              icon: Icons.video_collection_rounded,
                              count: totalProducts.toString(),
                              label: 'Products',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 2: Posters
                      _buildStatItem(
                        isDark: isDark,
                        icon: Icons.image_rounded,
                        count: totalPosters.toString(),
                        label: 'Posters',
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Account Info Section
                _buildSectionTitle(isDark, 'Account Information'),
                const SizedBox(height: 12),
                _buildInfoCard(isDark, 'Email Address', 'user@example.com'),
                const SizedBox(height: 8),
                _buildInfoCard(isDark, 'Member Since', 'January 2026'),
                const SizedBox(height: 8),
                _buildInfoCard(isDark, 'Account Status', 'Active'),
                const SizedBox(height: 24),

                // Quick Stats
                _buildSectionTitle(isDark, 'Quick Stats'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        isDark,
                        'Storage Used',
                        '2.4 GB / 10 GB',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStat(
                        isDark,
                        'Content Value',
                        '${totalBrands + totalProducts} items',
                        AppColors.buttonPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required bool isDark,
    required IconData icon,
    required String count,
    required String label,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppColors.buttonPrimary),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(bool isDark, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    bool isDark,
    String title,
    String value,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
