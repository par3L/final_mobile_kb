# Aplikasi Klasifikasi Uang Rupiah

## Deskripsi Proyek

Aplikasi 'Rupiah Scanner' adalah sebuah sistem berbasis kecerdasan buatan yang dirancang untuk mengidentifikasi dan mengklasifikasikan mata uang Rupiah Indonesia melalui analisis gambar. Proyek ini dikembangkan sebagai pemenuhan Proyek Akhir Praktikum Pemrograman Piranti Bergerak dan Kecerdasan Buatan.

Aplikasi ini menggunakan model berbasis Convolutional Neural Network (CNN) yang dilatih untuk mengenali 11 kelas denominasi uang rupiah, meliputi 7 jenis uang kertas (Rp 1.000, Rp 2.000, Rp 5.000, Rp 10.000, Rp 20.000, Rp 50.000, dan Rp 100.000) serta 4 jenis uang koin (Rp 100, Rp 200, Rp 500, dan Rp 1.000).

## Fitur Utama

### 1. Klasifikasi Real-time
- Pengambilan gambar menggunakan kamera perangkat
- Pemilihan gambar dari galeri
- Prediksi denominasi uang 
- Tampilan confidence score untuk setiap prediksi

### 2. Riwayat Scan
- Penyimpanan hasil scan dalam aplikasi
- Visualisasi gambar yang telah di-scan
- Detail informasi prediksi untuk setiap scan
- Kemampuan menghapus riwayat scan

## Arsitektur Sistem

### Struktur Proyek

```
final_mobile_AI/
├── notebook/
│   ├── model/
│       └── rupiah_classification.ipynb    # Notebook training model
│   
├── Synapse/                               # Backend API (Django)
│   ├── api/
│   │   ├── model/
│   │   │   ├── inference.py              # Logic prediksi
│   │   │   └── garden/                   # Direktori model
│   │   ├── views.py                      # API endpoints
│   │   └── urls.py
│   ├── synapse/
│   │   └── settings.py
│   └── manage.py
├── Rupiah_Clasification_Flutter/         # Aplikasi Mobile (Flutter)
│   ├── lib/
│   │   ├── controller/
│   │   │   └── controller.dart           # State management
│   │   ├── pages/
│   │   │   ├── homeScreen.dart
│   │   │   ├── scanScreen.dart
│   │   │   └── historyScreen.dart
│   │   ├── services/
│   │   │   └── history_service.dart
│   │   └── main.dart
│   └── pubspec.yaml
```

### Teknologi yang Digunakan

#### Backend (API Server)
- **Framework**: Django 5.1.2
- **Deep Learning**: TensorFlow 2.10.0, Keras
- **Image Processing**: Pillow, NumPy
- **Server**: Django Development Server

#### Frontend (Mobile Application)
- **Framework**: Flutter 3.9.2
- **State Management**: Provider
- **HTTP Client**: http package
- **Image Handling**: image_picker, camera
- **Platform Support**: Android, iOS, Web, Windows, macOS, Linux

#### Machine Learning
- **Architecture**: Sequential CNN
- **Input Shape**: 128x128x3 (RGB)
- **Output Classes**: 11 classes
- **Optimization**: Adam optimizer
- **Regularization**: L2 regularization, Dropout

## Cara Instalasi dan Menjalankan

### Prasyarat

1. **Python 3.10.8** atau lebih tinggi
2. **Flutter SDK 3.9.2** atau lebih tinggi
3. **Conda** (untuk environment management)
4. **Git** (untuk cloning repository)

### A. Setup Backend API

#### 1. Clone Repository

```bash
git clone https://github.com/Praktikum-Informatika-UNMUL/Synapse.git
cd final_mobile_AI
```

#### 2. Buat dan Aktifkan Conda Environment

```bash
cd Synapse
conda env create -n rupiah-api -f environment.yml
conda activate rupiah-api
```

Jika terjadi error saat membuat environment, lakukan:

```bash
conda clean --all
conda env create -n rupiah-api -f environment.yml
```

#### 3. Jalankan Server Django

```bash
python manage.py runserver 0.0.0.0:8000
```

Server akan berjalan di `http://localhost:8000`

