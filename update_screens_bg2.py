import re

def add_gradient_bg(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    old_scaffold = '''    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,'''

    new_scaffold = '''    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A), 
                  const Color(0xFF064E3B).withValues(alpha: 0.2),
                ]
              : [
                  const Color(0xFFFDF2F8),
                  Colors.white,
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,'''

    content = content.replace(old_scaffold, new_scaffold)
    
    # search screen ends with 
    #       ),
    #     );
    #   }
    # }
    
    # replace the exact block to close the Container
    content = content.replace('''      ),
    );
  }
}''', '''      ),
      ),
    );
  }
}''')
    
    with open(filepath, "w") as f:
        f.write(content)

add_gradient_bg("lib/screens/search/search_screen.dart")
add_gradient_bg("lib/screens/templates/templates_screen.dart")
