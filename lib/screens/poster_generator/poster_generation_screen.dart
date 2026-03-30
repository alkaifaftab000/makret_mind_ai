import 'dart:async';
import 'package:flutter/material.dart';

// Dummy output screen to satisfy the flow
class SceneResultScreen extends StatelessWidget {
  const SceneResultScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text('Result', style: TextStyle(color: Colors.white)), backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Generated Successfully!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('Done'),
            )
          ],
        ),
      ),
    );
  }
}

class PosterGenerationScreen extends StatefulWidget {
  const PosterGenerationScreen({Key? key}) : super(key: key);

  @override
  _PosterGenerationScreenState createState() => _PosterGenerationScreenState();
}

class _PosterGenerationScreenState extends State<PosterGenerationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _statusIndex = 0;
  final List<String> _statuses = [
    "Analyzing inputs...",
    "Generating base image...",
    "Applying styles...",
    "Adding typography...",
    "Finalizing details..."
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _simulateGeneration();
  }

  void _simulateGeneration() async {
    for (int i = 0; i < _statuses.length; i++) {
      if (!mounted) return;
      setState(() => _statusIndex = i);
      await Future.delayed(const Duration(milliseconds: 1200));
    }
    
    if (!mounted) return;
    
    // Auto navigate to the result screen
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SceneResultScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                    strokeWidth: 6,
                    backgroundColor: Colors.white.withOpacity(0.05),
                  ),
                ),
                RotationTransition(
                  turns: _controller,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purple.withOpacity(0.5)],
                      ),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _statuses[_statusIndex],
                key: ValueKey<int>(_statusIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "This might take a few moments",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
