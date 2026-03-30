import 'package:flutter/material.dart';
import 'poster_components.dart';
import 'poster_generation_screen.dart';

class PosterCustomizationScreen extends StatefulWidget {
  const PosterCustomizationScreen({Key? key}) : super(key: key);

  @override
  _PosterCustomizationScreenState createState() => _PosterCustomizationScreenState();
}

class _PosterCustomizationScreenState extends State<PosterCustomizationScreen> {
  bool _withModel = true;
  double _outputCount = 1;
  String _colorTheme = 'Dark & Mood';
  String _layoutStyle = 'Minimalist';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Customize Poster', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Product Selection
            PosterComponents.sectionContainer(
              title: 'Product Selection',
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://picsum.photos/seed/shoes/80/80',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sneakers Pro X',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Change Product'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Section 2: Text Input
            PosterComponents.sectionContainer(
              title: 'Text Content',
              child: Column(
                children: [
                  PosterComponents.inputField(hintText: 'Headline (e.g. Summer Sale 50% Off)'),
                  const SizedBox(height: 12),
                  PosterComponents.inputField(hintText: 'Subtext or Call to Action'),
                ],
              ),
            ),

            // Section 3: Model Selection
            PosterComponents.sectionContainer(
              title: 'Include AI Model',
              child: PosterComponents.toggleSelector(
                label1: 'With Model',
                label2: 'No Model',
                isFirstSelected: _withModel,
                onChanged: (val) {
                  setState(() => _withModel = val);
                },
              ),
            ),

            // Section 4: Style Settings
            PosterComponents.sectionContainer(
              title: 'Style Adjustments',
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF222222),
                    value: _colorTheme,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ['Dark & Mood', 'Bright & Pop', 'Earthy Tones', 'Monochrome'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) setState(() => _colorTheme = newValue);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF222222),
                    value: _layoutStyle,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: ['Minimalist', 'Magazine Cover', 'Grid', 'Abstract'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) setState(() => _layoutStyle = newValue);
                    },
                  ),
                ],
              ),
            ),

            // Section 5: Output Count
            PosterComponents.sectionContainer(
              title: 'Output Variations (${_outputCount.toInt()})',
              child: Slider(
                value: _outputCount,
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: Colors.deepPurpleAccent,
                inactiveColor: Colors.white24,
                label: _outputCount.toInt().toString(),
                onChanged: (val) {
                  setState(() => _outputCount = val);
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        color: const Color(0xFF121212),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const PosterGenerationScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Generate Poster', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
