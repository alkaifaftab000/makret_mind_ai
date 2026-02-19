# Quick Start: Using the Database

## 1. Create a Brand

```dart
// In HomeScreen or CreateBrandSheet
final brand = await brandService.createBrand(
  name: 'My Awesome Brand',
  imagePath: selectedImagePath,  // from ImageUtils.pickImage()
  description: 'This is my brand',
  targetAudience: 'Millennials',
  category: 'Technology',
);
```

## 2. Load All Brands

```dart
List<BrandModel> brands = await brandService.getAllBrands();
// Returns list of all stored brands
```

## 3. Search Brands

```dart
List<BrandModel> results = await brandService.searchBrands('tech');
// Searches name and description, case-insensitive
```

## 4. Get Single Brand

```dart
BrandModel? brand = await brandService.getBrandById('brand-uuid');
// Returns null if not found
```

## 5. Update Brand

```dart
BrandModel updated = await brandService.updateBrand(
  id: brandId,
  name: 'New Name',
  // other fields optional
);
```

## 6. Delete Brand

```dart
await brandService.deleteBrand(brandId);
```

## 7. Pick Image

```dart
// From gallery
String? imagePath = await ImageUtils.pickImage(
  source: ImageSource.gallery,
);

// From camera
String? imagePath = await ImageUtils.pickImage(
  source: ImageSource.camera,
);
```

## 8. Load Image from Path

```dart
File? imageFile = ImageUtils.loadImage(imagePath);
if (imageFile != null) {
  // Display: Image.file(imageFile)
}
```

## Current Architecture

```
CreateBrandSheet
  ├─ Pick image → ImageUtils.pickImage()
  ├─ Fill form (name, desc, audience, category)
  └─ Submit → BrandService.createBrand()
                    ├─ Save to Hive
                    └─ Return BrandModel

HomeScreen
  ├─ Load brands → BrandService.getAllBrands()
  ├─ Display in 2×2 grid
  ├─ Search → BrandService.searchBrands()
  └─ Tap card → (TODO: Navigate to brand details)
```

## Backend Integration (Future)

When you implement the backend:

1. Uncomment and implement methods in `APIService`
2. Modify `BrandService.createBrand()` to also call `APIService.createBrand()`
3. Handle responses and sync back to Hive
4. Show loading indicator during upload
5. Handle errors gracefully

Example:
```dart
// In BrandService.createBrand()
final brand = BrandModel(...);
await _brandsBox.put(id, brand);  // Save locally first

// Upload to backend
try {
  final response = await APIService.createBrand(...);
  if (response['success']) {
    brand.backendId = response['id'];
    await _brandsBox.put(id, brand);
  }
} catch (e) {
  print('Backend sync failed, but local save succeeded');
}
```

## Known Limitations (TODO)

- [ ] Image cropping/editing UI
- [ ] Batch operations
- [ ] Backup/restore functionality
- [ ] Encryption for sensitive fields
- [ ] Pagination for large lists
- [ ] Duplicate detection
- [ ] Brand versioning

## File Locations

- **Images**: `/data/user/0/com.example.market_mind/files/brand_images/`
- **Database**: `/data/user/0/com.example.market_mind/files/hive/brands.hive`

## Debugging

Enable verbose logging:
```dart
// In main.dart
Hive.initFlutter(subDir: 'debug');  // Stores in debug folder
```

Clear all data for testing:
```dart
await brandService.clearAllBrands();
await ImageUtils.clearAllImages();
```

View Hive data directly (for advanced users):
```dart
final box = await Hive.openBox<BrandModel>('brands');
print(box.values); // All brands
print(box.length); // Count
```

## Performance Tips

- Search is instant (in-memory, no network)
- Image compression is automatic (85% quality)
- Hive queries are very fast
- No pagination needed for reasonable datasets (<10K items)

Happy coding! 🚀
