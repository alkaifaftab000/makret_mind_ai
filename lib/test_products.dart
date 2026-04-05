import 'package:dio/dio.dart';
void main() async {
  final dio = Dio();
  try {
    final res = await dio.get('https://adstudiobackend.onrender.com/api/products');
    print(res.data);
  } catch (e) {
    print(e);
  }
}
