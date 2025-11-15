import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'getStartupScreen.dart';
import 'scanScreen.dart';
import 'historyScreen.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showDrawer = false;

  void _handleNavigation(int index) async {
    if (index == 0) {
      // sudah di home, ke getstarted
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      );
    } else if (index == 1) {
      // ke scan
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScanScreen()),
      );
      
      // jika ada hasil scan baru, tampilkan drawer
      if (result == true && mounted) {
        setState(() {
          _showDrawer = true;
        });
        
        // tutup drawer setelah beberapa detik
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showDrawer = false;
            });
          }
        });
      }
    } else if (index == 2) {
      // ke history
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HistoryScreen()),
      );
      // refresh untuk update drawer jika ada perubahan
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestScan = HistoryService.latestScan;
    final coinSize = ResponsiveHelper.coinSize(context);
    final titleSize = ResponsiveHelper.titleSize(context);
    final showArticle = _showDrawer && latestScan != null;
    final isLandscape = ResponsiveHelper.isLandscape(context);

    return Scaffold(
      body: Stack(
        children: [
          // gradient background
          Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          ),
          
          // konten utama
          SafeArea(
            child: isLandscape ? _buildLandscapeLayout(coinSize, titleSize, showArticle, latestScan) : _buildPortraitLayout(coinSize, titleSize, showArticle, latestScan),
          ),
        ],
      ),

      // bottom navigation bar
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: _handleNavigation,
      ),
    );
  }

  Widget _buildPortraitLayout(double coinSize, double titleSize, bool showArticle, ScanResult? latestScan) {
    return Column(
      children: [
        // bagian hero layar penuh dengan koin
        Expanded(
          child: Stack(
            children: [
              // lingkaran dekoratif di background
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -70,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              
              // konten utama
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // hero image
                      Container(
                        width: coinSize,
                        height: coinSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/coin.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.isMobile(context) ? 32 : 40),
                      
                      // judul
                      Text(
                        'Scan Your',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize * 0.75,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Money',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // subtitle
                      Text(
                        'Identifikasi Uang Anda via Scan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // area artikel/preview (drawer kondisional)
        if (showArticle)
          Container(
            height: 280,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F1F3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: _buildResultDrawer(latestScan!),
          ),
      ],
    );
  }

  Widget _buildLandscapeLayout(double coinSize, double titleSize, bool showArticle, ScanResult? latestScan) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // bagian kiri: hero dan judul
              Expanded(
                flex: showArticle ? 1 : 1,
                child: Stack(
                  children: [
                    // lingkaran dekoratif
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // hero image
                            Container(
                              width: coinSize,
                              height: coinSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 3,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/coin.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // judul
                            Text(
                              'Scan Your',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: titleSize * 0.75,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'Money',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Identifikasi Uang Anda via Scan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // bagian kanan: hasil scan (jika ada)
              if (showArticle)
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F1F3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _buildResultDrawer(latestScan!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultDrawer(ScanResult latestScan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Hasil Scan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() {
                  _showDrawer = false;
                  HistoryService.clearLatestScan();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // gambar koin
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb && latestScan.imageBytes != null
                      ? Image.memory(
                          latestScan.imageBytes!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                      : !kIsWeb
                          ? Image.file(
                              File(latestScan.imagePath),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: Icon(Icons.image, size: 40, color: Colors.grey[600]),
                            ),
                ),
                const SizedBox(width: 16),
                // detail prediksi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestScan.coinName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Akurasi: ${(latestScan.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 14, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        latestScan.description,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}