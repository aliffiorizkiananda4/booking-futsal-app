# PANDUAN DEBUGGING - BOOKING FUTSAL APP

## DEBUGGING DATA LAPANGAN

### 1. Periksa Response API
Tambahkan print statement di `lib/services/field_service.dart`:

```dart
Future<List<FieldModel>> getFields() async {
  final url = Uri.parse('${ApiConfig.baseUrl}/fields');
  final headers = await _getJsonHeaders();

  try {
    final response = await http.get(url, headers: headers);
    print('=== FIELD SERVICE DEBUG ===');
    print('URL: $url');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('===========================');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> dataList = responseData['data'] ?? [];
      print('Total Fields: ${dataList.length}');
      return dataList.map((json) => FieldModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data lapangan: ${response.statusCode}');
    }
  } catch (e) {
    print('ERROR: $e');
    throw Exception('Terjadi kesalahan: $e');
  }
}
```

### 2. Periksa Parsing Model
Tambahkan print di `lib/models/field_model.dart`:

```dart
factory FieldModel.fromJson(Map<String, dynamic> json) {
  print('=== PARSING FIELD ===');
  print('Raw JSON: $json');
  
  String? imageUrl;
  String? rawImageUrl = json['image'];
  print('Raw Image URL: $rawImageUrl');
  
  if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
    if (rawImageUrl.startsWith('http://') || rawImageUrl.startsWith('https://')) {
      imageUrl = rawImageUrl.replaceAll(
        "http://localhost:3000",
        ApiConfig.baseUrl,
      ).replaceAll(
        "http://localhost:9000",
        ApiConfig.baseUrl,
      );
    } else {
      imageUrl = '${ApiConfig.baseUrl}/uploads/$rawImageUrl';
    }
  }
  
  print('Final Image URL: $imageUrl');
  print('====================');
  
  return FieldModel(
    id: json['id'],
    name: json['name'] ?? '',
    type: json['type'] ?? '',
    price: json['price'] ?? 0,
    description: json['description'],
    image: imageUrl,
  );
}
```

