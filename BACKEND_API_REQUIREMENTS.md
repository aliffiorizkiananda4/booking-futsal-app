# BACKEND API REQUIREMENTS

Dokumentasi ini menjelaskan format API yang diharapkan oleh aplikasi Flutter.

## BASE URL

- **Development (Web):** `http://localhost:9000`
- **Development (Android Emulator):** `http://10.0.2.2:9000`

## AUTHENTICATION

Semua endpoint (kecuali `/auth/login` dan `/auth/register`) memerlukan header:
```
Authorization: Bearer <token>
```

---

## 1. LOGIN

### Endpoint
```
POST /auth/login
```

### Request Body
```json
{
  "email": "admin@gmail.com",
  "password": "password123"
}
```

### Response Success (200)
```json
{
  "status": 200,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Administrator",
      "email": "admin@gmail.com",
      "role": "admin"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Response Error (401)
```json
{
  "status": 401,
  "message": "Invalid credentials"
}
```

### ⚠️ PENTING
- Field `data.user.name` HARUS ada untuk menampilkan nama user di dashboard
- Field `data.token` HARUS ada untuk autentikasi request selanjutnya

---

## 2. REGISTER

### Endpoint
```
POST /auth/register
```

### Request Body
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "081234567890"
}
```

### Response Success (200/201)
```json
{
  "status": 201,
  "message": "User registered successfully",
  "data": {
    "id": 2,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

---

## 3. GET FIELDS (Daftar Lapangan)

### Endpoint
```
GET /fields
```

### Headers
```
Authorization: Bearer <token>
```

### Response Success (200)
```json
{
  "status": 200,
  "message": "Data berhasil ditampilkan",
  "data": [
    {
      "id": 1,
      "name": "Lapangan A",
      "type": "Vinyl",
      "price": 150000,
      "description": "Lapangan futsal dengan kualitas terbaik",
      "image": "lapangan1.jpg"
    },
    {
      "id": 2,
      "name": "Lapangan B",
      "type": "Rumput Sintetis",
      "price": 200000,
      "description": "Lapangan dengan rumput sintetis premium",
      "image": "lapangan2.jpg"
    }
  ]
}
```

### ⚠️ PENTING
- Response HARUS dalam format `{ data: [...] }`, bukan `{ fields: [...] }`
- Field `image` bisa berupa:
  - Nama file saja: `"lapangan1.jpg"` → akan diubah menjadi `http://10.0.2.2:9000/uploads/lapangan1.jpg`
  - URL lengkap: `"http://localhost:9000/uploads/lapangan1.jpg"` → akan diganti localhost dengan base URL yang sesuai

### Static Files
Backend harus serve static files dari folder uploads:
```javascript
// Express.js example
app.use('/uploads', express.static('uploads'));
```

---

## 4. GET FIELD BY ID (Detail Lapangan)

### Endpoint
```
GET /fields/:id
```

### Headers
```
Authorization: Bearer <token>
```

### Response Success (200)
```json
{
  "status": 200,
  "message": "Data berhasil ditampilkan",
  "data": {
    "id": 1,
    "name": "Lapangan A",
    "type": "Vinyl",
    "price": 150000,
    "description": "Lapangan futsal dengan kualitas terbaik",
    "image": "lapangan1.jpg"
  }
}
```

---

## 5. GET BOOKINGS (Daftar Booking User)

### Endpoint
```
GET /bookings?page=1&limit=10
```

### Headers
```
Authorization: Bearer <token>
```

### Query Parameters
- `page` (optional): Halaman yang diminta (default: 1)
- `limit` (optional): Jumlah data per halaman (default: 10)

### Response Success (200)
```json
{
  "status": 200,
  "message": "Data berhasil ditampilkan",
  "data": {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "field_id": 1,
        "schedule_id": 1,
        "status": "pending",
        "createdAt": "2026-06-01T10:00:00.000Z",
        "field": {
          "id": 1,
          "name": "Lapangan A",
          "type": "Vinyl",
          "price": 150000,
          "image": "lapangan1.jpg"
        }
      }
    ],
    "totalPage": 1,
    "total": 5
  }
}
```

### ⚠️ PENTING
- Response harus nested: `data.data` untuk array booking
- Field `field` (relasi) HARUS di-include untuk menampilkan nama lapangan
- Status yang valid: `pending`, `confirmed`, `paid`, `cancelled`

---

## 6. CREATE BOOKING

### Endpoint
```
POST /bookings
```

### Headers
```
Authorization: Bearer <token>
Content-Type: application/json
```

### Request Body
```json
{
  "field_id": 1,
  "schedule_id": 1
}
```

### Response Success (200/201)
```json
{
  "status": 201,
  "message": "Booking berhasil dibuat",
  "data": {
    "id": 1,
    "user_id": 1,
    "field_id": 1,
    "schedule_id": 1,
    "status": "pending",
    "createdAt": "2026-06-01T10:00:00.000Z"
  }
}
```

---

## 7. UPLOAD PAYMENT PROOF (BARU)

### Endpoint
```
POST /payments
```

### Headers
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

### Request Body (multipart/form-data)
```
booking_id: 1
payment_proof: [FILE]
```

### Response Success (200/201)
```json
{
  "status": 201,
  "message": "Bukti pembayaran berhasil diupload",
  "data": {
    "id": 1,
    "booking_id": 1,
    "payment_proof": "payment_1234567890.jpg",
    "status": "pending",
    "createdAt": "2026-06-01T10:30:00.000Z"
  }
}
```

### Response Error (400)
```json
{
  "status": 400,
  "message": "Booking tidak ditemukan"
}
```

### ⚠️ PENTING
- Endpoint ini HARUS dibuat di backend
- Method: POST
- Content-Type: multipart/form-data
- Field names:
  - `booking_id` (integer/string)
  - `payment_proof` (file)
