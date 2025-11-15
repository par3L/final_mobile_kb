import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../services/history_service.dart';
import '../controller/controller.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitializing = true;
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _requestPermissionsAndInitCamera();
    } else {
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _requestPermissionsAndInitCamera() async {
    try {
      // minta izin kamera
      final cameraStatus = await Permission.camera.request();
      
      if (cameraStatus.isGranted) {
        // dapatkan daftar kamera yang tersedia
        _cameras = await availableCameras();
        
        if (_cameras.isNotEmpty) {
          await _initCamera();
        } else {
          debugPrint('No cameras available');
          setState(() => _isInitializing = false);
        }
      } else {
        debugPrint('Camera permission denied');
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      debugPrint('Permission error: $e');
      setState(() => _isInitializing = false);
    }
  }

  Future<void> _initCamera() async {
    try {
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _processImage(File? imageFile, XFile? xFile) async {
    setState(() => _isProcessing = true);
    
    try {
      // Kirim gambar ke API menggunakan PredictionProvider
      final provider = Provider.of<PredictionProvider>(context, listen: false);
      
      // Gunakan XFile untuk semua platform
      Map<String, dynamic> result;
      if (xFile != null) {
        result = await provider.predictXFile(xFile);
      } else {
        throw Exception('No image file available');
      }
      
      if (mounted) {
        setState(() => _isProcessing = false);
        
        if (result['success']) {
          // tambahkan ke riwayat dengan data prediksi
          final imagePath = xFile.path;
          final imageBytes = await xFile.readAsBytes();
          HistoryService.addScan(imagePath, result['data'], imageBytes: imageBytes);
          
          // kembali ke home dengan hasil
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          _showError(result['error']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showError('Error processing image: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      // Gunakan XFile langsung untuk semua platform
      await _processImage(null, file);
    } catch (e) {
      debugPrint('error: $e');
      _showError('Failed to capture image');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        // XFile 
        await _processImage(null, picked);
      }
    } catch (e) {
      debugPrint('error: $e');
      _showError('Failed to pick image');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraSize = ResponsiveHelper.cameraSize(context);
    final isLandscape = ResponsiveHelper.isLandscape(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // gradient background
          Container(decoration: const BoxDecoration(gradient: AppColors.primaryGradient)),
          
          SafeArea(
            child: isLandscape ? _buildLandscapeLayout(cameraSize) : _buildPortraitLayout(cameraSize),
          ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout(double cameraSize) {
    return Column(
      children: [
        // header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Scan Rupiah',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // instruksi
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? 24.0 : 40.0),
          child: Text(
            'Arahkan kamera ke uang rupah',
            style: TextStyle(
              fontSize: ResponsiveHelper.isMobile(context) ? 16 : 18,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.5,
            ),
          ),
        ),

        SizedBox(height: ResponsiveHelper.isMobile(context) ? 30 : 40),

        // preview kamera
        Expanded(
          child: Center(
            child: _buildCameraPreview(cameraSize),
          ),
        ),

        SizedBox(height: ResponsiveHelper.isMobile(context) ? 30 : 40),

        // kontrol
        _buildControls(),
      ],
    );
  }

  Widget _buildLandscapeLayout(double cameraSize) {
    return Column(
      children: [
        // header kompak
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Scan Rupiah',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // konten utama horizontal
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // kiri: kamera
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Arahkan kamera ke uang rupah',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildCameraPreview(cameraSize),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // kanan: kontrol
                SizedBox(
                  width: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGalleryButton(),
                        const SizedBox(height: 20),
                        _buildCaptureButton(),
                        const SizedBox(height: 20),
                        _buildInfoButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCameraPreview(double cameraSize) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // sudut dekoratif
        SizedBox(
          width: cameraSize + 20,
          height: cameraSize + 20,
          child: Stack(
            children: [
              Positioned(top: 0, left: 0, child: _cornerDecoration()),
              Positioned(top: 0, right: 0, child: Transform.rotate(angle: 1.5708, child: _cornerDecoration())),
              Positioned(bottom: 0, left: 0, child: Transform.rotate(angle: -1.5708, child: _cornerDecoration())),
              Positioned(bottom: 0, right: 0, child: Transform.rotate(angle: 3.14159, child: _cornerDecoration())),
            ],
          ),
        ),
        
        // preview kamera
        Container(
          width: cameraSize,
          height: cameraSize,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.accent, width: 3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl - 3),
            child: _isInitializing
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  )
                : (_controller != null && _controller!.value.isInitialized)
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!.value.previewSize!.height,
                          height: _controller!.value.previewSize!.width,
                          child: CameraPreview(_controller!),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.white.withValues(alpha: 0.3)),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Kamera tidak tersedia',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Silahkan gunakan galeri',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    final isLandscape = ResponsiveHelper.isLandscape(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 20.0 : (ResponsiveHelper.isMobile(context) ? 40.0 : 60.0),
        vertical: isLandscape ? 20.0 : (ResponsiveHelper.isMobile(context) ? 24.0 : 30.0),
      ),
      child: isLandscape
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGalleryButton(),
                const SizedBox(height: 24),
                _buildCaptureButton(),
                const SizedBox(height: 24),
                _buildInfoButton(),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGalleryButton(),
                _buildCaptureButton(),
                _buildInfoButton(),
              ],
            ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _pickFromGallery,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.photo_library, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _takePicture,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 5),
        ),
        child: _isProcessing
            ? const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(AppColors.darkBackground),
                ),
              )
            : const Icon(Icons.camera_alt, size: 38, color: AppColors.darkBackground),
      ),
    );
  }

  Widget _buildInfoButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
            title: const Text('Tips'),
            content: const Text('• Pastikan uang berada di permukaan datar\n• Pastikan pencahayaan bagus\n• Tempatkan uang di tengah frame'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(Icons.info_outline, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _cornerDecoration() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.accent, width: 4),
          left: BorderSide(color: AppColors.accent, width: 4),
        ),
      ),
    );
  }
}
