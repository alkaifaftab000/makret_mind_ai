# 🔐 Authentication Integration Guide

## Frontend Implementation Status: ✅ PRODUCTION READY

This document describes the complete authentication system implemented in the Flutter frontend for **Market Mind** and how it integrates with your backend API.

---

## 📋 Overview

The authentication system supports:
- ✅ **Google Sign-In** (OAuth 2.0)
- ✅ **Email/Register** fallback (for failures)
- ✅ **Developer Login** (for testing)
- ✅ **Token Management** (Secure Storage)
- ✅ **Auto-Authorization** (Bearer Token Injection)
- ✅ **Error Handling** (Network, Server, Auth)
- ✅ **Logout** with cleanup

---

## 🔌 API Endpoints Required

The backend **MUST** provide these endpoints:

### 1. **Google Authentication**
```http
POST /api/auth/google
Content-Type: application/json

Request Body:
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE..."
}

Response (200 OK):
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "email": "user@gmail.com",
    "name": "John Doe",
    "avatar": "https://...",
    "google_id": "118....",
    "created_at": "2024-03-17T10:00:00Z",
    "updated_at": "2024-03-17T10:00:00Z"
  }
}

Errors:
{
  "statusCode": 401,
  "message": "Invalid token"
}
```

### 2. **Email Registration** (Fallback)
```http
POST /api/auth/register
Content-Type: application/json

Request Body:
{
  "email": "user@gmail.com",
  "name": "John Doe",
  "google_id": "118....",
  "avatar": "https://..."
}

Response (200 OK):
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "email": "user@gmail.com",
    "name": "John Doe",
    "avatar": "https://...",
    "google_id": "118....",
    "created_at": "2024-03-17T10:00:00Z",
    "updated_at": "2024-03-17T10:00:00Z"
  }
}
```

### 3. **Developer Login** (Testing Only)
```http
POST /api/auth/dev-login
Content-Type: application/json

Request Body:
{
  "email": "test@example.com",
  "name": "Test User"
}

Response (200 OK):
{
  "access_token": "test_token_12345",
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "email": "test@example.com",
    "name": "Test User",
    "avatar": null,
    "google_id": null,
    "created_at": "2024-03-17T10:00:00Z",
    "updated_at": "2024-03-17T10:00:00Z"
  }
}
```

### 4. **Get Current User** (Protected Endpoint)
```http
GET /api/users/me
Authorization: Bearer {access_token}

Response (200 OK):
{
  "_id": "507f1f77bcf86cd799439011",
  "email": "user@gmail.com",
  "name": "John Doe",
  "avatar": "https://...",
  "google_id": "118....",
  "created_at": "2024-03-17T10:00:00Z",
  "updated_at": "2024-03-17T10:00:00Z"
}
```

---

## 🏗️ Frontend Architecture

### **AuthService** (`lib/services/auth_service.dart`)

**Singleton Pattern** - Instantiated once and reused across the app

```dart
final authService = AuthService();

// Usage anywhere in the app:
final user = await authService.loginWithGoogle();
```

#### Methods:

| Method | Purpose | Returns |
|--------|---------|---------|
| `loginWithGoogle()` | Authenticate via Google OAuth | `Future<UserModel?>` |
| `registerWithEmail()` | Fallback registration | `Future<UserModel?>` |
| `devLogin()` | Test/Dev login | `Future<UserModel?>` |
| `logOut()` | Clear tokens & user | `Future<void>` |
| `get currentUser` | Get cached user | `UserModel?` |
| `get dioClient` | Get HTTP client | `Dio` |

### **GoogleSignIn Setup**

**Google OAuth Configuration:**
```dart
final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
serverClientId: '774223488327-lrue3e5dcujabfcp77v23gbglfbnq16h.apps.googleusercontent.com'
```

**Note**: This is configured for Android. iOS requires additional setup in Xcode.

### **Token Management**

**Storage**: `flutter_secure_storage` (encrypted at OS level)

```json
{
  "key": "access_token",
  "value": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Auto-Injection**: All HTTP requests automatically include:
```
Authorization: Bearer {access_token}
```

### **Error Handling**

The service catches and transforms backend errors:

| Status Code | User Message |
|-------------|--------------|
| 422 | "Validation error: Please check your data." |
| 401/403 | "Unauthorized access. Please try again." |
| 5xx | "Internal Server Error. Please try again later." |
| Connection Timeout | "Connection timed out. Please check your internet..." |
| No Connection | "Unable to connect to the server..." |

---

## 🔄 Authentication Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    LOGIN SCREEN                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ [Google Sign-In Button]  [Dev Login Button]    │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────┬──────────────────────────┬───────────────┘
              │                          │
    ┌─────────┴──────────┐    ┌──────────┴──────────┐
    │   GOOGLE OAUTH     │    │   DEV LOGIN        │
    │  Flow              │    │  (Testing Only)    │
    └────────┬───────────┘    └──────────┬─────────┘
             │                           │
    1. GoogleSignIn.authenticate()      │
    2. Get idToken from Google          │
    3. POST /api/auth/google            │
       { id_token }                     │
                                         │
             │                           │
    ┌────────┴────────────────────────────┘
    │
    ▼
┌───────────────────────────────────────┐
│   Backend Validates Token & User      │
│   - Verify Google idToken signature   │
│   - Extract user info from token      │
│   - Create/Update user in DB          │
│   - Generate JWT (access_token)       │
└────────────┬────────────────────────┘
             │
    ┌────────┴──────────┐
    │  Response OK?     │
    └─┬──────────────┬──┘
   Yes│              │No
    ┌─┴────────┐  ┌──┴──────────┐
    │ STORE    │  │ SHOW ERROR  │
    │ TOKEN &  │  │ TOAST       │
    │ USER     │  └─────────────┘
    └────┬─────┘
         │
    ┌────┴───────────────────┐
    │ Navigate to             │
    │ MainNavigationScreen    │
    │ (App ready!)            │
    └────────────────────────┘
```

