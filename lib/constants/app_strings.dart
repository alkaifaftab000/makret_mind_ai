class AppStrings {
  static const String appName = 'Market Mind AI✨';
  static const String splashTagline = 'From prompts to market ads, instantly.';
  static const String footer = '@2026 Market Mind · v0.1';

  static const String splashWordUpload = 'Upload';
  static const String splashWordPrompt = 'Prompt';
  static const String splashWordGenerate = 'Generate';

  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingDone = 'Done';

  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Login to continue creating AI videos.';
  static const String registerTitle = 'Create Your Account';
  static const String registerSubtitle =
      'Start generating stories with Market Mind AI.';

  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String emailHint = 'you@example.com';
  static const String passwordHint = '••••••••';

  static const String signIn = 'Login';
  static const String register = 'Register';
  static const String orContinue = 'or continue with';
  static const String noAccount = 'No account yet? ';
  static const String alreadyHaveAccount = 'Already have an account? ';

  static const String homeTitle = 'Home';
  static const String searchTitle = 'Search';
  static const String templatesTitle = 'Templates';
  static const String profileTitle = 'Profile';

  static const String searchBrandsHint = 'Search brands...';
  static const String searchAllHint = 'Search brands, products, posters...';
  static const String searchVideosHint = 'Search videos...';
  static const String searchPostersHint = 'Search posters...';
  static const String searchStudioHint = 'Search AI Studio jobs...';
  static const String searchTemplatesHint = 'Search templates...';
  static const String searchToGetResults = 'Search to get results';
  static const String noResultsFound = 'No results found';
  static const String noTemplatesFound = 'No templates found';

  static const String noBrandsYet = 'No Brands Yet';
  static const String noBrandsSubtitle =
      'Create your first brand to get started';
  static const String noProductsYet = 'No Products Yet';
  static const String noProductsSubtitle =
      'Create your first product for this brand';

  // Home tab labels
  static const String tabVideo = 'Video';
  static const String tabPoster = 'Poster';
  static const String tabAIStudio = 'AI Studio';
  static const String tabBrand = 'Brand';

  // Home tab FAB labels
  static const String generateVideo = 'Generate Video';
  static const String generatePoster = 'Generate Poster';
  static const String goToAIStudio = 'AI Studio';

  // Home tab empty states
  static const String noVideosYet = 'No Videos Yet';
  static const String noVideosSubtitle = 'Generate your first AI video';
  static const String noPostersYet = 'No Posters Yet';
  static const String noPostersSubtitle = 'Create stunning AI posters';
  static const String noStudioJobsYet = 'No Studio Jobs Yet';
  static const String noStudioJobsSubtitle = 'Start creating with AI Studio';
  static const String brandRequiredTitle = 'Brand Required';
  static const String brandRequiredMessage = 'Create at least one brand before generating content';

  // Brand creation multi-select options (exact backend enum values)
  static const List<String> audienceOptions = [
    'kids',
    'teens',
    'gen_z',
    'millennials',
    'gen_x',
    'boomers',
    'seniors',
    'parents',
    'students',
    'professionals',
    'business_owners',
    'homeowners',
    'gamers',
    'fitness_enthusiasts',
    'tech_enthusiasts',
    'travelers',
    'foodies',
    'pet_owners',
    'luxury_shoppers',
    'bargain_hunters',
    'creatives',
    'general',
  ];

  // Human-readable labels for audience chips
  static const Map<String, String> audienceLabels = {
    'kids': 'Kids',
    'teens': 'Teens',
    'gen_z': 'Gen Z',
    'millennials': 'Millennials',
    'gen_x': 'Gen X',
    'boomers': 'Boomers',
    'seniors': 'Seniors',
    'parents': 'Parents',
    'students': 'Students',
    'professionals': 'Professionals',
    'business_owners': 'Business Owners',
    'homeowners': 'Homeowners',
    'gamers': 'Gamers',
    'fitness_enthusiasts': 'Fitness Enthusiasts',
    'tech_enthusiasts': 'Tech Enthusiasts',
    'travelers': 'Travelers',
    'foodies': 'Foodies',
    'pet_owners': 'Pet Owners',
    'luxury_shoppers': 'Luxury Shoppers',
    'bargain_hunters': 'Bargain Hunters',
    'creatives': 'Creatives',
    'general': 'General',
  };

  static const List<String> categoryOptions = [
    'beauty',
    'electronics',
    'fashion',
    'jewelry_accessories',
    'home_garden',
    'pet_supplies',
    'toys_games',
    'sports_outdoors',
    'food_beverage',
    'health_wellness',
    'travel_tourism',
    'automotive',
    'finance',
    'education',
    'entertainment_media',
    'software_tech',
    'real_estate',
    'b2b_services',
    'art_design',
    'other',
  ];

  // Human-readable labels for category chips
  static const Map<String, String> categoryLabels = {
    'beauty': 'Beauty',
    'electronics': 'Electronics',
    'fashion': 'Fashion',
    'jewelry_accessories': 'Jewelry & Accessories',
    'home_garden': 'Home & Garden',
    'pet_supplies': 'Pet Supplies',
    'toys_games': 'Toys & Games',
    'sports_outdoors': 'Sports & Outdoors',
    'food_beverage': 'Food & Beverage',
    'health_wellness': 'Health & Wellness',
    'travel_tourism': 'Travel & Tourism',
    'automotive': 'Automotive',
    'finance': 'Finance',
    'education': 'Education',
    'entertainment_media': 'Entertainment & Media',
    'software_tech': 'Software & Tech',
    'real_estate': 'Real Estate',
    'b2b_services': 'B2B Services',
    'art_design': 'Art & Design',
    'other': 'Other',
  };

  static const String createBrand = 'Create Brand';
  static const String createProduct = 'Create Product';
  static const String accountDetails = 'Account Details';
  static const String settings = 'Settings';
  static const String about = 'About';
  static const String logout = 'Logout';
  static const String marketMindUser = 'MarketMind User';
  static const String contentCreator = 'Content Creator';
  static const String videos = 'Videos';
  static const String products = 'Products';
  static const String posters = 'Posters';
  static const String display = 'Display';
  static const String notifications = 'Notifications';
  static const String dataPrivacy = 'Data & Privacy';
  static const String darkMode = 'Dark Mode';
  static const String darkModeSubtitle = 'Enable dark theme';
  static const String pushNotifications = 'Push Notifications';
  static const String pushNotificationsSubtitle = 'Receive alerts';
  static const String emailNotifications = 'Email Notifications';
  static const String emailNotificationsSubtitle = 'Get email updates';
  static const String soundEffects = 'Sound Effects';
  static const String soundEffectsSubtitle = 'Play notification sounds';
  static const String exportData = 'Export Data';
  static const String clearCache = 'Clear Cache';
  static const String clearCacheTitle = 'Clear Cache?';
  static const String clearCacheMessage =
      'This will remove cached data. Confirm?';

  static const String aboutMarketMind = 'About MarketMind';
  static const String appVersion = 'v1.0.0';
  static const String keyFeatures = 'Key Features';
  static const String technologyStack = 'Technology Stack';
  static const String viewOnGithub = 'View on GitHub';
  static const String githubHandle = 'github.com/alkaifaftab000';
  static const String copyright = '© 2026 MarketMind. All rights reserved.';

  static const String confirmLogout = 'Confirm Logout';
  static const String logoutMessage =
      'Are you sure you want to logout? You can always log back in later.';
  static const String logoutNow = 'Logout Now';

  static const String deleteBrand = 'Delete Brand';
  static const String editBrand = 'Edit Brand';
  static const String share = 'Share';
  static const String description = 'Description';
  static const String details = 'Details';
  static const String category = 'Category';
  static const String targetAudience = 'Target Audience';
  static const String productions = 'Productions';
  static const String created = 'Created';
  static const String updated = 'Updated';
  static const String edit = 'Edit';
  static const String notSet = 'Not set';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  static const String generatedShortClipsTitle = 'Generated Short Clips';
  static const String finalVideoTitle = 'Final Video';
  static const String reviewClipsHint =
      'Review, reorder and regenerate clips before final merge';
  static const String uploadShortClip = 'Upload Clip';
  static const String makeFinalVideo = 'Make Final Video';
  static const String maxShortClipsReached =
      'Already 5 clips (maximum allowed)';
  static const String shortClipUploaded = 'Short clip uploaded';

  static const List<OnboardingContent> onboardingItems = [
    OnboardingContent(
      imagePath: 'assets/onboarding/1.png',
      title: 'Turn Ideas Into Cinematic Clips',
      description:
          'Upload visuals, add your prompt, and start creating in seconds.',
    ),
    OnboardingContent(
      imagePath: 'assets/onboarding/2.png',
      title: 'Guide Every Scene Clearly',
      description:
          'Describe style, mood, and movement to shape the output video.',
    ),
    OnboardingContent(
      imagePath: 'assets/onboarding/3.png',
      title: 'Pick The Right AI Model',
      description:
          'Select the model that best fits your concept and quality target.',
    ),
    OnboardingContent(
      imagePath: 'assets/onboarding/4.png',
      title: 'Generate Faster, Iterate Better',
      description:
          'Submit once, preview quickly, and refine prompts with confidence.',
    ),
    OnboardingContent(
      imagePath: 'assets/onboarding/5.png',
      title: 'Create Production-Ready Videos',
      description:
          'Go from rough concept to polished visual story with Market Mind AI.',
    ),
  ];
}

class OnboardingContent {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingContent({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}
