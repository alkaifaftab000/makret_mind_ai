import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_strings.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/utils/permission_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ProductGenerationScreen extends StatefulWidget {
  final ProductModel product;
  final bool startWithFinal;
  final String? overrideFinalAsset;

  const ProductGenerationScreen({
    super.key,
    required this.product,
    this.startWithFinal = false,
    this.overrideFinalAsset,
  });

  @override
  State<ProductGenerationScreen> createState() =>
      _ProductGenerationScreenState();
}

class _ProductGenerationScreenState extends State<ProductGenerationScreen> {
  static const List<String> _dummyShortAssets = [
    'assets/video/short_clip1.mp4',
    'assets/video/short_clip2.mp4',
    'assets/video/short_clip3.mp4',
  ];

  static const String _dummyFinalAsset = 'assets/video/final_video.mp4';

  late List<_GeneratedClip> _clips;
  bool _isGeneratingFinal = false;
  bool _isFinalReady = false;
  bool _isOpeningClip = false;
  VideoPlayerController? _finalController;

  String get _finalAsset => widget.overrideFinalAsset ?? _dummyFinalAsset;

  bool _isAssetPath(String path) => path.startsWith('assets/');

  VideoPlayerController _buildController(String assetPath) {
    if (_isAssetPath(assetPath)) {
      return VideoPlayerController.asset(
        assetPath,
        viewType: VideoViewType.textureView,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }
    return VideoPlayerController.file(
      File(assetPath),
      viewType: VideoViewType.textureView,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
  }

  @override
  void initState() {
    super.initState();
    _clips = List<_GeneratedClip>.generate(widget.product.imagePaths.length, (
      index,
    ) {
      final source = _dummyShortAssets[index % _dummyShortAssets.length];
      final imageDescription = 'Auto generated description for image ${index + 1}';

      return _GeneratedClip(
        id: 'clip_$index',
        sequence: index,
        sourceAsset: source,
        enhancedDescription:
            '${widget.product.prompt}\n\nEnhanced note: $imageDescription',
      );
    });

    if (widget.startWithFinal) {
      _isFinalReady = true;
      _initFinalPreview();
    }
  }

  @override
  void dispose() {
    _finalController?.dispose();
    super.dispose();
  }

  Future<void> _deleteClip(int index) async {
    if (index == 0 || index == _clips.length - 1) {
      AppNotification.warning(
        context,
        message: 'First and last short clips cannot be deleted',
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Delete Short Clip?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This clip will be removed from sequence.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _clips.removeAt(index);
      for (var i = 0; i < _clips.length; i++) {
        _clips[i] = _clips[i].copyWith(sequence: i);
      }
    });
  }

  Future<void> _playClip(String assetPath) async {
    if (_isOpeningClip) return;
    _isOpeningClip = true;
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ClipPlayerScreen(assetPath: assetPath),
        ),
      );
    } finally {
      _isOpeningClip = false;
    }
  }

  Future<void> _regenerateClip(int index) async {
    final promptController = TextEditingController();

    final customPrompt = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Regenerate Clip ${index + 1}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: promptController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add prompt for regeneration',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, promptController.text.trim()),
            child: Text('Regenerate', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    promptController.dispose();

    if (customPrompt == null || customPrompt.isEmpty) return;

    _showLoadingDialog('Regenerating short clip...');
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pop(context);

    final randomAsset =
        _dummyShortAssets[Random().nextInt(_dummyShortAssets.length)];

    setState(() {
      _clips[index] = _clips[index].copyWith(
        sourceAsset: randomAsset,
        enhancedDescription:
            '${_clips[index].enhancedDescription}\n\nRegenerated with prompt: $customPrompt',
      );
    });

    AppNotification.success(context, message: 'Short clip regenerated');
  }

  Future<void> _uploadShortClip() async {
    if (_clips.length >= 5) {
      AppNotification.warning(
        context,
        message: AppStrings.maxShortClipsReached,
      );
      return;
    }

    final hasPermission =
        await PermissionUtils.requestPhotosPermission() ||
        await PermissionUtils.requestGalleryPermission();

    if (!hasPermission) {
      if (!mounted) return;
      AppNotification.warning(
        context,
        message: 'Permission required to access videos',
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    setState(() {
      _clips.add(
        _GeneratedClip(
          id: 'clip_upload_${DateTime.now().microsecondsSinceEpoch}',
          sequence: _clips.length,
          sourceAsset: picked.path,
          enhancedDescription: 'User uploaded short clip',
        ),
      );
    });

    AppNotification.success(context, message: AppStrings.shortClipUploaded);
  }

  void _showLoadingDialog(String text) {
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.buttonPrimary,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makeFinalVideo() async {
    // Show a quick warning that it's mocked, since real backend video gen is pending
    AppNotification.info(
      context,
      message: 'Triggering local mock render. Real backend pipeline not yet connected.',
    );

    _showLoadingDialog('Making final video...');
    setState(() => _isGeneratingFinal = true);

    try {
      // simulate network request to patch final video
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      _finalController?.dispose();
      final controller = _buildController(_finalAsset);
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _finalController = controller;
        _isGeneratingFinal = false;
        _isFinalReady = true;
      });

      AppNotification.success(context, message: 'Final video is ready');
    } catch (_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
        setState(() {
          _isGeneratingFinal = false;
          _isFinalReady = false;
        });
        AppNotification.error(
          context,
          message: 'Unable to load final video. Please try again.',
        );
      }
    }
  }

  Future<void> _initFinalPreview() async {
    try {
      final controller = _buildController(_finalAsset);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _finalController = controller;
        _isFinalReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(
        context,
        message: 'Unable to load final video preview. Please try again.',
      );
    }
  }

  Future<void> _copyLink() async {
    const url = 'https://marketmind.local/final-video/demo';
    await Clipboard.setData(const ClipboardData(text: url));
    if (!mounted) return;
    AppNotification.success(context, message: 'Link copied');
  }

  Future<void> _downloadVideo() async {
    try {
      final bytes = await rootBundle.load(_finalAsset);
      final dir = await getApplicationDocumentsDirectory();
      final outDir = Directory('${dir.path}/downloads');
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }

      final outFile = File('${outDir.path}/market_mind_final_video.mp4');
      await outFile.writeAsBytes(bytes.buffer.asUint8List());

      if (!mounted) return;
      AppNotification.success(context, message: 'Downloaded to app storage');
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Failed to download video');
    }
  }

  Future<void> _shareVideo() async {
    await _copyLink();
    if (!mounted) return;
    AppNotification.info(context, message: 'Share link copied (demo mode)');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          _isFinalReady
              ? AppStrings.finalVideoTitle
              : AppStrings.generatedShortClipsTitle,
          style: AppTextStyles.screenTitle(isDark),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        child: _isFinalReady
            ? _buildFinalVideoView(isDark)
            : _buildClipsView(isDark),
      ),
    );
  }

  Widget _buildClipsView(bool isDark) {
    return Column(
      children: [
        Text(
          AppStrings.reviewClipsHint,
          style: AppTextStyles.bodySmall(isDark),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _clips.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex -= 1;
              setState(() {
                final item = _clips.removeAt(oldIndex);
                _clips.insert(newIndex, item);
                for (var i = 0; i < _clips.length; i++) {
                  _clips[i] = _clips[i].copyWith(sequence: i);
                }
              });
            },
            itemBuilder: (_, index) {
              final clip = _clips[index];
              return Container(
                key: ValueKey(clip.id),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.buttonPrimary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              color: AppColors.buttonText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Short Clip ${index + 1}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _playClip(clip.sourceAsset),
                          icon: const Icon(Icons.play_circle_fill_rounded),
                        ),
                        IconButton(
                          onPressed: () => _regenerateClip(index),
                          icon: const Icon(Icons.autorenew_rounded),
                        ),
                        IconButton(
                          onPressed: () => _deleteClip(index),
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: (index == 0 || index == _clips.length - 1)
                                ? Colors.grey
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      clip.enhancedDescription,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isGeneratingFinal ? null : _uploadShortClip,
                icon: const Icon(Icons.upload_file_rounded),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.buttonPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: AppColors.buttonPrimary,
                ),
                label: Text(
                  AppStrings.uploadShortClip,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _isGeneratingFinal ? null : _makeFinalVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.buttonText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.makeFinalVideo,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinalVideoView(bool isDark) {
    final controller = _finalController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio == 0
                ? 16 / 9
                : controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: VideoPlayer(controller),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () async {
                  final target =
                      controller.value.position - const Duration(seconds: 5);
                  await controller.seekTo(
                    target.isNegative ? Duration.zero : target,
                  );
                },
                icon: const Icon(Icons.replay_5_rounded),
              ),
              IconButton(
                onPressed: () {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                  setState(() {});
                },
                icon: Icon(
                  controller.value.isPlaying
                      ? Icons.pause_circle_rounded
                      : Icons.play_circle_rounded,
                  size: 34,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await controller.seekTo(Duration.zero);
                  await controller.play();
                  setState(() {});
                },
                icon: const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                onPressed: () async {
                  await controller.seekTo(
                    controller.value.position + const Duration(seconds: 5),
                  );
                },
                icon: const Icon(Icons.forward_5_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareVideo,
                  icon: const Icon(Icons.share_rounded),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.buttonPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: AppColors.buttonPrimary,
                  ),
                  label: Text(
                    'Share',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _downloadVideo,
                  icon: const Icon(Icons.download_rounded),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.buttonPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: AppColors.buttonPrimary,
                  ),
                  label: Text(
                    'Download',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyLink,
                  icon: const Icon(Icons.link_rounded),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.buttonPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: AppColors.buttonPrimary,
                  ),
                  label: Text(
                    'Copy Link',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildConfigurationSection(isDark),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection(bool isDark) {
    final items = [
      ('Product', widget.product.name),
      ('Tone', widget.product.tone),
      ('Model', widget.product.modelType),
      ('Audio', widget.product.audioType),
      ('Aspect', widget.product.aspectRatio),
      ('Length', widget.product.videoLength ?? 'Not specified'),
      ('Clips', '${_clips.length}'),
      ('Type', widget.product.type.toUpperCase()),
      ('Status', 'Final Ready'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Configuration',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Applied settings for this final render',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (_, index) => _buildConfigTile(
            isDark,
            label: items[index].$1,
            value: items[index].$2,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigTile(
    bool isDark, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardAlt : AppColors.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedClip {
  final String id;
  final int sequence;
  final String sourceAsset;
  final String enhancedDescription;

  const _GeneratedClip({
    required this.id,
    required this.sequence,
    required this.sourceAsset,
    required this.enhancedDescription,
  });

  _GeneratedClip copyWith({
    String? id,
    int? sequence,
    String? sourceAsset,
    String? enhancedDescription,
  }) {
    return _GeneratedClip(
      id: id ?? this.id,
      sequence: sequence ?? this.sequence,
      sourceAsset: sourceAsset ?? this.sourceAsset,
      enhancedDescription: enhancedDescription ?? this.enhancedDescription,
    );
  }
}

class _ClipPlayerScreen extends StatefulWidget {
  final String assetPath;

  const _ClipPlayerScreen({required this.assetPath});

  @override
  State<_ClipPlayerScreen> createState() => _ClipPlayerScreenState();
}

class _ClipPlayerScreenState extends State<_ClipPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  bool _isAssetPath(String path) => path.startsWith('assets/');

  VideoPlayerController _buildController(String assetPath) {
    if (_isAssetPath(assetPath)) {
      return VideoPlayerController.asset(
        assetPath,
        viewType: VideoViewType.textureView,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }
    return VideoPlayerController.file(
      File(assetPath),
      viewType: VideoViewType.textureView,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = _buildController(widget.assetPath);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to play this clip';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = _controller;

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
          'Short Clip Preview',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            )
          : controller == null
          ? const SizedBox.shrink()
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio == 0
                          ? 16 / 9
                          : controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          final target =
                              controller.value.position -
                              const Duration(seconds: 5);
                          await controller.seekTo(
                            target.isNegative ? Duration.zero : target,
                          );
                        },
                        icon: const Icon(Icons.replay_5_rounded),
                      ),
                      IconButton(
                        onPressed: () {
                          if (controller.value.isPlaying) {
                            controller.pause();
                          } else {
                            controller.play();
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause_circle_rounded
                              : Icons.play_circle_rounded,
                          size: 34,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await controller.seekTo(Duration.zero);
                          await controller.play();
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                      IconButton(
                        onPressed: () async {
                          await controller.seekTo(
                            controller.value.position +
                                const Duration(seconds: 5),
                          );
                        },
                        icon: const Icon(Icons.forward_5_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
