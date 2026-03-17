class ApiConstants {
  // Production server URL provided by backend
  static const String baseUrl = 'https://adstudiobackend.onrender.com';

  // Auth endpoints
  static const String googleAuth = '/api/auth/google';
  static const String register = '/api/auth/register';
  static const String devLogin = '/api/auth/dev-login';

  // User endpoints
  static const String currentUser = '/api/users/me';
  static const String users = '/api/users'; // e.g., /api/users/{id}

  // Brand endpoints
  static const String brands = '/api/brands';
  static const String brandWithLogo = '/api/brands/with-logo';
}
