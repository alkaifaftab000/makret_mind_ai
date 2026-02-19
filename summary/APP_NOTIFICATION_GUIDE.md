# AppNotification Widget Utility - Implementation Guide

## Overview
A minimalist, reusable notification system for displaying user-friendly feedback messages throughout the app.

## Features

### 4 Notification Types
1. **Success** - Green with checkmark icon
2. **Error** - Red with error icon
3. **Warning** - Amber with warning icon
4. **Info** - Blue with info icon

### Characteristics
- ✅ Floating snackbars (don't overlap navigation)
- ✅ Rounded corners (12px)
- ✅ Icons with text
- ✅ Customizable duration
- ✅ Minimalist design using Poppins font
- ✅ Auto-dismiss

## Usage

### Success Notification
```dart
AppNotification.success(
  context,
  message: 'Brand created successfully!',
);
```

### Error Notification
```dart
AppNotification.error(
  context,
  message: 'Failed to pick image. Please try again.',
);
```

### Warning Notification
```dart
AppNotification.warning(
  context,
  message: 'Brand name is required',
);
```

### Info Notification
```dart
AppNotification.info(
  context,
  message: 'Processing your request...',
);
```

### Custom Duration
```dart
AppNotification.success(
  context,
  message: 'Saved!',
  duration: const Duration(seconds: 1), // Default: 2 seconds
);
```

## Implementation in CreateBrandSheet

### Image Picker Error Handling
```dart
Future<void> _pickImage() async {
  try {
    final imagePath = await ImageUtils.pickImage(
      source: ImageSource.gallery,
    );
    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
    }
  } catch (e) {
    if (mounted) {
      AppNotification.error(
        context,
        message: 'Failed to pick image. Please try again.',
      );
    }
  }
}
```

### Form Validation
```dart
// Validate brand name
if (_nameController.text.isEmpty) {
  AppNotification.warning(
    context,
    message: 'Brand name is required',
  );
  return;
}

// Validate image
if (_selectedImagePath == null) {
  AppNotification.warning(
    context,
    message: 'Brand logo is required',
  );
  return;
}
```

### Success After Creation
```dart
if (mounted) {
  widget.onBrandCreated(brand);
  Navigator.pop(context);
  AppNotification.success(
    context,
    message: 'Brand created successfully!',
  );
}
```

### Error During Creation
```dart
catch (e) {
  if (mounted) {
    AppNotification.error(
      context,
      message: 'Error creating brand. Please try again.',
    );
  }
}
```

## Visual Design

### Layout
- Icon (20px) + 12px spacing + Text (flex)
- Horizontal margins: 16px
- Vertical padding: 12px horizontal padding
- Border radius: 12px

### Colors
| Type    | Background    | Icon/Text  |
|---------|---------------|------------|
| Success | Green 600     | White      |
| Error   | Red 600       | White      |
| Warning | Amber 600     | White      |
| Info    | Blue 600      | White      |

### Icons
| Type    | Icon                        |
|---------|----------------------------|
| Success | check_circle_rounded        |
| Error   | error_rounded               |
| Warning | warning_rounded             |
| Info    | info_rounded                |

## Durations

Default durations:
```dart
success: 2 seconds (quick confirmation)
error:   3 seconds (give time to read)
warning: 2 seconds (quick alert)
info:    2 seconds (informational)
```

## Best Practices

1. **Always check mounted** before showing notifications after async operations
   ```dart
   if (mounted) {
     AppNotification.success(context, message: 'Done!');
   }
   ```

2. **Use clear, concise messages**
   - ✅ "Brand name is required"
   - ❌ "The brand name field cannot be left empty"

3. **Match notification type to situation**
   - ✅ Warning for validation errors
   - ✅ Error for failed operations
   - ✅ Success for completed operations

4. **Don't overuse notifications**
   - Show only important feedback
   - Avoid notification overload

## File Location
```
lib/utils/app_notification.dart
```

## Import
```dart
import 'package:market_mind/utils/app_notification.dart';
```

## Example: Complete Form Submission

```dart
Future<void> _submitBrand() async {
  // Validation warnings
  if (_nameController.text.isEmpty) {
    AppNotification.warning(
      context,
      message: 'Brand name is required',
    );
    return;
  }

  if (_selectedImagePath == null) {
    AppNotification.warning(
      context,
      message: 'Brand logo is required',
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    // Create brand
    final brand = await brandService.createBrand(
      name: _nameController.text,
      imagePath: _selectedImagePath!,
      // ... other fields
    );

    if (mounted) {
      widget.onBrandCreated(brand);
      Navigator.pop(context);
      
      // Success notification
      AppNotification.success(
        context,
        message: 'Brand created successfully!',
      );
    }
  } catch (e) {
    if (mounted) {
      // Error notification
      AppNotification.error(
        context,
        message: 'Error creating brand. Please try again.',
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }
}
```

## Customization

To customize colors, modify in `app_notification.dart`:

```dart
case NotificationType.success:
  backgroundColor = Colors.green.shade600;  // Change this
  icon = Icons.check_circle_rounded;         // Or this
  textColor = Colors.white;                  // Or this
  break;
```

## Future Enhancements

- [ ] Add toast notifications (no action button)
- [ ] Add custom icon support
- [ ] Add action buttons (undo, retry)
- [ ] Add animation transitions
- [ ] Add sound/haptic feedback option
- [ ] Add message history
- [ ] Add queue for multiple notifications

## Status
✅ **Complete and Production Ready**
