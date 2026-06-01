# BACKEND ROLE IMPLEMENTATION GUIDE

Panduan untuk Backend Developer mengimplementasikan Role-Based Access Control.

---

## DATABASE SCHEMA

### Update Table Users

Tambahkan kolom `role` ke table `users`:

```sql
ALTER TABLE users 
ADD COLUMN role ENUM('admin', 'user') DEFAULT 'user' AFTER phone;
```

Atau jika membuat table baru:

```sql
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role ENUM('admin', 'user') DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Sample Data

```sql
-- Admin User
INSERT INTO users (name, email, password, role) 
VALUES (
  'Administrator', 
  'admin@gmail.com', 
  '$2b$10$YourHashedPasswordHere', 
  'admin'
);

-- Regular User
INSERT INTO users (name, email, password, role) 
VALUES (
  'John Doe', 
  'user@gmail.com', 
  '$2b$10$YourHashedPasswordHere', 
  'user'
);
```

---

## LOGIN API UPDATE

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

### Response Format (REQUIRED)

**Success Response (200):**
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

**⚠️ PENTING:**
- Field `data.user.role` HARUS ada
- Value role: `"admin"` atau `"user"`
- Token JWT harus include role dalam payload

### Implementation Example (Express.js + Sequelize)

```javascript
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User } = require('../models');

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        status: 400,
        message: 'Email and password are required'
      });
    }

    // Find user
    const user = await User.findOne({ where: { email } });
    if (!user) {
      return res.status(401).json({
        status: 401,
        message: 'Invalid credentials'
      });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        status: 401,
        message: 'Invalid credentials'
      });
    }

    // Generate JWT token with role
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email,
        role: user.role  // ← INCLUDE ROLE IN TOKEN
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Return response
    res.status(200).json({
      status: 200,
      message: 'Login successful',
      data: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role  // ← INCLUDE ROLE IN RESPONSE
        },
        token
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      status: 500,
      message: 'Internal server error'
    });
  }
};
```

---

## MIDDLEWARE: AUTHENTICATION

### authenticateToken.js

```javascript
const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      status: 401,
      message: 'Access token required'
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({
        status: 403,
        message: 'Invalid or expired token'
      });
    }

    req.user = user; // { id, email, role }
    next();
  });
};

module.exports = authenticateToken;
```

---

## MIDDLEWARE: ROLE AUTHORIZATION

### authorizeRole.js

```javascript
const authorizeRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        status: 401,
        message: 'Authentication required'
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        status: 403,
        message: 'Access denied. Insufficient permissions.'
      });
    }

    next();
  };
};

module.exports = authorizeRole;
```

### Usage Example

```javascript
const authenticateToken = require('./middleware/authenticateToken');
const authorizeRole = require('./middleware/authorizeRole');

// Public endpoint
app.post('/auth/login', authController.login);

// User endpoint (both admin and user can access)
app.get('/bookings', authenticateToken, bookingController.getUserBookings);

// Admin only endpoints
app.post('/fields', authenticateToken, authorizeRole('admin'), fieldController.create);
app.put('/fields/:id', authenticateToken, authorizeRole('admin'), fieldController.update);
app.delete('/fields/:id', authenticateToken, authorizeRole('admin'), fieldController.delete);

// Admin only - approve booking
app.put('/bookings/:id/approve', authenticateToken, authorizeRole('admin'), bookingController.approve);

// Admin only - verify payment
app.put('/payments/:id/verify', authenticateToken, authorizeRole('admin'), paymentController.verify);
```

---

## PROTECTED ENDPOINTS

### Admin Only Endpoints

#### 1. Kelola Lapangan
```javascript
// Create field
POST /fields
Headers: Authorization: Bearer <token>
Body: { name, type, price, description, image }
Access: Admin only

// Update field
PUT /fields/:id
Headers: Authorization: Bearer <token>
Body: { name, type, price, description, image }
Access: Admin only

// Delete field
DELETE /fields/:id
Headers: Authorization: Bearer <token>
Access: Admin only
```

#### 2. Kelola Jadwal
```javascript
// Create schedule
POST /schedules
Headers: Authorization: Bearer <token>
Body: { field_id, date, start_time, end_time }
Access: Admin only

// Update schedule
PUT /schedules/:id
Headers: Authorization: Bearer <token>
Body: { field_id, date, start_time, end_time, is_available }
Access: Admin only

// Delete schedule
DELETE /schedules/:id
Headers: Authorization: Bearer <token>
Access: Admin only
```

#### 3. Kelola Booking
```javascript
// Get all bookings (admin sees all)
GET /bookings
Headers: Authorization: Bearer <token>
Access: Admin sees all, User sees only their bookings

// Approve booking
PUT /bookings/:id/approve
Headers: Authorization: Bearer <token>
Access: Admin only

// Reject booking
PUT /bookings/:id/reject
Headers: Authorization: Bearer <token>
Body: { reason }
Access: Admin only
```

#### 4. Kelola Pembayaran
```javascript
// Get all payments
GET /payments
Headers: Authorization: Bearer <token>
Access: Admin sees all, User sees only their payments

