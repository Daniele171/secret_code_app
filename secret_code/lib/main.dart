import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'screens/version_block_screen.dart';
import 'services/version_service.dart';

void main() {
  runApp(const SecretCodeApp());
}

class SecretCodeApp extends StatelessWidget {
  const SecretCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secret Code',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0074D9), brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardColor: Colors.white,
        canvasColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0074D9), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        canvasColor: const Color(0xFF121212),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      
      home: const IntroScreen(),
    );
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> _slides = [
    { "title": "BENVENUTO", "desc": "Sfida la tua logica.\nIndovina il Codice Segreto." },
    { "title": "L'OBIETTIVO", "desc": "Trova la combinazione di colori corretta." },
    { "title": "⚫ PIOLI NERI", "desc": "Colore Giusto nella Posizione Giusta." },
    { "title": "⚪ PIOLI BIANCHI", "desc": "Colore Giusto ma Posizione Sbagliata." },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (_currentIndex < _slides.length - 1) {
        setState(() => _currentIndex++);
      } else {
        _goToMenu();
      }
    });
  }

  void _goToMenu() async {
    _timer?.cancel();

    // Controllo versione prima di procedere
    final isSupported = await VersionService.isVersionSupported();

    if (!isSupported && mounted) {
      final currentVersion = await VersionService.getCurrentVersion();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => VersionBlockScreen(
              currentVersion: currentVersion.version,
              minimumVersion: "2.0.0",
            ),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          )
        );
      }
    } else if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MenuScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        )
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    key: ValueKey<int>(_currentIndex),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _slides[_currentIndex]['title']!,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        _slides[_currentIndex]['desc']!,
                        style: const TextStyle(fontSize: 20, color: Colors.white70, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 20,
              child: TextButton(
                onPressed: _goToMenu,
                child: const Row(
                  children: [
                    Text("SALTA", style: TextStyle(color: Colors.white)),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}