**Catatan**: Gunakan `0.0.0.0:8000` agar server dapat diakses dari perangkat lain di jaringan lokal.

#### 4. Testing API dengan cURL

```bash
# Test endpoint predict-image
curl -X POST -F "image=@path/to/image.jpg" http://localhost:8000/api/predict-image
```

Response yang diharapkan:
```json
{
  "message": "Image received",
  "prediction": [2],
  "confidence": 0.9999
}
```

### B. Setup Aplikasi Mobile Flutter

#### 1. Install Dependencies

```bash
cd Rupiah_Clasification_Flutter
flutter pub get
```

#### 2. Konfigurasi API URL

Edit file `lib/controller/controller.dart`:

```dart
// Untuk testing lokal
static const String apiBaseUrl = 'http://YOUR_IP_ADDRESS:8000';

// Untuk production dengan ngrok
static const String apiBaseUrl = 'https://your-ngrok-url.ngrok-free.dev';
```

**Cara mendapatkan IP Address lokal**:

Windows:
```bash
ipconfig
```

Linux/Mac:
```bash
ifconfig
```

#### 3. Jalankan Aplikasi

**Android/iOS:**
```bash
flutter run
```

**Windows:**
```bash
flutter run -d windows
```

**Web:**
```bash
flutter run -d chrome
```

**Untuk build release:**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Windows
flutter build windows --release
```

### C. Setup dengan Ngrok (Optional untuk Remote Access)

Jika ingin mengakses API dari perangkat mobile yang tidak dalam jaringan yang sama:

#### 1. Install Ngrok

Download dari [ngrok.com](https://ngrok.com/download)

#### 2. Jalankan Ngrok

```bash
ngrok http 8000
```

#### 3. Update API URL di Flutter

Gunakan URL yang diberikan ngrok (contoh: `https://xxxx-xxxx.ngrok-free.dev`)

## Cara Menggunakan Aplikasi

### 1. Memulai Aplikasi

- Buka aplikasi Rupiah Classification
- Tampilan awal menampilkan splash screen dengan animasi
- Tap "Get Started" untuk masuk ke halaman utama

### 2. Melakukan Scan Uang

#### Menggunakan Kamera:
1. Tap tombol scan (tengah) di bottom navigation
2. Izinkan akses kamera jika diminta
3. Arahkan kamera ke uang rupiah yang ingin diidentifikasi
4. Pastikan pencahayaan cukup dan uang berada di tengah frame
5. Tap tombol capture (lingkaran putih besar)
6. Tunggu proses prediksi
7. Hasil akan ditampilkan di halaman home

#### Menggunakan Galeri:
1. Tap tombol scan di bottom navigation
2. Tap icon galeri (kiri bawah)
3. Pilih gambar uang dari galeri
4. Tunggu proses prediksi
5. Hasil akan ditampilkan di halaman home

### 3. Melihat Riwayat Scan

1. Tap icon history (kanan) di bottom navigation
2. Scroll untuk melihat semua riwayat scan
3. Tap pada item untuk melihat detail lengkap
4. Swipe atau tap icon delete untuk menghapus riwayat

### 4. Membaca Hasil Prediksi

Setiap hasil prediksi menampilkan:
- **Denominasi**: Nilai uang (contoh: Rp 100.000 Kertas)
- **Confidence**: Tingkat keyakinan model (0-100%)
- **Deskripsi**: Informasi tambahan tentang uang
- **Waktu Scan**: Tanggal dan jam scan dilakukan

## API Documentation

### Endpoints

#### 1. POST /api/predict-image

Endpoint untuk klasifikasi gambar uang rupiah.

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: 
  - image (file): File gambar uang rupiah

**Response:**
```json
{
  "message": "Image received",
  "prediction": [6],
  "confidence": 0.9987
}
```

**Class Index Mapping:**
- 0: kertas_1000 (Rp 1.000 Kertas)
- 1: kertas_10000 (Rp 10.000 Kertas)
- 2: kertas_100000 (Rp 100.000 Kertas)
- 3: kertas_2000 (Rp 2.000 Kertas)
- 4: kertas_20000 (Rp 20.000 Kertas)
- 5: kertas_5000 (Rp 5.000 Kertas)
- 6: kertas_50000 (Rp 50.000 Kertas)
- 7: koin_100 (Rp 100 Koin)
- 8: koin_1000 (Rp 1.000 Koin)
- 9: koin_200 (Rp 200 Koin)
- 10: koin_500 (Rp 500 Koin)

