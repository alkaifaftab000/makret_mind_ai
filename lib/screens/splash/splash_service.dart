class SplashService {
  static const Duration splashDuration = Duration(seconds: 8);

  Future<void> holdSplash() async {
    await Future<void>.delayed(splashDuration);
  }
}
