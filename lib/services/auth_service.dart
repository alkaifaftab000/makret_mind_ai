import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:market_mind/constants/api_constants.dart';
import 'package:market_mind/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    // Interceptor to attach token automatically for future authorized requests
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  late final Dio _dio;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger(printer: PrettyPrinter());

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Update the local user model state (e.g. after a profile edit)
  void updateLocalUser(UserModel updatedUser) {
    _currentUser = updatedUser;
  }

  /// Authenticate with Google
  /// Throws an exception if an error occurs so the UI can display it
  Future<UserModel?> loginWithGoogle() async {
    try {
      _logger.i('Starting Google Sign-In flow');
      
      if (!_isGoogleInitialized) {
        await _googleSignIn.initialize(
          serverClientId: '774223488327-lrue3e5dcujabfcp77v23gbglfbnq16h.apps.googleusercontent.com',
        );
        _isGoogleInitialized = true;
      }
      
      // Prompt user to pick Google account
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) {
        _logger.i('Google Sign-In canceled by user');
        return null; // User canceled the sign-in flow
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _logger.e('Failed to retrieve id_token from Google Sign-In');
        throw Exception('Authentication failed: missing Google ID token.');
      }

      _logger.i('Successfully retrieved id_token, attempting to authenticate with backend...');

      // Send id_token to backend
      final response = await _dio.post(
        ApiConstants.googleAuth,
        data: {
          'id_token': idToken,
        },
      );

      return _handleAuthResponse(response);
    } catch (e) {
      _logger.e('Exception during Google Sign-In: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow; // Rethrow to let the UI react to the specific error
    }
  }

  /// Optional endpoint to explicitly register (if Google fails)
  Future<UserModel?> registerWithEmail({
    required String email,
    required String name,
    required String googleId,
    String? avatar,
  }) async {
    try {
      _logger.i('Attempting alternative explicit registration for $email');
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'name': name,
          'google_id': googleId,
          'avatar': avatar,
        },
      );

      return _handleAuthResponse(response);
    } catch (e) {
      _logger.e('Exception during explicit registration: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  /// Developer Login to bypass Google OAuth during development
  Future<UserModel?> devLogin({
    String email = 'test@example.com',
    String name = 'Test User',
  }) async {
    try {
      _logger.i('Attempting Developer Login for $email');
      final response = await _dio.post(
        ApiConstants.devLogin,
        data: {
          'email': email,
          'name': name,
        },
      );

      return _handleAuthResponse(response);
    } catch (e) {
      _logger.e('Exception during Developer Login: $e');
      if (e is DioException) {
        _handleDioError(e);
      }
      rethrow;
    }
  }

  Future<UserModel> _handleAuthResponse(Response response) async {
    if (response.statusCode == 200) {
      final data = response.data;
      final String token = data['access_token'];
      final userJson = data['user'];

      if (token.isEmpty || userJson == null) {
        _logger.e('Invalid auth response format: missing token or user object');
        throw Exception('Invalid response from server.');
      }

      // Store token locally
      await _secureStorage.write(key: 'access_token', value: token);
      
      // Update local user state
      _currentUser = UserModel.fromJson(userJson);
      
      _logger.i('Backend authentication successful for ${_currentUser?.email}');
      return _currentUser!;
    } else {
      _logger.e('Unexpected status code from auth response: ${response.statusCode}');
      throw Exception('Authentication failed. Server returned status: ${response.statusCode}');
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      _logger.e('Server error ($statusCode): $responseData');
      
      if (statusCode == 422) {
        throw Exception('Validation error: Please check your data.');
      } else if (statusCode == 401 || statusCode == 403) {
        throw Exception('Unauthorized access. Please try again.');
      } else if (statusCode! >= 500) {
        throw Exception('Internal Server Error. Please try again later.');
      }
    } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      _logger.e('Connection timeout error during API call.');
      throw Exception('Connection timed out. Please check your internet connection and try again.');
    } else if (e.type == DioExceptionType.connectionError) {
       _logger.e('Connection error during API call.');
      throw Exception('Unable to connect to the server. Please verify your connection.');
    } else {
      _logger.e('Network or unknown error during API call: ${e.message}');
      throw Exception('Network error occurred. Please try again.');
    }
  }

  Future<void> logOut() async {
    _logger.i('Logging out user...');
    await _secureStorage.delete(key: 'access_token');
    await _googleSignIn.signOut();
    _currentUser = null;
    _logger.i('User successfully logged out.');
  }

  // Gives access to underlying dio instance for other services
  Dio get dioClient => _dio;
}

final authService = AuthService();