**Error Responses:**
```json
{
  "error": "No image provided"
}
```

#### 2. POST /api/predict

Endpoint untuk prediksi data tabular (contoh: iris dataset).

**Request:**
```json
{
  "data": [6.4, 2.9, 4.3, 1.3]
}
```

**Response:**
```json
{
  "message": "Data received",
  "prediction": "virginica"
}
```

## Model Architecture

### Spesifikasi Model

- **Model Type**: Sequential CNN
- **Input Shape**: (128, 128, 3)
- **Total Parameters**: ~2.5M parameters
- **Training Dataset**: ~3000 images
- **Validation Dataset**: ~400 images
- **Test Dataset**: ~400 images

### Layer Architecture

```
Input Layer: 128x128x3
    ↓
Conv2D(32) + MaxPooling2D
    ↓
Conv2D(64) + MaxPooling2D
    ↓
Conv2D(128) + MaxPooling2D
    ↓
Flatten
    ↓
Dense(128) + Dropout(0.5)
    ↓
Output: Dense(11) + Softmax
```

### Training Configuration

- **Optimizer**: Adam (learning_rate=0.001)
- **Loss Function**: Categorical Crossentropy
- **Metrics**: Accuracy
- **Batch Size**: 32
- **Epochs**: 50 (with early stopping)
- **Data Augmentation**: Yes
  - Rotation: 20 degrees
  - Width/Height Shift: 0.2
  - Zoom: 0.2
  - Horizontal Flip: Yes

### Model Performance

- **Training Accuracy**: ~98%
- **Validation Accuracy**: ~95%
- **Test Accuracy**: ~94%

## Troubleshooting

### Masalah Umum dan Solusi

#### 1. Server Django Tidak Dapat Diakses dari Mobile

**Masalah**: Connection error saat upload gambar dari app.

**Solusi**:
- Pastikan server berjalan dengan `0.0.0.0:8000` bukan `127.0.0.1:8000`
- Periksa firewall Windows/Linux tidak memblokir port 8000
- Pastikan perangkat mobile dan komputer dalam jaringan yang sama
- Update IP address di `controller.dart`

#### 2. Model Prediction Tidak Akurat

**Masalah**: Hasil prediksi salah atau confidence rendah.

**Solusi**:
- Pastikan gambar memiliki pencahayaan yang baik
- Uang harus berada di tengah frame
- Hindari gambar blur atau terlalu jauh

#### 4. Conda Environment Creation Failed

**Masalah**: `InvalidArchiveError` saat membuat environment.

**Solusi**:
```bash
conda clean --all
# Hapus package yang corrupt
Remove-Item -Path "C:\Users\...\conda\pkgs\package-name*" -Recurse -Force
conda env create -n rupiah-api -f environment.yml
```

## Link Google Drive

**Dataset dan Model Terlatih**:
[Google Drive Link - Rupiah Classification App, Model & Dataset]
(https://drive.google.com/drive/folders/your-folder-id)

Konten folder:
- Built App
- Dataset training, validation, dan test
- Model terlatih (.h5 dan .keras format)
- Dokumentasi training
- Sample images untuk testing

## Kontributor
**[Kelompok 7]**
Chaelse Dengen   (2309106003)
Rafif Zahran     (2309106029)
Christian Farrel (2309106032)
Muhammad Jahron  (2309106037)

## Lisensi

Proyek ini dikembangkan untuk keperluan akademis dan pembelajaran.

## Referensi

1. TensorFlow Documentation: https://www.tensorflow.org/
2. Flutter Documentation: https://flutter.dev/
3. Django Documentation: https://www.djangoproject.com/
4. Keras API Reference: https://keras.io/

---

**Catatan**: Untuk pertanyaan atau masalah lebih lanjut, silakan hubungi tim pengembang atau buat issue di repository GitHub.