- File yang diterima: image/jpeg, image/png
- Simpan file di folder uploads
- Update status booking menjadi "paid" atau "confirmed" setelah upload

### Backend Implementation Example (Express.js)
```javascript
const multer = require('multer');
const path = require('path');

// Configure multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'payment_' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only images are allowed'));
    }
  },
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB max
});

// Route
app.post('/payments', authenticateToken, upload.single('payment_proof'), async (req, res) => {
  try {
    const { booking_id } = req.body;
    const payment_proof = req.file.filename;
    
    // Validate booking exists
    const booking = await Booking.findByPk(booking_id);
    if (!booking) {
      return res.status(400).json({
        status: 400,
        message: 'Booking tidak ditemukan'
      });
    }
    
    // Create payment record
    const payment = await Payment.create({
      booking_id,
      payment_proof,
      status: 'pending'
    });
    
    // Optional: Update booking status
    await booking.update({ status: 'paid' });
    
    res.status(201).json({
      status: 201,
      message: 'Bukti pembayaran berhasil diupload',
      data: payment
    });
  } catch (error) {
    res.status(500).json({
      status: 500,
      message: error.message
    });
  }
});
```

---

## 8. GET SCHEDULES (Jadwal Lapangan)

### Endpoint
```
GET /schedules?field_id=1
```

### Headers
```
Authorization: Bearer <token>
```

### Query Parameters
- `field_id` (optional): Filter berdasarkan lapangan

### Response Success (200)
```json
{
  "status": 200,
  "message": "Data berhasil ditampilkan",
  "data": [
    {
      "id": 1,
      "field_id": 1,
      "date": "2026-06-02",
      "start_time": "08:00",
      "end_time": "10:00",
      "is_available": true
    },
    {
      "id": 2,
      "field_id": 1,
      "date": "2026-06-02",
      "start_time": "10:00",
      "end_time": "12:00",
      "is_available": false
    }
  ]
}
```

---

## DATABASE SCHEMA REQUIREMENTS

### Table: users
```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role ENUM('admin', 'user') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Table: fields
```sql
CREATE TABLE fields (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  type VARCHAR(100) NOT NULL,
  price INT NOT NULL,
  description TEXT,
  image VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Table: schedules
```sql
CREATE TABLE schedules (
  id INT PRIMARY KEY AUTO_INCREMENT,
  field_id INT NOT NULL,
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (field_id) REFERENCES fields(id)
);
```

### Table: bookings
```sql
CREATE TABLE bookings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  field_id INT NOT NULL,
  schedule_id INT NOT NULL,
  status ENUM('pending', 'confirmed', 'paid', 'cancelled') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (field_id) REFERENCES fields(id),
  FOREIGN KEY (schedule_id) REFERENCES schedules(id)
);
```

### Table: payments (BARU)
```sql
CREATE TABLE payments (
  id INT PRIMARY KEY AUTO_INCREMENT,
  booking_id INT NOT NULL,
  payment_proof VARCHAR(255),
  status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(id)
);
```

---

## CORS CONFIGURATION

Untuk development, backend harus mengizinkan CORS:

```javascript
// Express.js example
const cors = require('cors');

app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:9000'],
  credentials: true
}));
```

---

## ERROR HANDLING

Semua error response harus mengikuti format:

```json
{
  "status": 400,
  "message": "Error message here"
}
```

Status codes yang digunakan:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `500` - Internal Server Error

---

## TESTING ENDPOINTS

### Using cURL

#### Login
```bash
curl -X POST http://localhost:9000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@gmail.com","password":"password123"}'
```

#### Get Fields
```bash
curl -X GET http://localhost:9000/fields \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Get Bookings
```bash
curl -X GET http://localhost:9000/bookings \
  -H "Authorization: Bearer YOUR_TOKEN"
```

#### Upload Payment
```bash
curl -X POST http://localhost:9000/payments \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "booking_id=1" \
  -F "payment_proof=@/path/to/image.jpg"
```

### Using Postman

1. **Login**
   - Method: POST
   - URL: `http://localhost:9000/auth/login`
   - Body (JSON):
     ```json
     {
       "email": "admin@gmail.com",
       "password": "password123"
     }
     ```

2. **Get Fields**
   - Method: GET
   - URL: `http://localhost:9000/fields`
   - Headers:
     - Authorization: `Bearer YOUR_TOKEN`

3. **Upload Payment**
   - Method: POST
   - URL: `http://localhost:9000/payments`
   - Headers:
     - Authorization: `Bearer YOUR_TOKEN`
   - Body (form-data):
     - booking_id: `1`
     - payment_proof: [Select File]

---

## SAMPLE DATA

### Sample User (Admin)
```sql
INSERT INTO users (name, email, password, role) 
VALUES ('Administrator', 'admin@gmail.com', '$2b$10$...', 'admin');
```

### Sample Fields
```sql
INSERT INTO fields (name, type, price, description, image) VALUES
('Lapangan A', 'Vinyl', 150000, 'Lapangan futsal dengan kualitas terbaik', 'lapangan1.jpg'),
('Lapangan B', 'Rumput Sintetis', 200000, 'Lapangan dengan rumput sintetis premium', 'lapangan2.jpg'),
('Lapangan C', 'Parket', 180000, 'Lapangan indoor dengan lantai parket', 'lapangan3.jpg');
```

### Sample Schedules
```sql
INSERT INTO schedules (field_id, date, start_time, end_time, is_available) VALUES
(1, '2026-06-02', '08:00', '10:00', TRUE),
(1, '2026-06-02', '10:00', '12:00', TRUE),
(1, '2026-06-02', '14:00', '16:00', TRUE);
```
