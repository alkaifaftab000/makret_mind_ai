# Database Architecture Documentation

## Overview
The Market Mind app uses **Hive** as a local persistent database to store brand data. This document explains the structure and how to integrate with backend APIs.

## Technology Stack
- **Database**: Hive (Flutter local NoSQL database)
- **Code Generation**: Build Runner + Hive Generator
- **File Storage**: Local app documents directory
- **Image Handling**: `image_picker` + local file storage

## Database Schema

### BrandModel
Stored in `lib/models/brand_model.dart` with the following fields:

```dart
@HiveType(typeId: 0)
class BrandModel {
  @HiveField(0) String id;              // UUID generated locally
  @HiveField(1) String name;            // Required: Brand name
  @HiveField(2) String? description;    // Optional: Brand description
  @HiveField(3) String? targetAudience; // Optional: Target audience
  @HiveField(4) String? category;       // Optional: Category
  @HiveField(5) String imagePath;       // Required: Local file path
  @HiveField(6) int productions;        // Number of productions (default: 0)
  @HiveField(7) DateTime createdAt;     // Auto-timestamp
  @HiveField(8) DateTime updatedAt;     // Auto-timestamp
}
```

## File Structure

```
lib/
├── models/
│   └── brand_model.dart          # Hive model with @HiveType decorator
│   └── brand_model.g.dart        # Generated adapter (do not edit!)
├── services/
│   ├── brand_service.dart        # Local database CRUD operations
│   └── api_service.dart          # Template for backend API integration
└── utils/
    └── image_utils.dart          # Image picking & local storage
```

## Key Services

### BrandService (`lib/services/brand_service.dart`)
Singleton service for all database operations:

```dart
// Get all brands
List<BrandModel> brands = await brandService.getAllBrands();

// Get single brand
BrandModel? brand = await brandService.getBrandById(id);

// Create brand
BrandModel brand = await brandService.createBrand(
  name: 'My Brand',
  imagePath: '/path/to/image.jpg',
  description: 'Optional description',
  targetAudience: 'Optional audience',
  category: 'Optional category',
);

// Update brand
BrandModel updated = await brandService.updateBrand(
  id: brandId,
  name: 'Updated Name',
  // ... other optional fields
);

// Delete brand
await brandService.deleteBrand(id);

// Search brands
List<BrandModel> results = await brandService.searchBrands('tech');

// Clear all (testing only)
await brandService.clearAllBrands();
```

### ImageUtils (`lib/utils/image_utils.dart`)
Handle image picking and local storage:

```dart
// Pick image from gallery
String? imagePath = await ImageUtils.pickImage(
  source: ImageSource.gallery, // or ImageSource.camera
);

// Save image to app directory (called automatically by pickImage)
String savedPath = await ImageUtils.saveImage(imageFile);

// Load image
File? imageFile = ImageUtils.loadImage(imagePath);

// Delete image
await ImageUtils.deleteImage(imagePath);

// Get image size
int? bytes = await ImageUtils.getImageSize(imagePath);
String formatted = ImageUtils.formatBytes(bytes!); // "2.5 MB"
```

## Local Storage Structure

### Images
Images are stored in the app's documents directory:
```
/data/user/0/com.example.market_mind/files/brand_images/
├── uuid1-random-string.jpg
├── uuid2-random-string.jpg
└── ...
```

### Hive Box
Hive opens a `brands` box that persists all BrandModel instances:
```
/data/user/0/com.example.market_mind/files/hive/brands.hive
```

## Data Flow: Create Brand

1. User opens CreateBrandSheet
2. User picks image via ImageUtils.pickImage()
3. Image is saved to `/files/brand_images/uuid.jpg`
4. User fills form: name, description, audience, category
5. User clicks "Create"
6. BrandService.createBrand() is called:
   - Generates UUID for brand
   - Stores BrandModel in Hive box with local image path
   - Returns the created BrandModel
7. HomeScreen reloads and displays new brand

## Data Flow: Search Brands

1. User types in search field
2. _filterBrands() filters local _brands list in real-time
3. No network request needed (all data local)

## API Integration Workflow

When you're ready to sync with backend:

### Step 1: Implement APIService
Edit `lib/services/api_service.dart` to implement actual HTTP requests:

```dart
static Future<Map<String, dynamic>> createBrand({...}) async {
  var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/brands'));
  request.fields['name'] = name;
  request.files.add(await http.MultipartFile.fromPath('image', imagePath));
  var response = await request.send();
  return jsonDecode(await response.stream.bytesToString());
}
```

### Step 2: Call from BrandService
Update `brandService.createBrand()` to sync with backend:

```dart
Future<BrandModel> createBrand({...}) async {
  // 1. Save to local Hive first
  final brand = BrandModel(...);
  await _brandsBox.put(id, brand);
  
  // 2. Upload to backend (non-blocking)
  try {
    final response = await APIService.createBrand(...);
    // 3. Update with backend ID if returned
    if (response['backendId'] != null) {
      brand.backendId = response['backendId'];
      await _brandsBox.put(id, brand);
    }
  } catch (e) {
    print('Backend sync failed, but local save succeeded');
  }
  
  return brand;
}
```

### Step 3: Implement Offline-First Logic
- **Local First**: Save to Hive immediately for instant UI feedback
- **Background Sync**: Upload to backend in the background
- **Conflict Resolution**: Handle cases where local changes conflict with backend
- **Error Handling**: Gracefully handle network failures

## Database Initialization

In `main.dart`:
```dart
void main() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register model adapter
  Hive.registerAdapter(BrandModelAdapter()); // Generated by build_runner
  
  // Initialize service
  await brandService.init();
  
  runApp(const MainApp());
}
```

## Rebuilding Generated Files

If you modify `BrandModel`, regenerate adapters:
```bash
flutter pub run build_runner build
# or watch mode:
flutter pub run build_runner watch
```

## Best Practices

1. **Always save locally first** - Provides instant user feedback
2. **Use UUIDs** - Easier to sync with backend later
3. **Store file paths, not bytes** - More memory efficient
4. **Clean up images** - Delete image files when brands are deleted
5. **Validate before saving** - Check name, image exist before database operations
6. **Handle timestamps** - Auto-managed by BrandModel
7. **Search locally** - Filter in-memory, no network request needed
8. **Error handling** - Always wrap database operations in try-catch

## Future Enhancements

- [ ] Add authentication tokens to APIService
- [ ] Implement conflict resolution for offline changes
- [ ] Add pagination for large brand lists
- [ ] Implement incremental sync (only new/changed items)
- [ ] Add data encryption for sensitive fields
- [ ] Implement brand soft-delete with restore functionality
- [ ] Add analytics/export functionality
