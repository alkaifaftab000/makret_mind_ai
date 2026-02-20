import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class ProductGenerationScreen extends StatefulWidget {
  final ProductModel product;

  const ProductGenerationScreen({super.key, required this.product});

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

  VideoPlayerController _buildController(String assetPath) {
    return VideoPlayerController.asset(
      assetPath,
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
      final imageDescription = index < widget.product.imageDescriptions.length
          ? widget.product.imageDescriptions[index]
          : 'Auto generated description for image ${index + 1}';

      return _GeneratedClip(
        id: 'clip_$index',
        sequence: index,
        sourceAsset: source,
        enhancedDescription:
            '${widget.product.prompt}\n\nEnhanced note: $imageDescription',
      );
    });
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
    _showLoadingDialog('Making final video...');
    setState(() => _isGeneratingFinal = true);

    try {
      await Future.delayed(const Duration(seconds: 6));

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      _finalController?.dispose();
      final controller = _buildController(_dummyFinalAsset);
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

  Future<void> _copyLink() async {
    const url = 'https://marketmind.local/final-video/demo';
    await Clipboard.setData(const ClipboardData(text: url));
    if (!mounted) return;
    AppNotification.success(context, message: 'Link copied');
  }

  Future<void> _downloadVideo() async {
    try {
      final bytes = await rootBundle.load(_dummyFinalAsset);
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
          _isFinalReady ? 'Final Video' : 'Generated Short Clips',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
          'Review, reorder and regenerate clips before final merge',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
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
        SizedBox(
          width: double.infinity,
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
              'Make Final Video',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalVideoView(bool isDark) {
    final controller = _finalController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
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
                        controller.value.position + const Duration(seconds: 5),
                      );
                    },
                    icon: const Icon(Icons.forward_5_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      ],
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

  VideoPlayerController _buildController(String assetPath) {
    return VideoPlayerController.asset(
      assetPath,
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
