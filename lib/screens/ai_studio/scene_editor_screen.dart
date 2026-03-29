import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/utils/app_transitions.dart';
import 'package:market_mind/widgets/preview_canvas.dart';
import 'package:market_mind/widgets/color_picker_row.dart';
import 'package:market_mind/widgets/scene_option_tile.dart';
import 'package:market_mind/screens/ai_studio/scene_generation_screen.dart';

class SceneEditorScreen extends StatefulWidget {
  final String sceneTitle;
  final List<Color> gradientColors;
  final String productName;

  const SceneEditorScreen({
    super.key,
    required this.sceneTitle,
    required this.gradientColors,
    required this.productName,
  });

  @override
  State<SceneEditorScreen> createState() => _SceneEditorScreenState();
}

class _SceneEditorScreenState extends State<SceneEditorScreen> {
  Color _selectedColor = const Color(0xFF434343);
  String _selectedLayout = 'Centered Focus';
  String _selectedTheme = 'Minimal';

  final _colors = const [
    Color(0xFF434343),
    Color(0xFF1CB5E0),
    Color(0xFFe96c8a),
    Color(0xFF11998e),
    Color(0xFF7b4397),
    Color(0xFFf7971e),
    Color(0xFF4286f4),
    Color(0xFF000000),
  ];

  final _layouts = const [
    ('Centered Focus', Icons.center_focus_strong_rounded,
        'Product in the center'),
    ('Rule of Thirds', Icons.grid_on_rounded, 'Classic composition rule'),
    ('Flat Lay', Icons.layers_rounded, 'Top-down product layout'),
    ('Dynamic Angle', Icons.rotate_90_degrees_ccw_rounded,
        'Slightly tilted composition'),
  ];

  final _themes = const [
    ('Minimal', Icons.crop_square_rounded, 'Clean and airy'),
    ('Bold', Icons.flash_on_rounded, 'High contrast and punchy'),
    ('Luxe', Icons.diamond_rounded, 'Rich and premium feel'),
    ('Natural', Icons.eco_rounded, 'Organic and earthy tones'),
  ];

  List<Color> get _previewGradient {
    return [_selectedColor, widget.gradientColors.last];
  }

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
          'Scene Editor',
          style: AppTextStyles.screenTitle(context, isDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview canvas
            PreviewCanvas(
              gradientColors: _previewGradient,
              label: widget.sceneTitle,
              height: 200,
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Live preview updates as you customize',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product info chip
            Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 15,
                  color: AppColors.buttonPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Product: ',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  widget.productName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Background Color Section
            _SectionHeader(label: 'Background Color', isDark: isDark),
            const SizedBox(height: 12),
            ColorPickerRow(
              colors: _colors,
              selectedColor: _selectedColor,
              onColorSelected: (c) => setState(() => _selectedColor = c),
            ),
            const SizedBox(height: 24),

            // Layout Section
            _SectionHeader(label: 'Layout Style', isDark: isDark),
            const SizedBox(height: 12),
            ..._layouts.map((layout) {
              return SceneOptionTile(
                icon: layout.$2,
                label: layout.$1,
                subtitle: layout.$3,
                isSelected: _selectedLayout == layout.$1,
                onTap: () => setState(() => _selectedLayout = layout.$1),
              );
            }),
            const SizedBox(height: 16),

            // Theme Presets
            _SectionHeader(label: 'Theme Preset', isDark: isDark),
            const SizedBox(height: 12),
            ..._themes.map((theme) {
              return SceneOptionTile(
                icon: theme.$2,
                label: theme.$1,
                subtitle: theme.$3,
                isSelected: _selectedTheme == theme.$1,
                onTap: () => setState(() => _selectedTheme = theme.$1),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            FadeSlideRoute(
              page: SceneGenerationScreen(
                sceneTitle: widget.sceneTitle,
                productName: widget.productName,
                gradientColors: _previewGradient,
              ),
            ),
          );
        },
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.buttonText,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.auto_awesome_rounded),
        label: Text(
          'Generate',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}
