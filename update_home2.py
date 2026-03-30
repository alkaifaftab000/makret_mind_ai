import re

with open("lib/screens/home/home_screen.dart", "r") as f:
    text = f.read()

# Make the padding 12 inside the sub-cards
old_text2 = '''            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column('''

new_text2 = '''            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column('''

text = text.replace(old_text2, new_text2)

with open("lib/screens/home/home_screen.dart", "w") as f:
    f.write(text)
