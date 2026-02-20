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
