import 'package:flutter/material.dart';
import 'package:market_mind/services/kie_service.dart';

class KieImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const KieImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  State<KieImage> createState() => _KieImageState();
}

class _KieImageState extends State<KieImage> {
  late Future<String> _downloadUrlFuture;

  @override
  void initState() {
    super.initState();
    _downloadUrlFuture = _resolveKieUrl(widget.url);
  }

  @override
  void didUpdateWidget(KieImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _downloadUrlFuture = _resolveKieUrl(widget.url);
    }
  }

  Future<String> _resolveKieUrl(String originalUrl) async {
    if (originalUrl.contains('api.kie.ai') || originalUrl.contains('tempfile.')) {
      return await kieService.getDownloadUrl(originalUrl);
    }
    return originalUrl;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _downloadUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(
              context,
              snapshot.error ?? Exception('Failed to resolve URL'),
              null,
            );
          }
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey.withValues(alpha: 0.2),
            child: const Center(child: Icon(Icons.broken_image_rounded)),
          );
        }

        return Image.network(
          snapshot.data!,
          fit: widget.fit,
          width: widget.width,
          height: widget.height,
          errorBuilder: widget.errorBuilder,
        );
      },
    );
  }
}
