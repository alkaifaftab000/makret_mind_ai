import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:market_mind/constants/api_constants.dart';
import 'package:market_mind/services/auth_service.dart';

/// Service that fetches dynamic dropdown options from GET /api/app-data/options
/// Falls back to hardcoded defaults if the API call fails.
class AppOptionsService {
  static final AppOptionsService _instance = AppOptionsService._internal();
  factory AppOptionsService() => _instance;
  AppOptionsService._internal();

  final Logger _logger = Logger(printer: PrettyPrinter());
  Dio get _dio => authService.dioClient;

  bool _loaded = false;

  // ─── Audience options ──────────────────────────────────────────
  List<String> _audienceOptions = _defaultAudienceOptions;
  Map<String, String> _audienceLabels = _defaultAudienceLabels;

  List<String> get audienceOptions => _audienceOptions;
  Map<String, String> get audienceLabels => _audienceLabels;

  // ─── Category options ──────────────────────────────────────────
  List<String> _categoryOptions = _defaultCategoryOptions;
  Map<String, String> _categoryLabels = _defaultCategoryLabels;

  List<String> get categoryOptions => _categoryOptions;
  Map<String, String> get categoryLabels => _categoryLabels;

  bool get isLoaded => _loaded;

  /// Fetch options from backend. Safe to call multiple times.
  Future<void> fetchOptions() async {
    try {
      _logger.i('Fetching app options from backend...');
      final response = await _dio.get(ApiConstants.appOptions);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        _parseOptions(data);
        _loaded = true;
        _logger.i('App options loaded successfully');
      }
    } catch (e) {
      _logger.w('Failed to fetch app options, using defaults: $e');
      // Keep defaults — already set
    }
  }

  void _parseOptions(Map<String, dynamic> data) {
    // Parse target_audience options
    if (data.containsKey('target_audience')) {
      final raw = data['target_audience'];
      if (raw is List) {
        _audienceOptions = raw.map((e) => e.toString()).toList();
        _audienceLabels = {
          for (final opt in _audienceOptions) opt: _humanize(opt),
        };
      }
    }

    // Parse category options
    if (data.containsKey('category') || data.containsKey('categories')) {
      final raw = data['category'] ?? data['categories'];
      if (raw is List) {
        _categoryOptions = raw.map((e) => e.toString()).toList();
        _categoryLabels = {
          for (final opt in _categoryOptions) opt: _humanize(opt),
        };
      }
    }
  }

  /// Convert snake_case to Human Readable
  static String _humanize(String value) {
    return value
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ─── Defaults (fallback if API fails) ──────────────────────────
  static const List<String> _defaultAudienceOptions = [
    'kids', 'teens', 'gen_z', 'millennials', 'gen_x', 'boomers',
    'seniors', 'parents', 'students', 'professionals',
    'business_owners', 'homeowners', 'gamers', 'fitness_enthusiasts',
    'tech_enthusiasts', 'travelers', 'foodies', 'pet_owners',
    'luxury_shoppers', 'bargain_hunters', 'creatives', 'general',
  ];

  static const Map<String, String> _defaultAudienceLabels = {
    'kids': 'Kids', 'teens': 'Teens', 'gen_z': 'Gen Z',
    'millennials': 'Millennials', 'gen_x': 'Gen X', 'boomers': 'Boomers',
    'seniors': 'Seniors', 'parents': 'Parents', 'students': 'Students',
    'professionals': 'Professionals', 'business_owners': 'Business Owners',
    'homeowners': 'Homeowners', 'gamers': 'Gamers',
    'fitness_enthusiasts': 'Fitness Enthusiasts',
    'tech_enthusiasts': 'Tech Enthusiasts', 'travelers': 'Travelers',
    'foodies': 'Foodies', 'pet_owners': 'Pet Owners',
    'luxury_shoppers': 'Luxury Shoppers', 'bargain_hunters': 'Bargain Hunters',
    'creatives': 'Creatives', 'general': 'General',
  };

  static const List<String> _defaultCategoryOptions = [
    'beauty', 'electronics', 'fashion', 'jewelry_accessories',
    'home_garden', 'pet_supplies', 'toys_games', 'sports_outdoors',
    'food_beverage', 'health_wellness', 'travel_tourism', 'automotive',
    'finance', 'education', 'entertainment_media', 'software_tech',
    'real_estate', 'b2b_services', 'art_design', 'other',
  ];

  static const Map<String, String> _defaultCategoryLabels = {
    'beauty': 'Beauty', 'electronics': 'Electronics', 'fashion': 'Fashion',
    'jewelry_accessories': 'Jewelry & Accessories',
    'home_garden': 'Home & Garden', 'pet_supplies': 'Pet Supplies',
    'toys_games': 'Toys & Games', 'sports_outdoors': 'Sports & Outdoors',
    'food_beverage': 'Food & Beverage', 'health_wellness': 'Health & Wellness',
    'travel_tourism': 'Travel & Tourism', 'automotive': 'Automotive',
    'finance': 'Finance', 'education': 'Education',
    'entertainment_media': 'Entertainment & Media',
    'software_tech': 'Software & Tech', 'real_estate': 'Real Estate',
    'b2b_services': 'B2B Services', 'art_design': 'Art & Design',
    'other': 'Other',
  };
}

/// Singleton instance
final appOptionsService = AppOptionsService();