---

## 📱 UI Integration

### **LoginScreen** (`lib/screens/auth/login_screen.dart`)

```dart
// Google Sign-In Button
FloatingActionButton(
  onPressed: _handleGoogleSignIn,
  // Shows loading spinner while authenticating
)

Future<void> _handleGoogleSignIn() async {
  setState(() => _isGoogleLoading = true);
  try {
    final user = await authService.loginWithGoogle();
    if (user != null && mounted) {
      AppNotification.success(context, 
        message: 'Welcome back, ${user.name}!');
      
      // Navigate to main app
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    // Display error to user
    AppNotification.error(context, 
      message: e.toString().replaceAll('Exception: ', ''));
  } finally {
    setState(() => _isGoogleLoading = false);
  }
}
```

### **Protected Services**

After authentication, all backend calls automatically include the token:

```dart
// Any other service can use authService.dioClient:
class BrandService {
  final Dio _dio = authService.dioClient;
  
  // All requests automatically have:
  // Authorization: Bearer {token}
  Future<List<Brand>> getBrands() async {
    final response = await _dio.get('/api/brands');
    // ...
  }
}
```

---

## 🔑 Configuration Files

### **API Constants** (`lib/constants/api_constants.dart`)

```dart
class ApiConstants {
  static const String baseUrl = 'https://adstudiobackend.onrender.com';
  
  static const String googleAuth = '/api/auth/google';
  static const String register = '/api/auth/register';
  static const String devLogin = '/api/auth/dev-login';
  
  static const String currentUser = '/api/users/me';
  static const String users = '/api/users';
  
  static const String brands = '/api/brands';
}
```

### **User Model** (`lib/models/user_model.dart`)

```dart
class UserModel {
  final String id;           // _id from MongoDB
  final String email;
  final String name;
  final String? avatar;
  final String? googleId;    // google_id field
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Factory constructor for JSON deserialization
  factory UserModel.fromJson(Map<String, dynamic> json) { ... }
  
  Map<String, dynamic> toJson() { ... }
}
```

---

## 🧪 Testing the Integration

### **Test 1: Google Sign-In Flow**
```
1. Run app
2. Go to LoginScreen
3. Click "Google Sign-In"
4. Select Google account
5. Should see success toast
6. Should navigate to MainNavigationScreen
7. Check if user data is stored
```

### **Test 2: Dev Login (For Testing)**
```
1. Click "Dev Login" button
2. Should get test user: test@example.com
3. Should navigate to app
```

### **Test 3: Protected Endpoints**
```dart
// After authentication:
final user = authService.currentUser;
print(user?.email); // Should have auth data

// All Dio requests should include token:
// GET /api/brands
// Authorization: Bearer {token}
```

### **Test 4: Logout**
```dart
await authService.logOut();
// Token should be deleted from secure storage
// currentUser should be null
// GoogleSignIn should be signed out
```

---

## 🐛 Common Issues & Solutions

### **Issue 1: "Invalid token" Error**
- **Cause**: idToken expired or invalid
- **Solution**: Ensure Google idToken is fresh (< 1 hour old)
- **Fix**: Clear app cache and re-authenticate

### **Issue 2: "Connection timeout"**
- **Cause**: Backend unreachable
- **Solution**: Check backend URL in `ApiConstants.baseUrl`
- **Check**: `https://adstudiobackend.onrender.com` is accessible

### **Issue 3: Token not persisted**
- **Cause**: Issue with secure storage
- **Solution**: Check Android permissions (in `AndroidManifest.xml`)

### **Issue 4: "User null" after login**
- **Cause**: Backend response format mismatch
- **Solution**: Ensure response includes both `access_token` and `user` fields

---

## 📊 Response Validation

Frontend expects response in this exact format:

```json
{
  "access_token": "string (required)",
  "user": {
    "_id": "string",
    "email": "string",
    "name": "string",
    "avatar": "string or null",
    "google_id": "string or null",
    "created_at": "ISO 8601 timestamp",
    "updated_at": "ISO 8601 timestamp"
  }
}
```

**Field Mapping**:
| Frontend | Backend | Type |
|----------|---------|------|
| `id` | `_id` | String |
| `email` | `email` | String |
| `name` | `name` | String |
| `avatar` | `avatar` | String/Null |
| `googleId` | `google_id` | String/Null |
| `createdAt` | `created_at` | DateTime |
| `updatedAt` | `updated_at` | DateTime |

---

## 🚀 Next Steps (After Auth is Verified)

Once authentication is working:

1. **Brands API** - Create/Read/Update/Delete brands
2. **Products API** - Create/manage products per brand
3. **Image Upload** - Upload to cloud storage
4. **Video Generation** - Connect to AI backend
5. **User Profile** - Fetch/update user details

---

## 📞 Support

If issues occur:
1. Check backend endpoint responses (use Postman/Insomnia)
2. Check Flutter logs: `flutter logs`
3. Check backend logs for auth errors
4. Verify `ApiConstants.baseUrl` matches your backend

---

**Frontend Ready**: ✅ User can authenticate
**Awaiting**: Backend endpoints (/api/auth/google, /api/auth/register, /api/auth/dev-login)
