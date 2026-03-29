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

  // Mock creations data
  final List<String> _mockCreations = [
    'https://picsum.photos/seed/c1/400/400',
    'https://picsum.photos/seed/c2/400/400',
    'https://picsum.photos/seed/c3/400/400',
    'https://picsum.photos/seed/c4/400/400',
  ];

  final List<String> _mockScenes = [
    'https://picsum.photos/seed/s1/400/200',
    'https://picsum.photos/seed/s2/400/200',
    'https://picsum.photos/seed/s3/400/200',
  ];

  @override
  void initState() {
    super.initState();
    _profileStats = _loadStats();
  }

  Future<Map<String, dynamic>> _loadStats() async {
    try {
      _currentUser = await userService.getCurrentUser();
    } catch (e) {
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
      'credits': 100, // Mock premium credit count
      'creations': 42, // Mock total AI generations
    };
  }

  Future<void> _showAccountModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AccountModal(),
    );
    if (mounted) {
      setState(() {
        _profileStats = _loadStats();
      });
    }
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
    // Enforcing Dark Premium Theme constraint
    final isDark = Theme.of(context).brightness == Brightness.dark || true; // Let's respect system but force dark styling heavily
    final screenThemeDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: screenThemeDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                style: AppTextStyles.bodyMedium(context, screenThemeDark),
              ),
            );
          }

          final stats = snapshot.data!;
          final credits = stats['credits'] as int;
          final creations = stats['creations'] as int;
          final scenes = stats['totalProducts'] as int; // using as substitute
          final templates = stats['totalBrands'] as int;

          return Container(
            // Premium background
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: screenThemeDark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B).withValues(alpha: 0.8)]
                    : [AppColors.lightBackground, const Color(0xFFF3E8FF)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Profile',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: screenThemeDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: _showSettingsModal,
                          icon: Icon(
                            Icons.settings_rounded,
                            color: screenThemeDark ? Colors.white : Colors.black87,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Profile Card
                    _ProfileCard(
                      user: _currentUser,
                      isDark: screenThemeDark,
                      stats: {
                        'Creations': creations.toString(),
                        'Scenes': scenes.toString(),
                        'Templates': templates.toString(),
                        'Credits 🪙': credits.toString(),
                      },
                      onEditTap: _showAccountModal,
                    ),
                    const SizedBox(height: 20),

                    // 3. Pro & Credits Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7b4397), Color(0xFF4286f4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7b4397).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Pro Member ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text('💎', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You have $credits credits remaining',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Upgrade',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF4286f4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Quick Actions
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: screenThemeDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.person_outline_rounded,
                            label: 'Edit',
                            isDark: screenThemeDark,
                            onTap: _showAccountModal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.info_outline_rounded,
                            label: 'About',
                            isDark: screenThemeDark,
                            onTap: _showAboutModal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            isDark: screenThemeDark,
                            isDestructive: true,
                            onTap: _showLogoutModal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 5. User Creations Section
                    Text(
                      'Your Creations',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: screenThemeDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: _mockCreations.length,
                      itemBuilder: (context, index) {
                        return _CreationGridCard(
                          imageUrl: _mockCreations[index],
                          label: 'AI Gen #${index + 1}',
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // 6. Saved Scenes
                    Text(
                      'Your Scenes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: screenThemeDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _mockScenes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: _CreationGridCard(
                              imageUrl: _mockScenes[index],
                              label: 'Scene ${index + 1}',
                              width: 220,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final UserModel? user;
  final bool isDark;
  final Map<String, String> stats;
  final VoidCallback onEditTap;

  const _ProfileCard({
    required this.user,
    required this.isDark,
    required this.stats,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9061F9), Color(0xFF4286f4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: user?.avatar != null && user!.avatar!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(user!.avatar!),
                              fit: BoxFit.cover,
                            )
                          : const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/150?img=47'), // Mock
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Jenny Wilson',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF9061F9).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Creator ✨',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF9061F9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEditTap,
                icon: Icon(Icons.edit_rounded, color: isDark ? Colors.white70 : Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats.entries.map((entry) {
              return Column(
                children: [
                  Text(
                    entry.value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.key,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.isDark,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color baseColor = isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: baseColor, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: baseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreationGridCard extends StatelessWidget {
  final String imageUrl;
  final String label;
  final double? width;

  const _CreationGridCard({
    required this.imageUrl,
    required this.label,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 12,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
