# Market Mind AI - Codebase Guide

Welcome to the **Market Mind AI** codebase! This guide will help you navigate the project and show you how to add new features and UI changes without breaking existing functionality.

---

## 🏗 Architecture Overview

The project follows a **Layered Architecture** pattern to separate UI, Business Logic, and Data.

### 1. The `lib/` Directory
- **`constants/`**: Global configuration (colors, strings, text styles, API endpoints).
- **`models/`**: Data classes (PODOs) representing objects like `BrandModel`.
- **`screens/`**: UI Pages. Each feature (Home, Profile, etc.) has its own subfolder.
- **`services/`**: Business logic, API calls (Dio), and local storage (Hive).
- **`theme/`**: App-wide styling (Light/Dark mode definitions).
- **`utils/`**: Helper functions (Image picking, permissions, notifications).
- **`widgets/`**: Small, reusable UI components used across multiple screens.

---

## 🎨 UI & Design System

To keep the app looking premium and consistent, **always** use the existing design system.

### Colors
Do NOT use `Colors.black` or hex codes directly. Use `AppColors`:
```dart
import 'package:market_mind/constants/app_colors.dart';

// Example:
color: isDark ? AppColors.darkCard : AppColors.lightCard,
```

### Typography
Use `AppTextStyles` instead of manual `TextStyle`:
```dart
import 'package:market_mind/constants/app_text_styles.dart';

// Example:
Text(
  'My Heading',
  style: AppTextStyles.pageHeading(context, isDark),
)
```

---

## 🚀 How to Add a New Screen

### Step 1: Create the Screen Folder
Create a new directory in `lib/screens/`, for example: `lib/screens/settings/`.

### Step 2: Create the Screen File
Inside that folder, create `settings_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:market_mind/constants/app_colors.dart';
import 'package:market_mind/constants/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.titleMedium(context, isDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Text('Settings Content', style: AppTextStyles.bodyMedium(context, isDark)),
      ),
    );
  }
}
```

### Step 3: Register in Navigation
If it's a main bottom-nav screen, update `lib/screens/main_navigation_screen.dart`:
1. Add the screen to the `_screens` list.
2. Add a label to `_labels`.
3. Add an icon to `_icons`.

---

## 🛠 Making UI Changes Safely

If you want to change the "look" without breaking "logic":

1.  **Modify `lib/widgets/`**: If you change a component there, it updates everywhere.
2.  **Use `AppColors`**: Changing a color in `lib/constants/app_colors.dart` will update the entire app's theme.
3.  **Localize UI Logic**: Keep animation logic and `TextEditingControllers` inside the `State` of the widget, but keep API calls in `Services`.

### Example: Updating the Home Page UI
- Open `lib/screens/home/home_screen.dart`.
- The UI is built inside the `build` method and helper widgets like `_BrandCard`.
- To change the card layout, modify the `_BrandCard` class at the bottom of the file.

---

## 💡 Best Practices
- **Separation of Concerns**: UI stays in `screens/`, Logic stays in `services/`.
- **Don't hardcode strings**: Add them to `lib/constants/app_strings.dart`.
- **Use `SafeArea`**: Always wrap your screen content in a `SafeArea` or `Scaffold` body to handle notches/status bars.
- **Check for `isDark`**: Always check `Theme.of(context).brightness == Brightness.dark` to ensure your UI looks good in both themes.
