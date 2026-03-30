import "../../screens/poster_generator/poster_components.dart";
import 'package:flutter/material.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';

import 'video_generation_screen.dart';

class VideoCustomizationScreen extends StatefulWidget {
  VideoCustomizationScreen({Key? key}) : super(key: key);

  @override
  _VideoCustomizationScreenState createState() =>
      _VideoCustomizationScreenState();
}

class _VideoCustomizationScreenState extends State<VideoCustomizationScreen> {
  String _musicChoice = 'Upbeat';
  bool _includeVoiceover = true;
  String _templateStyle = 'Modern';
  double _videoLength = 30;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Customize Video',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Product/Content Selection
            PosterComponents.sectionContainer(
              title: 'Product Content',
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://picsum.photos/seed/product123/80/80',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Headphones',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Section 2: Music Selection
            PosterComponents.sectionContainer(
              title: 'Background Music',
              child: DropdownButtonFormField<String>(
                dropdownColor: Color(0xFF222222),
                value: _musicChoice,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Upbeat', 'Calm', 'Energetic', 'Cinematic'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) setState(() => _musicChoice = newValue);
                },
              ),
            ),

            // Section 3: Voiceover Toggle
            PosterComponents.sectionContainer(
              title: 'Include Voiceover',
              child: PosterComponents.toggleSelector(
                label1: 'Yes',
                label2: 'No',
                isFirstSelected: _includeVoiceover,
                onChanged: (val) {
                  setState(() => _includeVoiceover = val);
                },
              ),
            ),

            // Section 4: Template Style
            PosterComponents.sectionContainer(
              title: 'Visual Style',
              child: DropdownButtonFormField<String>(
                dropdownColor: Color(0xFF222222),
                value: _templateStyle,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Modern', 'Classic', 'Minimal', 'Bold'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null)
                    setState(() => _templateStyle = newValue);
                },
              ),
            ),

            // Section 5: Video Length
            PosterComponents.sectionContainer(
              title: 'Video Length (${_videoLength.toInt()}s)',
              child: Slider(
                value: _videoLength,
                min: 15,
                max: 60,
                divisions: 3,
                activeColor: Colors.deepPurpleAccent,
                inactiveColor: Colors.white24,
                label: '${_videoLength.toInt()}s',
                onChanged: (val) {
                  setState(() => _videoLength = val);
                },
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 32,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      VideoGenerationScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  transitionDuration: Duration(milliseconds: 400),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Generate Video',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
