import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StartupScreen extends StatefulWidget {
  final Widget nextPage; //halaman tujuan setelah animasi selesai

  const StartupScreen({super.key, required this.nextPage});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller; //controller untuk kontrol durasi Lottie

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this); //inisialisasi controller

    //jika animasi selesai, langsung navigasi ke halaman berikutnya
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNext();
      }
    });
  }

  //navigasi dengan efek fade ke halaman tujuan
  void _goToNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(_fadeRoute(widget.nextPage));
  }

  @override
  void dispose() {
    _controller.dispose(); //controller dibersihkan
    super.dispose();
  }

  //transition route fade halus
  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, animation, __) =>
          FadeTransition(opacity: animation, child: page),
    );
  }

  @override
  Widget build(BuildContext context) {
    //hitung ukuran layar untuk responsivitas
    final size = MediaQuery.sizeOf(context);
    final shortest = size.shortestSide;
    final isTablet = shortest >= 600;

    //batas ukuran Lottie agar proporsional di HP/tablet
    final animWidth = isTablet ? size.width * 0.5 : size.width * 0.8;
    final animHeight = isTablet ? size.height * 0.5 : size.height * 0.45;

    return Scaffold(
      body: Container(
        //gradient background gelap
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              //Lottie di tengah, ukurannya dibatasi agar tidak terpotong
              Center(
                child: SizedBox(
                  width: animWidth,
                  height: animHeight,
                  child: Lottie.asset(
                    'assets/Lottie/Money.json',
                    controller: _controller, //dikendalikan oleh AnimationController
                    onLoaded: (composition) {
                      //set durasi animasi sesuai file Lottie lalu jalankan
                      _controller
                        ..duration = composition.duration
                        ..forward();
                    },
                    frameRate: FrameRate.max,
                    repeat: false, //animasi diputar sekali saja
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              //judul/tagline di bawah animasi
              Positioned(
                bottom: 60,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    Text(
                      'Rupiah Scanner',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
