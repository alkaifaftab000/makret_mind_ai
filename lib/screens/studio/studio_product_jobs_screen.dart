import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/models/product_model.dart';
import 'package:market_mind/models/studio_model.dart';
import 'package:market_mind/services/studio_service.dart';
import 'package:market_mind/utils/app_notification.dart';
import 'package:market_mind/screens/studio/studio_detail_screen.dart';

class StudioProductJobsScreen extends StatefulWidget {
  final ProductModel product;

  const StudioProductJobsScreen({
    super.key,
    required this.product,
  });

  @override
  State<StudioProductJobsScreen> createState() => _StudioProductJobsScreenState();
}

class _StudioProductJobsScreenState extends State<StudioProductJobsScreen> {
  bool _isLoading = true;
  List<StudioJob> _jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    final jobs = await studioService.getProductStudioJobs(widget.product.id);
    if (!mounted) return;
    setState(() {
      _jobs = jobs;
      _isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF00B894);
      case 'failed':
        return Colors.redAccent;
      case 'processing':
        return const Color(0xFFFDAA5E);
      default:
        return Colors.grey;
    }
  }

  Future<void> _openJobDetails(StudioJob job) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final details = await studioService.getStudioJob(job.id);
    if (!mounted) return;
    if (details == null) {
      AppNotification.error(context, message: 'Unable to load job details');
      return;
    }

    final firstShot = details.shots.isNotEmpty ? details.shots.firstWhere(
        (s) => s.outputs.isNotEmpty,
        orElse: () => details.shots.first
    ) : null;

    if (firstShot == null) {
      AppNotification.warning(context, message: 'No shots found for this job');
      return;
    }

    final mappedJob = StudioImageJob(
      id: firstShot.id,
      jobId: details.id,
      status: firstShot.status,
      outputs: firstShot.outputs,
      createdAt: details.createdAt ?? DateTime.now(),
      error: firstShot.error,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudioDetailScreen(
          job: mappedJob,
          productName: widget.product.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: Text(
          'Studio Jobs',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadJobs,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? Center(
                  child: Text(
                    'No AI Studio jobs for this product yet',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  itemCount: _jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final job = _jobs[index];
                    final color = _statusColor(job.status);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _openJobDetails(job),
                        child: Ink(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Job ${job.id.substring(0, job.id.length > 8 ? 8 : job.id.length)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${job.shots.length} shots • ${job.totalRequestedImages} requested images',
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
                              Text(
                                job.status,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
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


