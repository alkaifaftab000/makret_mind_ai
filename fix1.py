with open("lib/screens/search/search_screen.dart", "r") as f:
    text = f.read()

# We need to replace the specific closing of `build` of `_SearchScreenState`
old_closing = '''                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {'''

new_closing = '''                    ],
                  ],
                ),
              ),
      ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {'''

text = text.replace(old_closing, new_closing)
with open("lib/screens/search/search_screen.dart", "w") as f:
    f.write(text)
