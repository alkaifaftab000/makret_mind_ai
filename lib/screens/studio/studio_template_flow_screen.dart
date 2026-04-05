import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/models/studio_model.dart';
import 'package:market_mind/services/product_service.dart';
import 'package:market_mind/services/studio_service.dart';
import "package:market_mind/utils/app_notification.dart";
import "package:market_mind/widgets/kie_image.dart";
import "package:market_mind/services/kie_service.dart";
import "package:market_mind/services/cloudinary_service.dart";
import "package:market_mind/services/kie_ai_service.dart";
class StudioTemplateFlowScreen extends StatefulWidget {
  final ProductModel product;
  final String templateName;
  final String templateCategory;
  final String initialPrompt;
  final String initialAspectRatio;

  const StudioTemplateFlowScreen({
    super.key,
    required this.product,
    required this.templateName,
    required this.templateCategory,
    required this.initialPrompt,
    required this.initialAspectRatio,
  });

  @override
  State<StudioTemplateFlowScreen> createState() =>
      _StudioTemplateFlowScreenState();
}

class _StudioTemplateFlowScreenState extends State<StudioTemplateFlowScreen> {
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isCreatingModel = false;

  List<AIHumanModel> _models = [];
  List<SceneTemplate> _scenes = [];
  StudioAppOptions _appOptions = const StudioAppOptions();

  AIHumanModel? _selectedModel;
  SceneTemplate? _selectedScene;

  late ProductModel _product;
  Timer? _pollTimer;

  // Active Kie AI polls (taskId → completer)
  final Map<String, Completer<void>> _activePolls = {};

  String _pose = '';
  String _expression = '';
  String _cameraAngle = 'eye level';
  String _resolution = '1K';
  String _outputFormat = 'jpg';
  int _numImages = 1;

  late final TextEditingController _promptController;

  static const List<String> _cameraAngles = [
    'eye level',
    'low angle',
    'high angle',
    'overhead',
    'dutch angle',
    'profile side shot',
  ];

  static const List<String> _resolutions = ['1K', '2K', '4K'];
  static const List<String> _outputFormats = ['jpg', 'png', 'jpeg'];

