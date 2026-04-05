import 'package:dio/dio.dart';
void main() async {
  final dio = Dio();
  try {
    Map<String, dynamic> loginData = {
      "email": "test@example.com",
      "password": "password"
    }; // Well, I don't know test credentials.
  } catch (e) {
  }
}
