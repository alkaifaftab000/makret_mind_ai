import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('api_res.json');
  final string = await file.readAsString();
  final list = json.decode(string) as List<dynamic>;
  
  for (var item in list) {
    try {
      final videosRaw = item['videos'] as List<dynamic>? ?? [];
      final firstVideo = videosRaw.isNotEmpty ? videosRaw.first as Map<String, dynamic>? : null;
      final parsedFinalVideoUrl = firstVideo?['finalVideoUrl']?.toString() ?? item['finalVideoUrl']?.toString();
      final rawScenes = firstVideo?['scenes'] as List<dynamic>? ?? item['scenes'] as List<dynamic>?;
      final hasVideos = videosRaw.isNotEmpty || parsedFinalVideoUrl != null || (rawScenes?.isNotEmpty ?? false);
      
      print('Product: \${item["name"]} - hasVideos: \$hasVideos, type: \${hasVideos ? "video" : "poster"}');
    } catch (e, stack) {
      print('Error parsing \${item["name"]}: \$e');
    }
  }
}