// Verify payment
PUT /payments/:id/verify
Headers: Authorization: Bearer <token>
Access: Admin only

// Reject payment
PUT /payments/:id/reject
Headers: Authorization: Bearer <token>
Body: { reason }
Access: Admin only
```

#### 5. Kelola User
```javascript
// Get all users
GET /users
Headers: Authorization: Bearer <token>
Access: Admin only

// Update user role
PUT /users/:id/role
Headers: Authorization: Bearer <token>
Body: { role: "admin" | "user" }
Access: Admin only

// Delete user
DELETE /users/:id
Headers: Authorization: Bearer <token>
Access: Admin only
```

### User Endpoints

```javascript
// Get fields (public or authenticated)
GET /fields
Headers: Authorization: Bearer <token> (optional)
Access: All users

// Create booking
POST /bookings
Headers: Authorization: Bearer <token>
Body: { field_id, schedule_id }
Access: Authenticated users

// Get my bookings
GET /bookings
Headers: Authorization: Bearer <token>
Access: User sees only their bookings

// Upload payment proof
POST /payments
Headers: Authorization: Bearer <token>
Body: multipart/form-data { booking_id, payment_proof }
Access: Authenticated users
```

---

## IMPLEMENTATION EXAMPLES

### 1. Get Bookings (Role-Based)

```javascript
exports.getBookings = async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = {};

    // If user role, only show their bookings
    if (req.user.role === 'user') {
      whereClause.user_id = req.user.id;
    }
    // If admin role, show all bookings (no filter)

    const { count, rows } = await Booking.findAndCountAll({
      where: whereClause,
      include: [
        { model: Field, as: 'field' },
        { model: Schedule, as: 'schedule' },
        { model: User, as: 'user', attributes: ['id', 'name', 'email'] }
      ],
      limit: parseInt(limit),
      offset: parseInt(offset),
      order: [['created_at', 'DESC']]
    });

    res.status(200).json({
      status: 200,
      message: 'Data berhasil ditampilkan',
      data: {
        data: rows,
        total: count,
        totalPage: Math.ceil(count / limit),
        currentPage: parseInt(page)
      }
    });
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({
      status: 500,
      message: 'Internal server error'
    });
  }
};
```

### 2. Approve Booking (Admin Only)

```javascript
exports.approveBooking = async (req, res) => {
  try {
    const { id } = req.params;

    // Find booking
    const booking = await Booking.findByPk(id);
    if (!booking) {
      return res.status(404).json({
        status: 404,
        message: 'Booking not found'
      });
    }

    // Update status
    await booking.update({ status: 'confirmed' });

    // Optional: Update schedule availability
    await Schedule.update(
      { is_available: false },
      { where: { id: booking.schedule_id } }
    );

    res.status(200).json({
      status: 200,
      message: 'Booking approved successfully',
      data: booking
    });
  } catch (error) {
    console.error('Approve booking error:', error);
    res.status(500).json({
      status: 500,
      message: 'Internal server error'
    });
  }
};
```

### 3. Verify Payment (Admin Only)

```javascript
exports.verifyPayment = async (req, res) => {
  try {
    const { id } = req.params;

    // Find payment
    const payment = await Payment.findByPk(id, {
      include: [{ model: Booking, as: 'booking' }]
    });

    if (!payment) {
      return res.status(404).json({
        status: 404,
        message: 'Payment not found'
      });
    }

    // Update payment status
    await payment.update({ status: 'verified' });

    // Update booking status to paid
    await Booking.update(
      { status: 'paid' },
      { where: { id: payment.booking_id } }
    );

    res.status(200).json({
      status: 200,
      message: 'Payment verified successfully',
      data: payment
    });
  } catch (error) {
    console.error('Verify payment error:', error);
    res.status(500).json({
      status: 500,
      message: 'Internal server error'
    });
  }
};
```

### 4. Create Field (Admin Only)

```javascript
const multer = require('multer');
const path = require('path');

// Multer config
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'field_' + uniqueSuffix + path.extname(file.originalname));
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
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

exports.createField = async (req, res) => {
  try {
    const { name, type, price, description } = req.body;
    const image = req.file ? req.file.filename : null;

    // Validate
    if (!name || !type || !price) {
      return res.status(400).json({
        status: 400,
        message: 'Name, type, and price are required'
      });
    }

    // Create field
    const field = await Field.create({
      name,
      type,
      price: parseInt(price),
      description,
      image
    });

    res.status(201).json({
      status: 201,
      message: 'Field created successfully',
      data: field
    });
  } catch (error) {
    console.error('Create field error:', error);
    res.status(500).json({
      status: 500,
      message: 'Internal server error'
    });
  }
};

// Route
app.post('/fields', 
  authenticateToken, 
  authorizeRole('admin'), 
  upload.single('image'), 
  fieldController.createField
);
```

---

## ROUTES CONFIGURATION

### routes/index.js

```javascript
const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const fieldController = require('../controllers/fieldController');
const scheduleController = require('../controllers/scheduleController');
const bookingController = require('../controllers/bookingController');
const paymentController = require('../controllers/paymentController');
const userController = require('../controllers/userController');

