import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/brand_model.dart';
import 'package:market_mind/screens/brand_details/brand_service.dart';
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

  @override
  void initState() {
    super.initState();
    _brand = widget.brand;
  }

  Future<void> _deleteBrand() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Brand',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.brand.name}"? This action cannot be undone.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMutedLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await brandDetailsActionService.deleteBrand(_brand.id);

      if (mounted) {
        AppNotification.success(
          context,
          message: 'Brand deleted successfully!',
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(
              context,
              true,
            ); // Return true to indicate refresh needed
          }
        });
      }
    } catch (e) {
      if (mounted) {
        AppNotification.error(
          context,
          message: 'Failed to delete brand. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMutedLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _MenuOption(
              icon: Icons.edit_rounded,
              label: 'Edit Brand',
              onTap: () async {
                Navigator.pop(context);
                await _editBrand();
              },
            ),
            _MenuOption(
              icon: Icons.share_rounded,
              label: 'Share',
              onTap: () async {
                Navigator.pop(context);
                await _shareBrand();
              },
            ),
            _MenuOption(
              icon: Icons.delete_rounded,
              label: 'Delete',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _deleteBrand();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(),
                        DecoratedBox(
                          decoration: BoxDecoration(
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
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Text(
                            _brand.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 12,
                  child: _OverlayIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 30,
                  right: 12,
                  child: _OverlayIconButton(
                    icon: Icons.more_vert_rounded,
                    onTap: _showOptionsMenu,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_brand.description != null &&
                      _brand.description!.trim().isNotEmpty) ...[
                    _SectionTitle('Description'),
                    const SizedBox(height: 6),
                    Text(
                      _brand.description!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  _SectionTitle('Details'),
                  const SizedBox(height: 8),
                  _SimpleDetailRow(
                    heading: 'Category',
                    value: _brand.category?.trim().isNotEmpty == true
                        ? _brand.category!
                        : 'Not set',
                  ),
                  _SimpleDetailRow(
                    heading: 'Target Audience',
                    value: _brand.targetAudience?.trim().isNotEmpty == true
                        ? _brand.targetAudience!
                        : 'Not set',
                  ),
                  _SimpleDetailRow(
                    heading: 'Productions',
                    value:
                        '${_brand.productions} production${_brand.productions == 1 ? '' : 's'}',
                  ),
                  _SimpleDetailRow(
                    heading: 'Created',
                    value: _formatDate(_brand.createdAt),
                  ),
                  _SimpleDetailRow(
                    heading: 'Updated',
                    value: _formatDate(_brand.updatedAt),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isDeleting ? null : _deleteBrand,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _editBrand,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.darkCardAlt
                                  : AppColors.lightCardAlt,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Edit',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _shareBrand,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: isDark
                                  ? AppColors.darkCardAlt
                                  : AppColors.lightCardAlt,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Share',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareBrand() async {
    try {
      await brandDetailsActionService.shareBrand(_brand);
      if (!mounted) return;
      AppNotification.success(
        context,
        message: 'Brand details copied for sharing',
      );
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Unable to share brand now');
    }
  }

  Future<void> _editBrand() async {
    try {
      final updated = await brandDetailsActionService.editBrand(brand: _brand);
      if (!mounted) return;
      setState(() {
        _brand = updated;
      });
      AppNotification.info(
        context,
        message: 'Edit flow will be connected next',
      );
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Unable to open edit right now');
    }
  }

  Widget _buildImage() {
    if (_brand.imagePath.startsWith('http')) {
      return Image.network(
        _brand.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    } else {
      final file = File(_brand.imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
      return _placeholderImage();
    }
  }

  Widget _placeholderImage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: 80,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textMutedLight,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

class _SimpleDetailRow extends StatelessWidget {
  final String heading;
  final String value;

  const _SimpleDetailRow({required this.heading, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              heading,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMutedLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.26),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
