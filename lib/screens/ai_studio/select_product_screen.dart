import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/utils/app_transitions.dart';
import 'package:market_mind/widgets/product_selector_card.dart';
import 'package:market_mind/screens/ai_studio/scene_editor_screen.dart';

class _MockProduct {
  final String id;
  final String name;
  final String type;
  final Color accentColor;
  final IconData icon;

  const _MockProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.accentColor,
    required this.icon,
  });
}

const _kMockProducts = [
  _MockProduct(
    id: '1',
    name: 'Serum Bottle',
    type: 'Cosmetic',
    accentColor: Color(0xFFe96c8a),
    icon: Icons.science_rounded,
  ),
  _MockProduct(
    id: '2',
    name: 'Running Shoes',
    type: 'Fashion',
    accentColor: Color(0xFF4286f4),
    icon: Icons.directions_run_rounded,
  ),
  _MockProduct(
    id: '3',
    name: 'Protein Shake',
    type: 'Health',
    accentColor: Color(0xFF11998e),
    icon: Icons.fitness_center_rounded,
  ),
  _MockProduct(
    id: '4',
    name: 'Smart Watch',
    type: 'Tech',
    accentColor: Color(0xFF7b4397),
    icon: Icons.watch_rounded,
  ),
  _MockProduct(
    id: '5',
    name: 'Coffee Blend',
    type: 'Food & Bev',
    accentColor: Color(0xFFf7971e),
    icon: Icons.coffee_rounded,
  ),
  _MockProduct(
    id: '6',
    name: 'Perfume',
    type: 'Luxury',
    accentColor: Color(0xFF434343),
    icon: Icons.spa_rounded,
  ),
];

class SelectProductScreen extends StatefulWidget {
  final String sceneTitle;
  final List<Color> gradientColors;

  const SelectProductScreen({
    super.key,
    required this.sceneTitle,
    required this.gradientColors,
  });

  @override
  State<SelectProductScreen> createState() => _SelectProductScreenState();
}

class _SelectProductScreenState extends State<SelectProductScreen> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Product',
          style: AppTextStyles.screenTitle(context, isDark),
        ),
      ),
      body: Column(
        children: [
          // Scene context banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.layers_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Scene: ${widget.sceneTitle}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Subtitle
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Choose a product to place in this scene.',
              style: AppTextStyles.bodySmall(context, isDark),
            ),
          ),

          // Product grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: GridView.builder(
                itemCount: _kMockProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final product = _kMockProducts[index];
                  return ProductSelectorCard(
                    name: product.name,
                    type: product.type,
                    accentColor: product.accentColor,
                    icon: product.icon,
                    isSelected: _selectedProductId == product.id,
                    onTap: () {
                      setState(() {
                        _selectedProductId = product.id;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add product button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add Product flow coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '+ Add Product',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedProductId == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            FadeSlideRoute(
                              page: SceneEditorScreen(
                                sceneTitle: widget.sceneTitle,
                                gradientColors: widget.gradientColors,
                                productName: _kMockProducts
                                    .firstWhere(
                                      (p) => p.id == _selectedProductId,
                                    )
                                    .name,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: AppColors.buttonText,
                    disabledBackgroundColor:
                        AppColors.buttonPrimary.withValues(alpha: 0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