const authenticateToken = require('../middleware/authenticateToken');
const authorizeRole = require('../middleware/authorizeRole');

// ============================================
// PUBLIC ROUTES
// ============================================
router.post('/auth/login', authController.login);
router.post('/auth/register', authController.register);

// ============================================
// AUTHENTICATED ROUTES (All Users)
// ============================================
router.get('/fields', authenticateToken, fieldController.getAll);
router.get('/fields/:id', authenticateToken, fieldController.getById);
router.get('/schedules', authenticateToken, scheduleController.getAll);

// ============================================
// USER ROUTES
// ============================================
router.post('/bookings', authenticateToken, bookingController.create);
router.get('/bookings', authenticateToken, bookingController.getAll); // Role-based filter
router.post('/payments', authenticateToken, paymentController.upload);

// ============================================
// ADMIN ONLY ROUTES
// ============================================

// Fields Management
router.post('/fields', authenticateToken, authorizeRole('admin'), fieldController.create);
router.put('/fields/:id', authenticateToken, authorizeRole('admin'), fieldController.update);
router.delete('/fields/:id', authenticateToken, authorizeRole('admin'), fieldController.delete);

// Schedules Management
router.post('/schedules', authenticateToken, authorizeRole('admin'), scheduleController.create);
router.put('/schedules/:id', authenticateToken, authorizeRole('admin'), scheduleController.update);
router.delete('/schedules/:id', authenticateToken, authorizeRole('admin'), scheduleController.delete);

// Bookings Management
router.put('/bookings/:id/approve', authenticateToken, authorizeRole('admin'), bookingController.approve);
router.put('/bookings/:id/reject', authenticateToken, authorizeRole('admin'), bookingController.reject);

// Payments Management
router.get('/payments', authenticateToken, authorizeRole('admin'), paymentController.getAll);
router.put('/payments/:id/verify', authenticateToken, authorizeRole('admin'), paymentController.verify);
router.put('/payments/:id/reject', authenticateToken, authorizeRole('admin'), paymentController.reject);

// Users Management
router.get('/users', authenticateToken, authorizeRole('admin'), userController.getAll);
router.put('/users/:id/role', authenticateToken, authorizeRole('admin'), userController.updateRole);
router.delete('/users/:id', authenticateToken, authorizeRole('admin'), userController.delete);

module.exports = router;
```

---

## TESTING

### Test with cURL

#### 1. Login as Admin
```bash
curl -X POST http://localhost:9000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@gmail.com",
    "password": "password123"
  }'
```

**Expected Response:**
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

#### 2. Create Field (Admin Only)
```bash
curl -X POST http://localhost:9000/fields \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -F "name=Lapangan A" \
  -F "type=Vinyl" \
  -F "price=150000" \
  -F "description=Lapangan futsal terbaik" \
  -F "image=@/path/to/image.jpg"
```

#### 3. Try Create Field as User (Should Fail)
```bash
curl -X POST http://localhost:9000/fields \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -F "name=Lapangan B" \
  -F "type=Vinyl" \
  -F "price=150000"
```

**Expected Response:**
```json
{
  "status": 403,
  "message": "Access denied. Insufficient permissions."
}
```

---

## SECURITY BEST PRACTICES

### 1. Password Hashing
```javascript
const bcrypt = require('bcrypt');

// Hash password before saving
const hashedPassword = await bcrypt.hash(password, 10);

// Verify password
const isValid = await bcrypt.compare(password, user.password);
```

### 2. JWT Secret
```javascript
// .env
JWT_SECRET=your-super-secret-key-change-this-in-production
JWT_EXPIRES_IN=7d
```

### 3. Input Validation
```javascript
const { body, validationResult } = require('express-validator');

router.post('/fields',
  authenticateToken,
  authorizeRole('admin'),
  [
    body('name').notEmpty().withMessage('Name is required'),
    body('type').notEmpty().withMessage('Type is required'),
    body('price').isInt({ min: 0 }).withMessage('Price must be a positive number')
  ],
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
  fieldController.create
);
```

### 4. Rate Limiting
```javascript
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per windowMs
  message: 'Too many login attempts, please try again later'
});

router.post('/auth/login', loginLimiter, authController.login);
```

---

## DEPLOYMENT CHECKLIST

- [ ] Database has `role` column
- [ ] Sample admin user created
- [ ] JWT_SECRET set in environment variables
- [ ] All admin endpoints protected with authorizeRole('admin')
- [ ] Login API returns role in response
- [ ] Token includes role in payload
- [ ] CORS configured properly
- [ ] Rate limiting enabled
- [ ] Input validation implemented
- [ ] Error handling implemented
- [ ] Logging configured

---

**Last Updated:** 1 Juni 2026  
**Version:** 2.0.0  
**Backend Framework:** Express.js + Sequelize
