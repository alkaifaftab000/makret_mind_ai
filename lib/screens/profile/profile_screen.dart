import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/services/brand_service.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/services/user_service.dart';
import 'package:market_mind/models/user_model.dart';
import 'package:market_mind/screens/profile/modals/account_modal.dart';
import 'package:market_mind/screens/profile/modals/settings_modal.dart';
import 'package:market_mind/screens/profile/modals/about_modal.dart';
import 'package:market_mind/screens/profile/modals/logout_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileStats;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _profileStats = _loadStats();
  }

  Future<Map<String, dynamic>> _loadStats() async {
    try {
      _currentUser = await userService.getCurrentUser();
    } catch (e) {
      // If user fetch fails, we can fall back to authService currentUser or null
      _currentUser = null;
    }

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
    };
  }

  void _showAccountModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccountModal(),
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsModal(),
    );
  }

  void _showAboutModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AboutModal(),
    );
  }

  void _showLogoutModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LogoutModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);

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
          AppStrings.profileTitle,
          style: AppTextStyles.screenTitle(isDark),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Unable to load profile',
                style: AppTextStyles.bodyMedium(isDark),
              ),
            );
          }

          final stats = snapshot.data!;
          final totalBrands = stats['totalBrands'] as int;
          final totalProducts = stats['totalProducts'] as int;
          final totalPosters = stats['totalPosters'] as int;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Avatar
                Container(
                  width: screenSize.width * 0.25,
                  height: screenSize.width * 0.25,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [
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
                  clipBehavior: Clip.hardEdge,
                  child: _currentUser?.avatar != null && _currentUser!.avatar!.isNotEmpty
                      ? Image.network(
                          _currentUser!.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_rounded,
                            size: screenSize.width * 0.12,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: screenSize.width * 0.12,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(height: 18),

                // Name and Profession
                Text(
                  _currentUser?.name ?? AppStrings.marketMindUser,
                  style: AppTextStyles.titleMedium(isDark),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser?.email ?? AppStrings.contentCreator,
                  style: AppTextStyles.bodySmall(isDark),
                ),
                const SizedBox(height: 28),

                // Stats Grid (1x3)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        icon: Icons.video_library_rounded,
                        count: totalProducts.toString(),
                        label: AppStrings.videos,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        icon: Icons.shopping_bag_rounded,
                        count: totalBrands.toString(),
                        label: AppStrings.products,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        isDark,
                        icon: Icons.image_rounded,
                        count: totalPosters.toString(),
                        label: AppStrings.posters,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Action Buttons (1x4 Column)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showAccountModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPrimary,
                      foregroundColor: AppColors.buttonText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.accountDetails,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showSettingsModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.settings_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.settings,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showAboutModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.about,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showLogoutModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.logout,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
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

  Widget _buildStatCard(
    bool isDark, {
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.6),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 8),
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
}