  List<StudioImageJob> _fetchedStudioJobs = [];

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _promptController = TextEditingController(text: widget.initialPrompt);
    _loadInitialData();
    // Note: _startPollingIfNeeded() is called at the end of _loadInitialData
    // after existing studio jobs have been fetched.
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    for (final completer in _activePolls.values) {
      if (!completer.isCompleted) completer.complete();
    }
    _activePolls.clear();
    _promptController.dispose();
    super.dispose();
  }

  // ─── Polling ─────────────────────────────────────────────────────

  List<StudioImageJob> get _activeJobsList {
    return _fetchedStudioJobs.isNotEmpty ? _fetchedStudioJobs : _product.studioImages;
  }

  bool get _hasActiveJobs => _activeJobsList.any(
        (p) => p.status == 'processing' || p.status == 'pending',
      );

  void _startPollingIfNeeded() {
    // Poll backend periodically
    if (_hasActiveJobs && _pollTimer == null) {
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
        await _refreshProduct(silent: true);
        if (!_hasActiveJobs) {
          _pollTimer?.cancel();
          _pollTimer = null;
        }
      });
    }

    // Direct Kie AI Polling if taskId is available
    for (final job in _activeJobsList) {
      if ((job.status == 'processing' || job.status == 'pending') &&
          job.taskId != null &&
          job.taskId!.isNotEmpty) {
        _pollKieAiForStudioJob(job.id, job.taskId!);
      }
    }
  }

  Future<void> _pollKieAiForStudioJob(String shotId, String taskId) async {
    if (_activePolls.containsKey(taskId)) return;

    final completer = Completer<void>();
    _activePolls[taskId] = completer;

    try {
      final result = await kieAiService.pollUntilComplete(
        taskId,
        pollInterval: const Duration(seconds: 5),
        timeout: const Duration(minutes: 10),
      );

      if (!mounted) return;

      if (result.isCompleted) {
        List<String> permanentUrls = [];
        
        for (final url in result.resultUrls) {
           String downloadableUrl = url;
           final tempDownloadUrl = await kieAiService.getDownloadUrl(url);
           if (tempDownloadUrl != null) {
              downloadableUrl = tempDownloadUrl;
           }
           final uploadedUrl = await cloudinaryService.uploadImageFromUrl(
              downloadableUrl,
              folder: 'studio',
           );
           if (uploadedUrl != null) {
              permanentUrls.add(uploadedUrl);
           }
        }

        _updateJobLocally(shotId, 'completed', permanentUrls, null);

        if (mounted) {
          AppNotification.success(context, message: 'Studio image generated successfully! 🎨');
        }
        
        // Kick off another backend refresh to grab any backend updates too
        await _refreshProduct(silent: true);
      } else if (result.isFailed) {
        _updateJobLocally(shotId, 'failed', const [], result.error ?? 'Generation failed');
        if (mounted) {
          AppNotification.error(context, message: 'Studio generation failed: ${result.error}');
        }
      }
    } catch (e) {
      // ignore
    } finally {
      _activePolls.remove(taskId);
      if (!completer.isCompleted) completer.complete();
    }
  }

  void _updateJobLocally(String shotId, String status, List<String> outputs, String? error) {
    if (!mounted) return;
    setState(() {
      final updatedJobs = _fetchedStudioJobs.map((j) {
        if (j.id == shotId) {
          return StudioImageJob(
            id: j.id,
            status: status,
            outputs: outputs.isNotEmpty ? outputs : j.outputs,
            createdAt: j.createdAt,
            error: error ?? j.error,
            taskId: j.taskId,
          );
        }
        return j;
      }).toList();
      _fetchedStudioJobs = updatedJobs;
    });
  }

  Future<void> _refreshProduct({bool silent = false}) async {
    try {
      final updated = await ProductService().getProductById(_product.id);
      
      List<StudioImageJob> mappedJobs = [];
      try {
        final rawJobs = await studioService.getProductStudioJobs(_product.id);
        for (final job in rawJobs) {
          for (final shot in job.shots) {
            mappedJobs.add(StudioImageJob(
              id: shot.id,
              status: shot.status,
              outputs: shot.outputs,
              createdAt: job.createdAt ?? DateTime.now(),
              error: shot.error,
              taskId: shot.taskId,
            ));
          }
        }
        // ignore: empty_catches
      } catch (_) {}

      // Preserve local completed jobs if backend is stale
      for (var i = 0; i < mappedJobs.length; i++) {
        final existing = _fetchedStudioJobs.where((j) => j.id == mappedJobs[i].id).firstOrNull;
        if (existing != null && existing.status == 'completed' && mappedJobs[i].status != 'completed') {
          // Backend is out of sync, keep our frontend updated version
          mappedJobs[i] = existing;
        } else if (existing != null && existing.status == 'failed' && mappedJobs[i].status != 'failed') {
          // Keep our local failure error
          mappedJobs[i] = existing;
        }
      }

      if (mounted) {
        setState(() {
          if (updated != null) {
            _product = updated;
          }
          if (mappedJobs.isNotEmpty) {
            _fetchedStudioJobs = mappedJobs;
          }
        });
        _startPollingIfNeeded();
      }
    } catch (_) {}
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final models = await studioService.getStudioModels();
      final scenes = await studioService.getSceneTemplates();
      final appOptions = await studioService.getAppOptions();

      if (!mounted) return;
      setState(() {
        _models = models;
        _scenes = scenes;
        _appOptions = appOptions;
        if (_appOptions.cameraAngles.isNotEmpty) {
          _cameraAngle = _appOptions.cameraAngles.first;
        }
        if (_appOptions.resolutions.isNotEmpty) {
          _resolution = _appOptions.resolutions.first;
        }
        if (_appOptions.outputFormats.isNotEmpty) {
          _outputFormat = _appOptions.outputFormats.first;
        }
      });

      // Fetch existing studio jobs so the screen shows any previous results
      // immediately on open, without waiting for a user action.
      await _refreshProduct(silent: true);
    } catch (_) {
      if (!mounted) return;
      AppNotification.error(
        context,
        message: 'Failed to load studio setup data',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        // Start polling AFTER data (including existing jobs) has been fetched
        _startPollingIfNeeded();
      }
    }
  }

  List<String> get _poseOptions => _appOptions.poses.isNotEmpty
      ? _appOptions.poses
      : (_selectedModel?.poses ?? const []);

  List<String> get _expressionOptions => _appOptions.expressions.isNotEmpty
      ? _appOptions.expressions
      : (_selectedModel?.expressions ?? const []);

  List<StudioImageJob> get _activeStudioJobs => _activeJobsList
      .where((j) => ['pending', 'processing'].contains(j.status))
      .toList();

  List<StudioImageJob> get _completedStudioJobs =>
      _activeJobsList.where((j) => j.status == 'completed').toList();

  List<StudioImageJob> get _failedStudioJobs => _activeJobsList
      .where((j) => ['failed', 'canceled'].contains(j.status))
      .toList();

  bool get _canCreateJob {
    final hasPrompt = _promptController.text.trim().isNotEmpty;
    return hasPrompt || _selectedScene != null;
  }

  Future<void> _createStudioJob() async {
    if (!_canCreateJob) {
      AppNotification.warning(
        context,
        message: 'Fill model and add prompt/scene',
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final shot = StudioShotCreate(
        modelId: _selectedModel?.id,
        sceneId: _selectedScene?.id,
        pose: _pose.trim().isEmpty ? null : _pose.trim(),
        expression: _expression.trim().isEmpty ? null : _expression.trim(),
        cameraAngle: _cameraAngle,
        aspectRatio: widget.initialAspectRatio,
        resolution: _resolution,
        outputFormat: _outputFormat,
        customPrompt: _promptController.text.trim().isEmpty
            ? null
            : _promptController.text.trim(),
        numImages: _numImages,
      );

      final request = StudioJobCreateRequest(
        productId: _product.id,
        shots: [shot],
      );

      final jobResponse = await studioService.createStudioJob(request);
      if (!mounted) return;

      // Immediately show a 'pending' processing card so the user sees visual
      // feedback without waiting for the first poll cycle.
      setState(() {
        _fetchedStudioJobs = [
          StudioImageJob(
            id: jobResponse.jobId,
            status: 'pending',
            outputs: const [],
            createdAt: DateTime.now(),
            // Use the real taskId if returned by backend, never guess from jobId
            taskId: jobResponse.taskId,
          ),
          ..._fetchedStudioJobs,
        ];
      });

      AppNotification.success(
        context,
        message: 'AI Studio generation started! Images will appear below when ready.',
      );

      // Start polling immediately so the 'pending' card turns into results
      _startPollingIfNeeded();

      // Also do an immediate refresh to pick up the real job record
      await _refreshProduct();
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(context, message: 'Failed to generate studio images: $e');
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _showAddModelSheet() async {
    final nameController = TextEditingController();
    final genderController = TextEditingController(text: 'female');
    final avatarController = TextEditingController();
    final refsController = TextEditingController();

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : AppColors.lightBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add AI Model',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInput(nameController, 'Name', isDark),
                    const SizedBox(height: 10),
                    _buildInput(
                      genderController,
                      'Gender (male/female)',
                      isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildInput(avatarController, 'Avatar URL', isDark),
                    const SizedBox(height: 10),
                    _buildInput(
                      refsController,
                      'Reference image URLs (comma separated)',
                      isDark,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCreatingModel
                            ? null
                            : () async {
                                final refs = refsController.text
                                    .split(',')
                                    .map((e) => e.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();

                                if (nameController.text.trim().isEmpty ||
                                    genderController.text.trim().isEmpty ||
                                    avatarController.text.trim().isEmpty ||
                                    refs.isEmpty) {
                                  AppNotification.warning(
                                    context,
                                    message: 'Fill all required model fields',
                                  );
                                  return;
                                }

                                setState(() => _isCreatingModel = true);
                                setModalState(() {});

                                try {
                                  final payload = AIHumanModelCreate(
                                    name: nameController.text.trim(),
                                    gender: genderController.text.trim(),
                                    avatar: avatarController.text.trim(),
                                    referenceImages: refs,
                                  );

                                  final model = await studioService
                                      .createStudioModel(payload);
                                  if (!mounted) return;
                                  setState(() {
                                    _models = [model, ..._models];
                                    _selectedModel = model;
                                  });
                                  Navigator.pop(context, true);
                                } catch (_) {
                                  if (!mounted) return;
                                  AppNotification.error(
                                    context,
                                    message: 'Failed to create model',
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isCreatingModel = false);
                                  }
                                  setModalState(() {});
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonPrimary,
                          foregroundColor: AppColors.buttonText,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isCreatingModel
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create Model',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (created == true && mounted) {
      AppNotification.success(context, message: 'Model added successfully');
    }
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint,
    bool isDark, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _openModelDetails(AIHumanModel model) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: KieImage(url: 
                      model.avatar,
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 84,
                        height: 84,
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                        child: const Icon(Icons.person_rounded, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
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
                          '${model.gender}${model.ageRange != null ? ' • ${model.ageRange}' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        if (model.ethnicity != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            model.ethnicity!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Reference Images',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              if (model.referenceImages.isEmpty)
                Text(
                  'No reference images available',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                )
              else
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: model.referenceImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, index) {
                      final ref = model.referenceImages[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              child: InteractiveViewer(
                                child: KieImage(url: ref, fit: BoxFit.contain),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: KieImage(url: 
                            ref,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 110,
                              height: 110,
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              child: const Icon(Icons.broken_image_rounded),
                            ),
                          ),
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
        title: Text(
          widget.templateName,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Jobs
                  if (_activeStudioJobs.isNotEmpty) ...[
                    _SectionLabel('Generating...', isDark: isDark),
                    const SizedBox(height: 10),
                    ..._activeStudioJobs.map(
                      (job) => _ProcessingCard(job: job, isDark: isDark),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Completed Jobs
                  if (_completedStudioJobs.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel(
                          'Generated Studio Images',
                          isDark: isDark,
                        ),
                        Text(
                          '${_completedStudioJobs.length} item${_completedStudioJobs.length > 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _completedStudioJobs.length,
                      itemBuilder: (context, index) {
                        final job = _completedStudioJobs[index];
                        return _StudioGridItem(
                          job: job,
                          isDark: isDark,
                          onTap: () {
                            if (job.outputs.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => _StudioJobResultScreen(
                                    job: job,
                                    productId: _product.id,
                                    onImageSelected: () {
                                      _refreshProduct();
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Failed Jobs
                  if (_failedStudioJobs.isNotEmpty) ...[
                    _SectionLabel('Failed', isDark: isDark),
                    const SizedBox(height: 8),
                    ..._failedStudioJobs.map(
                      (job) => _FailedCard(job: job, isDark: isDark),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Template',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.templateCategory} • ${widget.initialAspectRatio}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _SectionTitle(title: '1. Selected Product', isDark: isDark),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        if (widget.product.images.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 94,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: widget.product.images.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, index) {
                                final imageUrl = widget.product.images[index];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: KieImage(url: 
                                    imageUrl,
                                    width: 94,
                                    height: 94,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 94,
                                      height: 94,
                                      color: isDark
                                          ? AppColors.darkCard
                                          : AppColors.lightCard,
                                      child: const Icon(
                                        Icons.broken_image_rounded,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionTitle(
                        title: _selectedModel == null
                            ? '2. Select Model (Optional)'
                            : '2. Select Model',
                        isDark: isDark,
                      ),
                      TextButton.icon(
                        onPressed: _showAddModelSheet,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          'Add Model',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_models.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No models available',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create one model to continue',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _models.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.82,
                          ),
                      itemBuilder: (_, index) {
                        if (index == 0) {
                          final selected = _selectedModel == null;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedModel = null),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard,
                                border: Border.all(
                                  color: selected
                                      ? AppColors.buttonPrimary
                                      : AppColors.divider.withValues(
                                          alpha: 0.5,
                                        ),
                                  width: selected ? 1.8 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.darkBackground
                                            : AppColors.lightBackground,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.divider.withValues(
                                            alpha: 0.35,
                                          ),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.block_rounded,
                                          size: 34,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No Model',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          setState(() => _selectedModel = null),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                        ),
                                        backgroundColor: selected
                                            ? AppColors.buttonPrimary
                                            : (isDark
                                                  ? AppColors.darkBackground
                                                  : AppColors.lightBackground),
                                        foregroundColor: selected
                                            ? AppColors.buttonText
                                            : (isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimaryLight),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        selected ? 'Selected' : 'Use None',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final model = _models[index - 1];
                        final selected = _selectedModel?.id == model.id;
                        return GestureDetector(
                          onTap: () => _openModelDetails(model),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              border: Border.all(
                                color: selected
                                    ? AppColors.buttonPrimary
                                    : AppColors.divider.withValues(alpha: 0.5),
                                width: selected ? 1.8 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: KieImage(url: 
                                      model.avatar,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: isDark
                                            ? AppColors.darkBackground
                                            : AppColors.lightBackground,
                                        child: const Icon(
                                          Icons.person_rounded,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  model.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        setState(() => _selectedModel = model),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      backgroundColor: selected
                                          ? AppColors.buttonPrimary
                                          : (isDark
                                                ? AppColors.darkBackground
                                                : AppColors.lightBackground),
                                      foregroundColor: selected
                                          ? AppColors.buttonText
                                          : (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      selected ? 'Selected' : 'Use Model',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                  _SectionTitle(title: '4. Required Inputs', isDark: isDark),
                  const SizedBox(height: 8),

                  _buildSceneSelector(isDark),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _promptController,
                    maxLines: 3,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: _inputDecoration(
                      isDark,
                      'Custom prompt (required if scene not selected)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildChoiceSection(
                    isDark: isDark,
                    title: 'Pose',
                    values: _poseOptions,
                    selectedValue: _pose,
                    onSelected: (value) => setState(() => _pose = value),
                    emptyLabel: 'No pose options returned by the API',
                  ),
                  const SizedBox(height: 10),
                  _buildChoiceSection(
                    isDark: isDark,
                    title: 'Expression',
                    values: _expressionOptions,
                    selectedValue: _expression,
                    onSelected: (value) => setState(() => _expression = value),
                    emptyLabel: 'No expression options returned by the API',
                  ),
                  const SizedBox(height: 10),
                  _buildChoiceSection(
                    isDark: isDark,
                    title: 'Camera Angle',
                    values: _appOptions.cameraAngles.isNotEmpty
                        ? _appOptions.cameraAngles
                        : _cameraAngles,
                    selectedValue: _cameraAngle,
                    onSelected: (value) => setState(() => _cameraAngle = value),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceSection(
                          isDark: isDark,
                          title: 'Resolution',
                          values: _appOptions.resolutions.isNotEmpty
                              ? _appOptions.resolutions
                              : _resolutions,
                          selectedValue: _resolution,
                          onSelected: (value) =>
                              setState(() => _resolution = value),
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceSection(
                          isDark: isDark,
                          title: 'Format',
                          values: _appOptions.outputFormats.isNotEmpty
                              ? _appOptions.outputFormats
                              : _outputFormats,
                          selectedValue: _outputFormat,
                          onSelected: (value) =>
                              setState(() => _outputFormat = value),
                          compact: true,
                          uppercase: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Number of images',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _numImages > 1
                            ? () => setState(() => _numImages--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      Text(
                        '$_numImages',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      IconButton(
                        onPressed: _numImages < 8
                            ? () => setState(() => _numImages++)
                            : null,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createStudioJob,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Generate AI Studio Images',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSceneSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scene Template',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        if (_scenes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'No scene templates returned by the backend',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          )
        else
          SizedBox(
            height: 184,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _scenes.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _SceneTemplateCard(
                    isDark: isDark,
                    title: 'No scene template',
                    subtitle: 'Use prompt-only generation',
                    imageUrl: null,
                    selected: _selectedScene == null,
                    onTap: () => setState(() => _selectedScene = null),
                  );
                }

                final scene = _scenes[index - 1];
                return _SceneTemplateCard(
                  isDark: isDark,
                  title: scene.name,
                  subtitle: scene.category,
                  imageUrl: scene.sampleImageUrl,
                  selected: _selectedScene?.id == scene.id,
                  onTap: () => setState(() => _selectedScene = scene),
                );
              },
            ),
          ),
        if (_selectedScene != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedScene!.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedScene!.lightingSetup,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChoiceSection({
    required bool isDark,
    required String title,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onSelected,
    String? emptyLabel,
    bool compact = false,
    bool uppercase = false,
  }) {
    final visibleValues = values
        .where((value) => value.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        if (visibleValues.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              emptyLabel ?? 'No options available',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visibleValues.map((value) {
              final normalized = value.trim();
              final selected = normalized == selectedValue;
              final label = uppercase ? normalized.toUpperCase() : normalized;

              return InkWell(
                onTap: () => onSelected(normalized),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 12 : 14,
                    vertical: compact ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.buttonPrimary
                        : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? AppColors.buttonPrimary
                          : AppColors.divider.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.buttonText
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  InputDecoration _dropdownDecoration(bool isDark, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class _SceneTemplateCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const _SceneTemplateCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.buttonPrimary
                : AppColors.divider.withValues(alpha: 0.45),
            width: selected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    KieImage(url: 
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _sceneFallback(),
                    )
                  else
                    _sceneFallback(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.48),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        selected ? 'Selected' : 'Scene',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
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

  Widget _sceneFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1F1F), Color(0xFF4B4B4B)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.photo_library_rounded,
          color: Colors.white70,
          size: 38,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _SelectorTile({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.buttonPrimary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;

  const _SectionLabel(this.text, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}

class _ProcessingCard extends StatelessWidget {
  final StudioImageJob job;
  final bool isDark;

  const _ProcessingCard({required this.job, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDAA5E).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDAA5E).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFFFDAA5E)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.status == 'pending'
                          ? 'Queued for generation'
                          : 'Generating studio images...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'This may take a minute',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              backgroundColor: AppColors.divider.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFDAA5E)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioGridItem extends StatelessWidget {
  final StudioImageJob job;
  final bool isDark;
  final VoidCallback onTap;

  const _StudioGridItem({
    required this.job,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: job.outputs.isNotEmpty
                    ? KieImage(url: 
                        job.outputs.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark
                              ? AppColors.darkCardAlt
                              : AppColors.lightCardAlt,
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, size: 32),
                          ),
                        ),
                      )
                    : Container(
                        color: isDark
                            ? AppColors.darkCardAlt
                            : AppColors.lightCardAlt,
                        child: const Center(
                          child: Icon(Icons.image_rounded, size: 32),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00B894),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job.createdAt.toLocal().toString().split(' ')[0],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
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

class _FailedCard extends StatelessWidget {
  final StudioImageJob job;
  final bool isDark;

  const _FailedCard({required this.job, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generation Failed',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  job.error ?? 'An unknown error occurred.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioJobResultScreen extends StatefulWidget {
  final StudioImageJob job;
  final String productId;
  final VoidCallback onImageSelected;

  const _StudioJobResultScreen({
    required this.job,
    required this.productId,
    required this.onImageSelected,
  });

  @override
  State<_StudioJobResultScreen> createState() => _StudioJobResultScreenState();
}

class _StudioJobResultScreenState extends State<_StudioJobResultScreen> {
  bool _isSelecting = false;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    if (widget.job.outputs.isEmpty) return;

    setState(() => _isSelecting = true);
    try {
      final originalUrl = widget.job.outputs[_currentIndex];
      String finalUrl = originalUrl;

      // KIE AI generates temporary URLs that expire in ~20 minutes.
      // We must: 1) get a permanent download URL, 2) download the file,
      // 3) upload to Cloudinary, 4) use the Cloudinary URL as the permanent link.
      final isKieAiUrl = originalUrl.contains('api.kie.ai') ||
          originalUrl.contains('tempfile.') ||
          originalUrl.contains('kie.ai');

      if (isKieAiUrl) {
        AppNotification.info(
          context,
          message: 'Uploading to cloud storage...',
        );

        // Step 1: Get a short-lived secure download URL from KIE
        final secureUrl = await kieService.getDownloadUrl(originalUrl);

        // Step 2: Download the image to a local temp file
        final downloadedFile = await kieService.downloadImageToFile(secureUrl);

        // Step 3: Upload to Cloudinary for a permanent URL
        final cloudinaryUrl = await cloudinaryService.uploadImage(
          downloadedFile,
          folder: 'studio_images',
        );

        if (cloudinaryUrl == null || cloudinaryUrl.isEmpty) {
          throw Exception('Cloud upload returned an empty URL.');
        }

        finalUrl = cloudinaryUrl;

        // Clean up temp file
        try { await downloadedFile.delete(); } catch (_) {}
      }

      // Step 4: POST the permanent URL to the backend to associate it
      // with the product (saved to DDB via /api/studio/select)
      await studioService.selectStudioImage(
        SelectStudioImageRequest(
          productId: widget.productId,
          imageUrl: finalUrl,
        ),
      );

      if (!mounted) return;
      AppNotification.success(
        context,
        message: 'Image assigned to product successfully!',
      );
      widget.onImageSelected();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppNotification.error(
        context,
        message: 'Failed to assign image: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() => _isSelecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.job.outputs.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Studio Image',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: Text('No images found', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.job.outputs.length > 1
              ? 'Image ${_currentIndex + 1} of ${widget.job.outputs.length}'
              : 'Studio Image',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.job.outputs.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: KieImage(url: widget.job.outputs[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSelecting ? null : _selectImage,
        icon: _isSelecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(_isSelecting ? 'Setting...' : 'Set as Product Image'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
