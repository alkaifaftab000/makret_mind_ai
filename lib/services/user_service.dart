import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:market_mind/constants/api_constants.dart';
import 'package:market_mind/models/user_model.dart';
import 'package:market_mind/services/auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  final Logger _logger = Logger(printer: PrettyPrinter());

  // Use the Dio instance from AuthService because it already handles injecting the token
  Dio get _dio => authService.dioClient;

  /// Get Current User Info (GET /api/users/me)
  Future<UserModel> getCurrentUser() async {
    try {
      _logger.i('Fetching current user profile data...');
      final response = await _dio.get(ApiConstants.currentUser);
      
      if (response.statusCode == 200) {
        final userData = UserModel.fromJson(response.data);
        return userData;
      } else {
        throw Exception('Failed to load user profile. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching current user profile: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Update Current User (PUT /api/users/me)
  Future<UserModel> updateCurrentUser({
    String? name,
    String? avatar,
  }) async {
    try {
      _logger.i('Updating current user profile data...');
      final Map<String, dynamic> data = {};
      
      if (name != null) data['name'] = name;
      if (avatar != null) data['avatar'] = avatar;

      final response = await _dio.put(
        ApiConstants.currentUser,
        data: data,
      );

      if (response.statusCode == 200) {
        final userData = UserModel.fromJson(response.data);
        authService.updateLocalUser(userData);
        _logger.i('User profile updated successfully.');
        return userData;
      } else {
        throw Exception('Failed to update user profile. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error updating current user profile: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Delete Current User (DELETE /api/users/me)
  Future<String> deleteCurrentUser() async {
    try {
      _logger.w('Attempting to delete current user account permanently.');
      final response = await _dio.delete(ApiConstants.currentUser);

      if (response.statusCode == 200) {
        _logger.i('User account deleted successfully.');
        // The API returns a string message according to the documentation
        return response.data is String ? response.data : 'User account deleted successfully';
      } else {
        throw Exception('Failed to delete account. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error deleting account: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Get General User by ID (GET /api/users/{user_id})
  Future<UserModel> getUserById(String userId) async {
    try {
      _logger.i('Fetching user profile for ID: $userId');
      final response = await _dio.get('${ApiConstants.users}/$userId');
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load user profile. Server returned ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching user profile by ID: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      if (statusCode == 422) {
        throw Exception('Validation error: Please check your input data.');
      } else if (statusCode == 401 || statusCode == 403) {
        throw Exception('Unauthorized. Your session may have expired.');
      } else if (statusCode == 404) {
        throw Exception('User not found.');
      } else if (statusCode! >= 500) {
        throw Exception('Internal server error. Please try again later.');
      } else {
        throw Exception('Server error: $responseData');
      }
    } else {
      throw Exception('Network error: Unable to connect to the server.');
    }
  }
}

// Global instance of the service
final userService = UserService();
