import re

def fix_bracket(filepath):
    with open(filepath, "r") as f:
        content = f.read()

    # The end of the file is likely:
    #       ),
    #     );
    #   }
    # }
    
    # We want to change the last `    );` before `  }` to `      ), \n    );`
    
    # Split into lines
    lines = content.split('\n')
    
    for i in range(len(lines)-1, -1, -1):
        if lines[i].strip() == ');':
            lines[i] = '      ),\n    );'
            break
            
    with open(filepath, "w") as f:
        f.write('\n'.join(lines))

fix_bracket('lib/screens/search/search_screen.dart')
fix_bracket('lib/screens/templates/templates_screen.dart')
