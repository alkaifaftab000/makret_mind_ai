import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  dio.options.headers['Authorization'] = 'Bearer 46c3b599074c1c6a376b2c0a64731035';
  
  try {
    final res = await dio.get('https://marketmind.kiebot.com/api/products');
    print("Response status: ${res.statusCode}");
    
    if (res.data is List) {
       for (var item in res.data) {
          final sImgs = item['studioImages'] ?? item['studio_images'];
          if (sImgs != null && (sImgs as List).isNotEmpty) {
             print("Found product ${item['id']} with ${sImgs.length} studio images!");
             print(jsonEncode(sImgs.first));
          }
       }
    }
  } catch (e, stack) {
    if (e is DioException) {
      print("DioError: ${e.response?.data}");
    }
    print("Error: $e");
  }
}
