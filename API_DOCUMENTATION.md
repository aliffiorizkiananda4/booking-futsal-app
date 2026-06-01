# API Documentation - Futsal Booking Backend

Dokumentasi lengkap API endpoints untuk aplikasi Futsal Booking.

## Base URL

```
Development: http://localhost:9000
Android Emulator: http://10.0.2.2:9000
Production: [Your Production URL]
```

## Authentication

Semua endpoint (kecuali `/auth/login` dan `/auth/register`) memerlukan authentication token di header:

```
Authorization: Bearer <token>
```

---

## 📌 Endpoints

### 1. Authentication

#### 1.1 Register
Membuat akun user baru.

**Endpoint:** `POST /auth/register`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "081234567890"
}
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "081234567890",
    "role": "user"
  }
}
```

**Response Error (400):**
```json
{
  "success": false,
  "message": "Email already exists"
}
```

---

#### 1.2 Login
Login user dan mendapatkan token.

**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user"
  }
}
```

**Response Error (401):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

---

### 2. Fields (Lapangan)

#### 2.1 Get All Fields
Mendapatkan semua lapangan futsal.

**Endpoint:** `GET /fields`

**Headers:**
```
Authorization: Bearer <token>
```

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Lapangan A",
      "type": "Vinyl",
      "price": 150000,
      "description": "Lapangan futsal dengan rumput sintetis berkualitas",
      "image": "http://localhost:9000/uploads/field1.jpg",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    },
    {
      "id": 2,
      "name": "Lapangan B",
      "type": "Rumput Sintetis",
      "price": 200000,
      "description": "Lapangan futsal indoor dengan AC",
      "image": "http://localhost:9000/uploads/field2.jpg",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

---

#### 2.2 Get Field by ID
Mendapatkan detail lapangan berdasarkan ID.

**Endpoint:** `GET /fields/:id`

**Headers:**
```
Authorization: Bearer <token>
```

**URL Parameters:**
- `id` (integer, required): ID lapangan

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Lapangan A",
    "type": "Vinyl",
    "price": 150000,
    "description": "Lapangan futsal dengan rumput sintetis berkualitas",
    "image": "http://localhost:9000/uploads/field1.jpg",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**Response Error (404):**
```json
{
  "success": false,
  "message": "Field not found"
}
```

---

### 3. Schedules (Jadwal)

#### 3.1 Get All Schedules
Mendapatkan semua jadwal yang tersedia.

**Endpoint:** `GET /schedules`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters (Optional):**
- `field_id` (integer): Filter jadwal berdasarkan lapangan

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "field_id": 1,
      "date": "2024-06-15",
      "start_time": "08:00",
      "end_time": "10:00",
      "status": "available",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    },
    {
      "id": 2,
      "field_id": 1,
      "date": "2024-06-15",
      "start_time": "10:00",
      "end_time": "12:00",
      "status": "booked",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

---

#### 3.2 Get Schedules by Field
Mendapatkan jadwal berdasarkan lapangan tertentu.

**Endpoint:** `GET /schedules?field_id=:field_id`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `field_id` (integer, required): ID lapangan

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "field_id": 1,
      "date": "2024-06-15",
      "start_time": "08:00",
      "end_time": "10:00",
      "status": "available",
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

---

### 4. Bookings

#### 4.1 Get User Bookings
Mendapatkan riwayat booking user yang sedang login.

**Endpoint:** `GET /bookings`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters (Optional):**
- `page` (integer, default: 1): Halaman pagination
- `limit` (integer, default: 10): Jumlah data per halaman

**Response Success (200):**
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "field_id": 1,
        "schedule_id": 1,
        "status": "pending",
        "createdAt": "2024-06-01T10:00:00.000Z",
        "updatedAt": "2024-06-01T10:00:00.000Z",
        "field": {
          "id": 1,
          "name": "Lapangan A",
          "type": "Vinyl",
          "price": 150000,
          "image": "http://localhost:9000/uploads/field1.jpg"
        },
        "schedule": {
          "id": 1,
          "date": "2024-06-15",
          "start_time": "08:00",
          "end_time": "10:00"
        }
      }
    ],
    "page": 1,
    "limit": 10,
    "totalPage": 1,
    "total": 1
  }
}
```

---

#### 4.2 Create Booking
Membuat booking baru.

**Endpoint:** `POST /bookings`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "field_id": 1,
  "schedule_id": 1
}
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "Booking created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "field_id": 1,
    "schedule_id": 1,
    "status": "pending",
    "createdAt": "2024-06-01T10:00:00.000Z",
    "updatedAt": "2024-06-01T10:00:00.000Z"
  }
}
```

