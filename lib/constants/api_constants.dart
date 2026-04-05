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

  // Product endpoints
  static const String products = '/api/products';
  static const String productsWithImages = '/api/products/with-images';

  // AI Studio endpoints
  static const String studioJobs = '/api/studio/jobs';
  static const String studioSelect = '/api/studio/select';
  static const String studioModels = '/api/studio/models';
  static const String studioScenes = '/api/studio/scenes';

  // App Data endpoints
  static const String appData = '/api/app-data';
  static const String appOptions = '/api/app-data/options';
}
