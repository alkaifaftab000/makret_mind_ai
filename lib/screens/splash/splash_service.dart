class SplashService {
  static const Duration splashDuration = Duration(seconds: 15);

  Future<void> holdSplash() async {
    await Future<void>.delayed(splashDuration);
  }
}
