import re
import os

files = [
    'lib/screens/video_generator/video_main_screen.dart',
    'lib/screens/video_generator/video_template_preview_screen.dart',
    'lib/screens/video_generator/video_customization_screen.dart',
    'lib/screens/video_generator/video_generation_screen.dart'
]

for filename in files:
    with open(filename, 'r') as f:
        content = f.read()

    # The issue is near the end:
    #         ),
    #       
    #   }
    # }
    
    # We'll just replace the last occurrence of `),` or `)` before the `}` with `);`
    content = re.sub(r'\),\s*\n\s*\}\n\}', r');\n  }\n}', content)
    content = re.sub(r'\)\n\s*\}\n\}', r');\n  }\n}', content)
    # Also handle the exact tail seen:
    content = re.sub(r'\),\n\s*\n\s*\}\n\}', r');\n  }\n}', content)

    with open(filename, 'w') as f:
        f.write(content)

