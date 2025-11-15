import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/controller.dart';
import 'pages/startupScreen.dart';
import 'pages/getStartupScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PredictionProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rupiah Scanner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
          useMaterial3: true,
        ),
        home: const StartupScreen(nextPage: GetStartedScreen()),
      ),
    );
  }
}
