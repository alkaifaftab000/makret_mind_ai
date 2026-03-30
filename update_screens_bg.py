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
    
    # Check if we need to close the Container at the end of build method
    # It might be tricky to find the end. For search_screen:
    
    content = re.sub(r'(\s+)body: SafeArea', r'\1body: SafeArea', content)
    
    # append closing paren to the last brace of the build method
    # Actually just replace the last `);` of the build method with `), );` 
    # Or find the exact end block. Let's do it manually for each.
    
    with open(filepath, "w") as f:
        f.write(content)

add_gradient_bg("lib/screens/search/search_screen.dart")
add_gradient_bg("lib/screens/templates/templates_screen.dart")

