import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PredictionProvider with ChangeNotifier {
  File? imageFile;
  XFile? imageXFile; // untuk web support
  String? predictionMessage;
  final ImagePicker _picker = ImagePicker();
  
  // URL API Django - ganti dengan URL server Anda
  static const String apiBaseUrl = 'https://aeromarine-miki-nonsynonymously.ngrok-free.dev'; 
  // static const String apiBaseUrl = 'http://127.0.0.1:8000';  
  // static const String apiBaseUrl = 'https://pakbmobile.loca.lt'; // untuk production

  // Fungsi untuk mengambil gambar dari galeri atau kamera
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      imageXFile = pickedFile;
      if (!kIsWeb) {
        imageFile = File(pickedFile.path);
      }
      notifyListeners();
    }
  }

  // Fungsi untuk mengirim gambar ke API dan mendapatkan prediksi
  Future<void> predictImage() async {
    if (imageFile == null && imageXFile == null) return;
    if (kIsWeb) {
      await predictXFile(imageXFile!);
    } else {
      await predictXFile(imageXFile!);
    }
  }

  // Fungsi untuk prediksi dari XFile (untuk semua platform)
  Future<Map<String, dynamic>> predictXFile(XFile file) async {
    final url = Uri.parse('$apiBaseUrl/api/predict-image');
    final request = http.MultipartRequest('POST', url);
    
    // Baca bytes dari XFile
    final bytes = await file.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: file.name,
    ));

    return await _sendRequest(request);
  }

  // Legacy: Fungsi untuk prediksi dari file gambar
  Future<Map<String, dynamic>> predictFile(File file) async {
    final url = Uri.parse('$apiBaseUrl/api/predict-image');
    final request = http.MultipartRequest('POST', url);
    
    // Baca bytes dan buat multipart file
    final bytes = await file.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: 'image.jpg',
    ));

    return await _sendRequest(request);
  }

  // Fungsi helper untuk mengirim request dan handle response
  Future<Map<String, dynamic>> _sendRequest(http.MultipartRequest request) async {
    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      print('API Response status: ${response.statusCode}');
      print('API Response body: $responseData');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(responseData);
          print('Decoded data: $data');
          
          // Parse response dari Django API
          if (data['prediction'] != null) {
            // Format data untuk HistoryService
            final predictionData = _formatPredictionData(data);
            print('Formatted prediction: $predictionData');
            
            // Update state provider
            predictionMessage = predictionData['token_name'];
            notifyListeners();
            
            return {'success': true, 'data': predictionData};
          } else {
            print('No prediction in response');
            return {'success': false, 'error': 'No prediction data received'};
          }
        } catch (e) {
          print('Error parsing response: $e');
          return {'success': false, 'error': 'Error parsing response: $e'};
        }
      } else {
        return {
          'success': false,
          'error': 'Server error ${response.statusCode}: $responseData'
        };
      }
    } catch (e) {
      print('API Error: $e');
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // Format data prediksi dari API ke format yang dibutuhkan HistoryService
  Map<String, dynamic> _formatPredictionData(Map<String, dynamic> apiResponse) {
    // Mapping class index ke nama uang rupiah (HARUS sesuai urutan sorted di model!)
    // Urutan: sorted(['koin_100', 'koin_200', 'koin_500', 'koin_1000',
    //                 'kertas_1000', 'kertas_2000', 'kertas_5000', 'kertas_10000',
    //                 'kertas_20000', 'kertas_50000', 'kertas_100000'])
    final Map<int, Map<String, String>> rupiahClasses = {
      0: {'name': 'Rp 1.000 (Kertas)', 'description': 'Uang kertas seribu rupiah'},
      1: {'name': 'Rp 10.000 (Kertas)', 'description': 'Uang kertas sepuluh ribu rupiah'},
      2: {'name': 'Rp 100.000 (Kertas)', 'description': 'Uang kertas seratus ribu rupiah'},
      3: {'name': 'Rp 2.000 (Kertas)', 'description': 'Uang kertas dua ribu rupiah'},
      4: {'name': 'Rp 20.000 (Kertas)', 'description': 'Uang kertas dua puluh ribu rupiah'},
      5: {'name': 'Rp 5.000 (Kertas)', 'description': 'Uang kertas lima ribu rupiah'},
      6: {'name': 'Rp 50.000 (Kertas)', 'description': 'Uang kertas lima puluh ribu rupiah'},
      7: {'name': 'Rp 100 (Koin)', 'description': 'Uang koin seratus rupiah'},
      8: {'name': 'Rp 1.000 (Koin)', 'description': 'Uang koin seribu rupiah'},
      9: {'name': 'Rp 200 (Koin)', 'description': 'Uang koin dua ratus rupiah'},
      10: {'name': 'Rp 500 (Koin)', 'description': 'Uang koin lima ratus rupiah'},
    };

    // Ambil prediksi (asumsi list dengan 1 elemen atau single value)
    int predictedClass = 0;
    if (apiResponse['prediction'] is List && apiResponse['prediction'].isNotEmpty) {
      predictedClass = apiResponse['prediction'][0];
    } else if (apiResponse['prediction'] is int) {
      predictedClass = apiResponse['prediction'];
    }

    // Confidence score (jika ada)
    double confidence = 0.85; // default
    if (apiResponse['confidence'] != null) {
      confidence = (apiResponse['confidence'] is num) 
          ? apiResponse['confidence'].toDouble() 
          : 0.85;
    }

    // Get info dari mapping
    final info = rupiahClasses[predictedClass] ?? 
        {'name': 'Unknown', 'description': 'Tidak dikenali'};

    return {
      'token_name': info['name'],
      'year': '2024', // bisa disesuaikan jika API mengembalikan info tahun
      'confidence': confidence,
      'description': info['description'],
      'class_index': predictedClass,
    };
  }

  // Fungsi untuk menghapus gambar dan prediksi
  void clear() {
    imageFile = null;
    imageXFile = null;
    predictionMessage = null;
    notifyListeners();
  }
}
