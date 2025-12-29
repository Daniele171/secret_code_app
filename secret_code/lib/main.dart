import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0074D9), brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
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
    { "title": "SALVATAGGIO AUTO", "desc": "Giochi senza login.\nI tuoi progressi sono salvati online." },
    { "title": "⚫ PIOLI NERI", "desc": "Colore Giusto nella Posizione Giusta." },
  ];

  @override
  void initState() {
    super.initState();
    _initializeUser(); // Genera ID ospite se non esiste
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (_currentIndex < _slides.length - 1) {
        setState(() => _currentIndex++);
      } else {
        _checkVersionAndGo();
      }
    });
  }

  // Crea un ID univoco per questo dispositivo se non c'è login
  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('username')) {
      // Creiamo un ID ospite tipo "guest_abc123"
      String guestId = "guest_${const Uuid().v4().substring(0, 8)}";
      await prefs.setString('username', guestId);
      debugPrint("🆕 Nuovo utente ospite creato: $guestId");
    } else {
      debugPrint("👤 Utente rilevato: ${prefs.getString('username')}");
    }
  }

  void _checkVersionAndGo() async {
    _timer?.cancel();

    // 1. Controllo Versione
    final isSupported = await VersionService.isVersionSupported();

    if (!isSupported && mounted) {
      // CASO BLOCCO: Versione obsoleta
      final currentVersion = await VersionService.getCurrentVersion();
      final minimumVersion = await VersionService.getMinimumVersionRequired();
      
      debugPrint("🔒 Blocco attivo - App: ${currentVersion.version}, Minima: $minimumVersion");
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VersionBlockScreen(
          currentVersion: currentVersion.version,
          minimumVersion: minimumVersion,
        ))
      );
    } else if (mounted) {
      // CASO OK: Vai al menu
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey<int>(_currentIndex),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_slides[_currentIndex]['title']!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Text(_slides[_currentIndex]['desc']!, style: const TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}