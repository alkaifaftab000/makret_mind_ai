# Android Image Picker Permission Fix

## Problem
Image picker fails with:
```
PlatformException(channel-error, Unable to establish connection on channel: 
"dev.flutter.pigeon.image_picker_android.ImagePickerApi.pickImages"., null, null)
```

## Root Causes
1. **Missing Runtime Permissions**: Android requires runtime permission requests for image gallery access
2. **Plugin Channel Issue**: Image picker plugin can't communicate with Android platform
3. **Build Cache**: Flutter build cache may have stale plugin binaries

## Solution

### Step 1: Clean Build (CRITICAL)
Run these commands in order:

```bash
flutter clean
rm -rf android/build/  # Windows: rmdir android\build /s /q
rm -rf build/
flutter pub get
flutter pub cache clean
```

### Step 2: Build APK with Clean Build
```bash
flutter build apk --release --clean
```

### Step 3: Rebuild and Run
```bash
flutter run --no-build-cache
```

### Step 4: Verify Permissions Work
1. Launch the app on Android device
2. Try to pick an image
3. System should prompt for photo/gallery permission
4. Grant permission
5. Image picker should now work

## Technical Details

### Permissions Added
- **READ_EXTERNAL_STORAGE**: Access photos on older Android versions
- **READ_MEDIA_IMAGES**: Access photos on Android 13+ (required)
- **CAMERA**: For camera capture functionality

Location: `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.CAMERA" />
```

### Runtime Permission Handling
File: `lib/utils/permission_utils.dart`

The app now requests permissions at runtime before opening the image picker:

```dart
// In _pickImage() method
final permissionGranted = await PermissionUtils.requestPhotosPermission();
if (!permissionGranted) {
  AppNotification.warning(context, message: 'Permission required to access photos');
  return;
}
```

### Dependencies Added
- **permission_handler: ^11.4.0**: Manages Android runtime permissions

## Common Issues & Fixes

### Issue 1: "Permission required to access photos" notification appears
**Solution**: Grant permission when Android prompts you. Check device settings:
- Settings → Apps → Market Mind → Permissions → Photo/Media Access → Allow

### Issue 2: Image picker still fails after permission grant
**Solution**: Run clean build:
```bash
flutter clean
flutter pub get
flutter build apk --release --clean
```

### Issue 3: App crashes when trying to pick image
**Solution**: Check Android device logs:
```bash
flutter logs
```
Look for "image_picker" or "flutter" errors, then check if:
- Permissions are granted in device settings
- App has READ_EXTERNAL_STORAGE permission
- AndroidManifest.xml has all required permissions

### Issue 4: Snackbar appearing at wrong position
**Fixed in latest update**: Changed from ScaffoldMessenger to custom Overlay
- Notifications now appear at the bottom of the screen
- No longer conflicts with Material3 Material behavior
- Consistent positioning across all screens

## Android Device Testing Checklist

- [ ] Uninstall previous app version from device
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`
- [ ] Run `flutter build apk --release --clean`
- [ ] Install fresh APK on device
- [ ] Open app
- [ ] Tap "Create Brand" button
- [ ] Tap image picker icon
- [ ] Android prompts for permission → Grant
- [ ] Gallery app opens → Select image
- [ ] Image loads successfully in UI
- [ ] Notification shows at bottom (not top)

## Installation Commands

```bash
# Complete clean rebuild
flutter clean
flutter pub get

# Build for testing
flutter build apk --debug --clean

# Build for release
flutter build apk --release --clean

# Install and run
flutter run --no-build-cache

# View logs
flutter logs
```

## File Changes Summary

1. **android/app/src/main/AndroidManifest.xml**
   - Added 3 permission declarations

2. **pubspec.yaml**
   - Added `permission_handler: ^11.4.0`

3. **lib/utils/permission_utils.dart** (NEW)
   - Request photos permission
   - Check permission status
   - Open app settings if needed

4. **lib/utils/app_notification.dart**
   - Changed from ScaffoldMessenger to custom Overlay
   - Now shows at bottom of screen (not top)
   - Better visual consistency

5. **lib/screens/home/home_screen.dart**
   - Added permission check in `_pickImage()` method
   - Shows warning if permission denied
   - Proper error handling

## Next Steps

1. Run the complete clean build process above
2. Test on physical Android device (not just emulator)
3. Verify:
   - Permission dialog appears when tapping image picker
   - Gallery opens after granting permission
   - Selected image displays in UI
   - Success notification appears at bottom when creating brand

## Still Having Issues?

If problems persist after all steps:

1. Check device settings:
   ```
   Settings → Apps → Market Mind → Permissions → Photo/Media Access
   ```
   Ensure it's set to "Allow"

2. Check Play Store/device restrictions:
   - Some devices restrict app to Media Storage only
   - Ensure app-level restrictions aren't enabled

3. Check MinSdk version:
   - MinSdk should be 21 or higher
   - Found in `android/app/build.gradle.kts`

4. Verify image_picker plugin:
   ```bash
   flutter pub get
   flutter pub upgrade image_picker
   ```

5. Last resort - rebuild from scratch:
   ```bash
   flutter clean
   rm -rf ios/
   rm -rf android/
   flutter create . --org com.example
   ```

## Support

For permission_handler documentation:
https://pub.dev/packages/permission_handler

For image_picker documentation:
https://pub.dev/packages/image_picker

For Flutter Android documentation:
https://flutter.dev/docs/deployment/android