**Response Error (400):**
```json
{
  "success": false,
  "message": "Schedule is not available"
}
```

**Response Error (404):**
```json
{
  "success": false,
  "message": "Field or schedule not found"
}
```

---

## 📊 Status Codes

| Code | Description |
|------|-------------|
| 200  | OK - Request berhasil |
| 201  | Created - Resource berhasil dibuat |
| 400  | Bad Request - Request tidak valid |
| 401  | Unauthorized - Token tidak valid atau tidak ada |
| 404  | Not Found - Resource tidak ditemukan |
| 500  | Internal Server Error - Error di server |

---

## 🔐 Authentication Flow

### 1. Register
```
Client -> POST /auth/register
Server -> Return user data (no token)
```

### 2. Login
```
Client -> POST /auth/login
Server -> Return token + user data
Client -> Save token to SharedPreferences
```

### 3. Authenticated Request
```
Client -> GET /fields (with token in header)
Server -> Verify token
Server -> Return data
```

### 4. Logout
```
Client -> Remove token from SharedPreferences
```

---

## 📝 Data Models

### User
```typescript
{
  id: number
  name: string
  email: string
  phone: string
  role: 'user' | 'admin'
  createdAt: Date
  updatedAt: Date
}
```

### Field
```typescript
{
  id: number
  name: string
  type: string
  price: number
  description: string
  image: string
  createdAt: Date
  updatedAt: Date
}
```

### Schedule
```typescript
{
  id: number
  field_id: number
  date: string (YYYY-MM-DD)
  start_time: string (HH:mm)
  end_time: string (HH:mm)
  status: 'available' | 'booked'
  createdAt: Date
  updatedAt: Date
}
```

### Booking
```typescript
{
  id: number
  user_id: number
  field_id: number
  schedule_id: number
  status: 'pending' | 'approved' | 'rejected'
  createdAt: Date
  updatedAt: Date
  field?: Field
  schedule?: Schedule
}
```

---

## 🧪 Testing dengan Postman

### 1. Setup Environment
```
BASE_URL: http://localhost:9000
TOKEN: (akan diisi setelah login)
```

### 2. Test Register
```
POST {{BASE_URL}}/auth/register
Body (JSON):
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123",
  "phone": "081234567890"
}
```

### 3. Test Login
```
POST {{BASE_URL}}/auth/login
Body (JSON):
{
  "email": "test@example.com",
  "password": "password123"
}

Save token from response to environment variable
```

### 4. Test Get Fields
```
GET {{BASE_URL}}/fields
Headers:
Authorization: Bearer {{TOKEN}}
```

### 5. Test Create Booking
```
POST {{BASE_URL}}/bookings
Headers:
Authorization: Bearer {{TOKEN}}
Content-Type: application/json

Body (JSON):
{
  "field_id": 1,
  "schedule_id": 1
}
```

---

## 🔧 Error Handling

### Common Errors

#### 1. Token Expired
```json
{
  "success": false,
  "message": "Token expired"
}
```
**Solution:** Login ulang untuk mendapatkan token baru

#### 2. Invalid Token
```json
{
  "success": false,
  "message": "Invalid token"
}
```
**Solution:** Check format token di header

#### 3. Missing Required Fields
```json
{
  "success": false,
  "message": "Missing required fields",
  "errors": {
    "email": "Email is required",
    "password": "Password is required"
  }
}
```
**Solution:** Lengkapi semua field yang required

#### 4. Duplicate Entry
```json
{
  "success": false,
  "message": "Email already exists"
}
```
**Solution:** Gunakan email yang berbeda

---

## 📚 Additional Notes

### Image Upload
- Format: JPG, PNG
- Max size: 5MB
- Stored in: `/uploads` directory
- URL format: `http://localhost:9000/uploads/filename.jpg`

### Pagination
- Default page: 1
- Default limit: 10
- Max limit: 100

### Date Format
- Date: `YYYY-MM-DD` (e.g., 2024-06-15)
- Time: `HH:mm` (e.g., 08:00)
- DateTime: ISO 8601 (e.g., 2024-06-01T10:00:00.000Z)

### Status Values
- Schedule status: `available`, `booked`
- Booking status: `pending`, `approved`, `rejected`
- User role: `user`, `admin`

---

**API Version:** 1.0.0  
**Last Updated:** June 2024
