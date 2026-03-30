import re
import os

files = [
    'lib/screens/video_generator/video_main_screen.dart',
    'lib/screens/video_generator/video_template_preview_screen.dart',
    'lib/screens/video_generator/video_customization_screen.dart',
    'lib/screens/video_generator/video_generation_screen.dart'
]

COMMON_IMPORTS = """import 'package:flutter/material.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
"""

def process_file(filename):
    with open(filename, 'r') as f:
        content = f.read()

    # Generic string replacements
    content = content.replace("import 'package:flutter/material.dart';", COMMON_IMPORTS)
    content = content.replace("import 'package:market_mind/screens/poster_generator/poster_components.dart';", "")
    
    if 'Widget build(BuildContext context) {' in content:
        content = content.replace('Widget build(BuildContext context) {', 'Widget build(BuildContext context) {\n    final isDark = Theme.of(context).brightness == Brightness.dark;')

    # Replace PosterComponents.gradientBackground wrapper
    content = re.sub(r'PosterComponents\.gradientBackground\(\s*child:\s*Scaffold\(', r'Scaffold(', content)
    
    # Replace transparent background with theme background
    content = re.sub(r'backgroundColor: Colors\.transparent,', r'backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,', content)

    # Some texts might be using Colors.white or Colors.black, which we want to tie to isDark.
    # We will do some targeted replacements
    content = re.sub(r'TextStyle\(.*?\bcolor:\s*Colors\.white[^),]*', lambda m: m.group(0).replace('color: Colors.white', 'color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight'), content)
    content = re.sub(r'TextStyle\(.*?\bcolor:\s*Colors\.white70[^),]*', lambda m: m.group(0).replace('color: Colors.white70', 'color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight'), content)
    content = content.replace('Colors.black.withOpacity(0.3)', 'Colors.black.withValues(alpha: 0.3)')
    content = content.replace('Colors.white.withOpacity(0.15)', 'isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05)')
    content = content.replace('Colors.black.withOpacity(0.8)', 'Colors.black.withValues(alpha: 0.8)')
    content = content.replace('color: Colors.white', 'color: isDark ? Colors.white : Colors.black87')
    content = content.replace('color: isActive ? Colors.white : const Color(0xFF6B1510)', 'color: isActive ? (isDark ? Colors.white : Colors.black) : AppColors.darkCard')
    content = content.replace('color: isActive ? Colors.black : Colors.white', 'color: isActive ? (isDark ? Colors.black : Colors.white) : AppColors.textPrimaryDark')
    content = content.replace('color: const Color(0xFF6B1510)', 'color: isDark ? AppColors.darkCard : Colors.white')

    # Remove the trailing parenthesis logic that occurs because we removed `PosterComponents.gradientBackground(child: ...)`
    # Since we replaced `PosterComponents.gradientBackground(child: Scaffold(` with `Scaffold(`, there's an extra `)` at the very end of the build method.
    # Usually it looks like:
    #       ),
    #     );
    #   }
    # }
    content = re.sub(r'\);\n\s*\}\n\}', r'\n  }\n}', content)
    content = re.sub(r'\),\n\s*\}\n\}', r'\n  }\n}', content) # sometimes without semicolon

    with open(filename, 'w') as f:
        f.write(content)

for f in files:
    process_file(f)
