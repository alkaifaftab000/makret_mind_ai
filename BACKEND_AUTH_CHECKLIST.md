# 📝 Backend Developer - Quick Auth API Checklist

## ✅ Required Endpoints

### 1️⃣ Google Authentication
```
POST /api/auth/google
```
**Input**: `{ "id_token": "google...token" }`
**Output**: `{ "access_token": "jwt", "user": {...} }`
**Task**: Verify Google token → Find/Create user → Return JWT

---

### 2️⃣ Email Registration (Fallback)
```
POST /api/auth/register
```
**Input**: `{ "email": "x@y.com", "name": "John", "google_id": "...", "avatar": "url" }`
**Output**: `{ "access_token": "jwt", "user": {...} }`
**Task**: Create user if not exists → Return JWT

---

### 3️⃣ Dev Login (Testing)
```
POST /api/auth/dev-login
```
**Input**: `{ "email": "test@example.com", "name": "Test User" }`
**Output**: `{ "access_token": "test_token", "user": {...} }`
**Task**: Debug endpoint → Always succeeds

---

### 4️⃣ Current User (Protected)
```
GET /api/users/me
Header: Authorization: Bearer {token}
```
**Task**: Return current user info

---

## 📦 User Response Format

**EXACT format expected by frontend**:

```json
{
  "access_token": "eyJhbGc...",
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "email": "user@gmail.com",
    "name": "John Doe",
    "avatar": "https://...",
    "google_id": "118...",
    "created_at": "2024-03-17T10:00:00Z",
    "updated_at": "2024-03-17T10:00:00Z"
  }
}
```

**Key Notes**:
- ✅ `_id` not `id`
- ✅ `google_id` not `googleId`
- ✅ `created_at` not `createdAt` (ISO 8601)
- ✅ `access_token` is JWT for Bearer auth
- ✅ `avatar` can be null
- ✅ `google_id` can be null

---

## 🔐 Token Implementation

```
All protected endpoints need:
Authorization: Bearer {access_token}

Frontend will auto-inject this header via Dio interceptor.
```

---

## ⚠️ Error Handling

Frontend treats these status codes specially:

```
422 → "Validation error"
401/403 → "Unauthorized access"
5xx → "Internal Server Error"
timeout → "Connection timed out"
no-connection → "Unable to connect"
```

Generic errors shown as: `Exception: {message}`

---

## 🧪 Test Instructions

**Test 1: Dev Login** (Easiest start)
```
POST http://localhost:5000/api/auth/dev-login
Body: { "email": "test@example.com", "name": "Test User" }
Expected: { "access_token": "...", "user": {...} }
```

**Test 2: Google Token** (Need real Google account)
```
Frontend does: POST /api/auth/google
Body: { "id_token": "<from Android GoogleSignIn>" }
Expected: { "access_token": "...", "user": {...} }
```

---

## 📱 Frontend Info

- **Base URL**: `https://adstudiobackend.onrender.com`
- **Google OAuth Server ID**: `774223488327-lrue3e5dcujabfcp77v23gbglfbnq16h.apps.googleusercontent.com`
- **Token Storage**: Encrypted (flutter_secure_storage)
- **HTTP Client**: Dio with auto-token injection

---

## 🎯 Priority

1. **Dev Login** ← Start here (no Google needed)
2. **Google Auth** ← Then add Google OAuth
3. **Get Current User** ← Fetch user details

---

## 💻 Frontend Code Using Your API

```dart
// LocationL lib/services/auth_service.dart

Future<UserModel?> loginWithGoogle() async {
  // 1. Get idToken from Google
  final idToken = googleAuth.idToken;
  
  // 2. Call your endpoint
  final response = await _dio.post('/api/auth/google', 
    data: { 'id_token': idToken }
  );
  
  // 3. Parse response
  final token = response.data['access_token'];
  final user = UserModel.fromJson(response.data['user']);
  
  // 4. Store & return
  return user;
}
```

**All future requests include**:
```
Authorization: Bearer {access_token}
```

---

## ❓ Questions for Backend Dev

Before implementing, clarify:

1. ✅ Is MongoDB being used? (Field naming `_id`, `google_id` vs `googleId`)
2. ✅ Does backend verify Google idToken or does frontend?
3. ✅ Should `/register` endpoint create user or just validate?
4. ✅ Token expiry time?
5. ✅ Does backend support multiple accounts per email?

---

**Frontend Status**: ✅ READY TO TEST
**Awaiting**: Your backend endpoints implementation

