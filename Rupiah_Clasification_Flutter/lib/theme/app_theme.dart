import 'package:flutter/material.dart';

// warna aplikasi - konsisten di semua halaman
class AppColors {
  static const Color primary = Color(0xFF17B3AA);
  static const Color primaryDark = Color(0xFF071427);
  static const Color accent = Color(0xFF4ECDC4);
  static const Color background = Color(0xFFF1F1F3);
  static const Color darkBackground = Color(0xFF0A1628);
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );
}

// spasi aplikasi - konsisten spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

// radius aplikasi
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
}

// helper responsif
class ResponsiveHelper {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
  
  static bool isLandscape(BuildContext context) => screenWidth(context) > screenHeight(context);
  static bool isMobile(BuildContext context) => screenWidth(context) < 600;
  static bool isTablet(BuildContext context) => screenWidth(context) >= 600 && screenWidth(context) < 900;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 900;
  
  // ukuran responsif untuk gambar koin
  static double coinSize(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    final isLandscapeMode = isLandscape(context);
    
    if (isLandscapeMode) {
      // di landscape, gunakan tinggi sebagai acuan
      if (height < 400) return 150.0;
      if (height < 500) return 180.0;
      return 200.0;
    }
    
    if (width < 360) return 200.0;
    if (width < 600) return 280.0;
    return 320.0;
  }
  
  // ukuran responsif untuk preview kamera
  static double cameraSize(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    final isLandscapeMode = isLandscape(context);
    
    if (isLandscapeMode) {
      // di landscape, lebih kecil
      final smaller = height < width ? height : width;
      return smaller * 0.5;
    }
    
    if (width < 360) return 260.0;
    if (width < 600) return 300.0;
    return 340.0;
  }
  
  // ukuran font responsif untuk judul
  static double titleSize(BuildContext context) {
    final width = screenWidth(context);
    final isLandscapeMode = isLandscape(context);
    
    if (isLandscapeMode) {
      // di landscape, lebih kecil
      if (width < 600) return 32.0;
      if (width < 900) return 40.0;
      return 48.0;
    }
    
    if (width < 360) return 42.0;
    if (width < 600) return 56.0;
    return 64.0;
  }
}

// widget bottom navigation bar - konsisten di semua halaman
class AppBottomNav extends StatelessWidget {
  final int currentIndex; // 0: home, 1: scan, 2: history
  final Function(int) onTap;
  
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.darkBackground),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Stack(
            children: [
              // bar bawah dengan home dan history
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // tombol home
                      IconButton(
                        tooltip: 'Beranda',
                        onPressed: () => onTap(0),
                        icon: Icon(
                          Icons.home,
                          color: currentIndex == 0 ? AppColors.accent : Colors.grey,
                          size: 30,
                        ),
                      ),

                      // spasi untuk tombol tengah
                      const SizedBox(width: 70),

                      // tombol history
                      IconButton(
                        tooltip: 'History',
                        onPressed: () => onTap(2),
                        icon: Icon(
                          Icons.history,
                          color: currentIndex == 2 ? AppColors.accent : Colors.grey,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // tombol scan tengah yang menonjol
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => onTap(1),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.darkBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 5),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.darkBackground,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