### 3. Periksa UI State
Tambahkan print di `lib/views/field_page.dart`:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: FutureBuilder<List<FieldModel>>(
      future: _fieldFuture,
      builder: (context, snapshot) {
        print('=== FIELD PAGE STATE ===');
        print('Connection State: ${snapshot.connectionState}');
        print('Has Error: ${snapshot.hasError}');
        print('Error: ${snapshot.error}');
        print('Has Data: ${snapshot.hasData}');
        print('Data Length: ${snapshot.data?.length ?? 0}');
        print('========================');
        
        // ... rest of the code
      },
    ),
  );
}
```

## DEBUGGING NAMA USER

### 1. Periksa Response Login
Tambahkan print di `lib/services/auth_service.dart`:

```dart
static Future<bool> login(String email, String password) async {
  final url = "${ApiConfig.baseUrl}/auth/login";
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('=== LOGIN DEBUG ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print('Response Data: $responseData');
      
      final String token =
          responseData['data']?['token'] ?? responseData['token'] ?? '';
      print('Token: $token');
      
      final String name =
          responseData['data']?['user']?['name'] ?? 
          responseData['data']?['name'] ?? 
          responseData['name'] ?? 
          'User';
      print('Name: $name');
      print('==================');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setString("name", name);
      return true;
    }
  } catch (e) {
    print('LOGIN ERROR: $e');
    return false;
  }
}
```

### 2. Periksa SharedPreferences
Tambahkan print di `lib/views/dashboard_page.dart`:

```dart
Future<void> _loadUserName() async {
  final prefs = await SharedPreferences.getInstance();
  final name = await AuthService.getName();
  
  print('=== DASHBOARD USER ===');
  print('Name from SharedPreferences: ${prefs.getString("name")}');
  print('Name from AuthService: $name');
  print('======================');
  
  setState(() {
    _name = name;
  });
}
```

## DEBUGGING PEMBAYARAN

### 1. Periksa Booking Data
Tambahkan print di `lib/services/booking_service.dart`:

```dart
Future<Map<String, dynamic>?> fetchBookings({
  int page = 1,
  int limit = 10,
}) async {
  final url = Uri.parse(
    "${ApiConfig.baseUrl}/bookings?page=$page&limit=$limit",
  );
  try {
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);
    
    print('=== BOOKING SERVICE DEBUG ===');
    print('URL: $url');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      print('Decoded: $decoded');
      
      final paginationData = decoded['data'];
      List<dynamic> rawData = paginationData['data'] ?? paginationData;
      print('Raw Data Length: ${rawData.length}');
      
      List<BookingModel> bookings = rawData
          .map((e) => BookingModel.fromJson(e))
          .toList();
      print('Bookings Length: ${bookings.length}');
      print('============================');
      
      return {
        'bookings': bookings,
        'totalPage': paginationData['totalPage'] ?? 1,
        'totalData': paginationData['total'] ?? bookings.length,
      };
    }
  } catch (e) {
    print('BOOKING ERROR: $e');
    return null;
  }
}
```

### 2. Periksa Upload Payment
Tambahkan print di `lib/services/payment_service.dart`:

```dart
Future<bool> uploadPaymentProof({
  required int bookingId,
  required File paymentProof,
}) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/payments');
  final headers = await _getAuthHeader();

  print('=== PAYMENT UPLOAD DEBUG ===');
  print('URL: $url');
  print('Booking ID: $bookingId');
  print('File Path: ${paymentProof.path}');
  print('File Exists: ${await paymentProof.exists()}');

  try {
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    request.fields['booking_id'] = bookingId.toString();

    final bytes = await paymentProof.readAsBytes();
    print('File Size: ${bytes.length} bytes');
    
    final fileName = paymentProof.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final mimeType = extension == 'png' ? 'png' : 'jpeg';
    
    print('File Name: $fileName');
    print('Extension: $extension');
    print('MIME Type: image/$mimeType');

    request.files.add(
      http.MultipartFile.fromBytes(
        'payment_proof',
        bytes,
        filename: fileName,
        contentType: MediaType('image', mimeType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('===========================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print('PAYMENT ERROR: $e');
    return false;
  }
}
```

## COMMON ISSUES & SOLUTIONS

### Issue 1: Data lapangan tidak muncul
**Kemungkinan Penyebab:**
1. Backend tidak berjalan
2. Endpoint salah
3. Token tidak valid
4. Response format tidak sesuai

**Cara Debug:**
1. Cek apakah backend berjalan di `http://localhost:9000`
2. Test endpoint dengan Postman/curl
3. Periksa log console untuk error
4. Periksa format response dari backend

**Solusi:**
```bash
# Test endpoint dengan curl
curl -X GET http://localhost:9000/fields \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Issue 2: Gambar tidak tampil
**Kemungkinan Penyebab:**
1. URL gambar salah
2. Folder uploads tidak accessible
3. CORS issue (untuk web)
4. File tidak ada di server

**Cara Debug:**
1. Print URL gambar yang dihasilkan
2. Buka URL di browser
3. Periksa folder uploads di backend
4. Periksa permission folder

**Solusi:**
- Pastikan backend serve static files dari folder uploads
- Contoh Express.js:
```javascript
app.use('/uploads', express.static('uploads'));
```

### Issue 3: Nama user tidak tampil
**Kemungkinan Penyebab:**
1. Response login format salah
2. SharedPreferences tidak tersimpan
3. Key salah saat mengambil data

**Cara Debug:**
1. Print response login
2. Print data yang disimpan ke SharedPreferences
3. Print data yang diambil dari SharedPreferences

**Solusi:**
- Pastikan backend mengirim response dengan format:
```json
{
  "data": {
    "user": {
      "name": "Administrator"
    },
    "token": "..."
  }
}
```

### Issue 4: Upload pembayaran gagal
**Kemungkinan Penyebab:**
1. Endpoint belum dibuat di backend
2. Field name tidak sesuai
3. File size terlalu besar
4. Format file tidak didukung

**Cara Debug:**
1. Print request yang dikirim
2. Periksa response dari backend
3. Test dengan Postman

**Solusi:**
- Pastikan backend endpoint `/payments` menerima:
  - Method: POST
  - Content-Type: multipart/form-data
  - Fields: booking_id, payment_proof

## TESTING CHECKLIST

### Pre-Testing
- [ ] Backend berjalan di port 9000
- [ ] Database terisi dengan data lapangan
- [ ] User admin sudah terdaftar

### Login Testing
- [ ] Login berhasil dengan kredensial yang benar
- [ ] Token tersimpan di SharedPreferences
- [ ] Nama user tersimpan di SharedPreferences
- [ ] Redirect ke dashboard setelah login

### Dashboard Testing
- [ ] Nama user tampil dengan benar
- [ ] Menu "Lapangan Futsal" ada
- [ ] Menu "Booking Sekarang" ada
- [ ] Menu "Riwayat Booking" ada
- [ ] Menu "Pembayaran" ada (BARU)
- [ ] Semua menu dapat diklik

### Field Page Testing
- [ ] Data lapangan muncul dari database
- [ ] Gambar lapangan tampil
- [ ] Nama lapangan tampil
- [ ] Tipe lapangan tampil
- [ ] Harga tampil dengan format yang benar
- [ ] Klik card membuka detail lapangan

### Payment Page Testing
- [ ] Halaman pembayaran dapat dibuka
- [ ] Daftar booking tampil
- [ ] Status booking tampil dengan benar
- [ ] Dapat memilih booking
- [ ] Dapat memilih gambar dari galeri
- [ ] Preview gambar tampil setelah dipilih
- [ ] Upload berhasil dengan notifikasi sukses
- [ ] Upload gagal dengan notifikasi error

## LOG MONITORING

### Android
```bash
# Monitor log Android
adb logcat | grep -i flutter
```

### iOS
```bash
# Monitor log iOS
xcrun simctl spawn booted log stream --predicate 'processImagePath endswith "Runner"'
```

### Web
- Buka Developer Tools (F12)
- Tab Console untuk melihat print statements
- Tab Network untuk melihat HTTP requests

## PERFORMANCE MONITORING

### Check API Response Time
```dart
Future<List<FieldModel>> getFields() async {
  final stopwatch = Stopwatch()..start();
  
  // ... API call
  
  stopwatch.stop();
  print('API Response Time: ${stopwatch.elapsedMilliseconds}ms');
}
```

### Check Image Loading Time
```dart
Image.network(
  field.image!,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) {
      print('Image loaded successfully');
      return child;
    }
    print('Loading: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
    return CircularProgressIndicator();
  },
)
```
