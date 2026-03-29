import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/utils/app_transitions.dart';
import 'package:market_mind/widgets/color_picker_row.dart';
import 'package:market_mind/widgets/scene_option_tile.dart';
import 'package:market_mind/screens/ai_studio/select_product_screen.dart';

class CreateSceneScreen extends StatefulWidget {
  const CreateSceneScreen({super.key});

  @override
  State<CreateSceneScreen> createState() => _CreateSceneScreenState();
}

class _CreateSceneScreenState extends State<CreateSceneScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = const Color(0xFF4286f4);
  String _selectedLayout = 'Centered Focus';
  bool _isSaving = false;

  final _colors = const [
    Color(0xFF4286f4),
    Color(0xFF11998e),
    Color(0xFFe96c8a),
    Color(0xFF7b4397),
    Color(0xFFf7971e),
    Color(0xFF1CB5E0),
    Color(0xFF434343),
    Color(0xFF000000),
  ];

  final _bgStyles = const [
    ('Gradient', Icons.gradient_rounded, 'Smooth color transition'),
    ('Solid Color', Icons.format_color_fill_rounded, 'Single flat color'),
    ('Blurred', Icons.blur_on_rounded, 'Soft blurred background'),
    ('Textured', Icons.texture_rounded, 'Subtle surface texture'),
  ];

  String _selectedBgStyle = 'Gradient';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scene name is required')),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.push(
      context,
      FadeSlideRoute(
        page: SelectProductScreen(
          sceneTitle: _nameController.text.trim(),
          gradientColors: [_selectedColor, _selectedColor.withValues(alpha: 0.5)],
        ),
      ),
    );
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
          'Create Scene',
          style: AppTextStyles.screenTitle(context, isDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Design a reusable scene for AI generation.',
              style: AppTextStyles.bodySmall(context, isDark),
            ),
            const SizedBox(height: 20),

            // Scene name input
            _FieldLabel(label: 'Scene Name *', isDark: isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: AppTextStyles.fieldText(context, isDark),
              decoration: InputDecoration(
                hintText: 'e.g. Summer Vibes',
                hintStyle: AppTextStyles.fieldHint(context, isDark),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Background style
            _FieldLabel(label: 'Background Style', isDark: isDark),
            const SizedBox(height: 12),
            ..._bgStyles.map((style) {
              return SceneOptionTile(
                icon: style.$2,
                label: style.$1,
                subtitle: style.$3,
                isSelected: _selectedBgStyle == style.$1,
                onTap: () => setState(() => _selectedBgStyle = style.$1),
              );
            }),
            const SizedBox(height: 20),

            // Color selection
            _FieldLabel(label: 'Primary Color', isDark: isDark),
            const SizedBox(height: 12),
            ColorPickerRow(
              colors: _colors,
              selectedColor: _selectedColor,
              onColorSelected: (c) => setState(() => _selectedColor = c),
            ),
            const SizedBox(height: 22),

            // Layout type
            _FieldLabel(label: 'Layout Type', isDark: isDark),
            const SizedBox(height: 12),
            _LayoutChips(
              layouts: const [
                'Centered Focus',
                'Rule of Thirds',
                'Flat Lay',
                'Dynamic',
              ],
              selected: _selectedLayout,
              isDark: isDark,
              onSelected: (val) => setState(() => _selectedLayout = val),
            ),
            const SizedBox(height: 32),

            // Color preview strip
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _selectedColor,
                      _selectedColor.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _nameController.text.isEmpty
                        ? 'Scene Preview'
                        : _nameController.text,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.buttonText,
                  disabledBackgroundColor:
                      AppColors.buttonPrimary.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Save & Continue',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
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

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _FieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

class _LayoutChips extends StatelessWidget {
  final List<String> layouts;
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelected;

  const _LayoutChips({
    required this.layouts,
    required this.selected,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: layouts.map((layout) {
        final isSelected = layout == selected;
        return GestureDetector(
          onTap: () => onSelected(layout),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.buttonPrimary
                  : (isDark ? AppColors.darkCard : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.buttonPrimary : AppColors.divider,
              ),
            ),
            child: Text(
              layout,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.buttonText
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
