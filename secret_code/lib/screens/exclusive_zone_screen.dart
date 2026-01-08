import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_settings.dart';
import 'game_screen.dart';

class ExclusiveZoneScreen extends StatefulWidget {
  const ExclusiveZoneScreen({super.key});

  @override
  State<ExclusiveZoneScreen> createState() => _ExclusiveZoneScreenState();
}

class _ExclusiveZoneScreenState extends State<ExclusiveZoneScreen> {
  int _masterPoints = 0;
  String _rankTitle = "NEOFITA";
  int _matchesWon = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _masterPoints = prefs.getInt('master_points') ?? 0;
      _matchesWon = prefs.getInt('master_wins') ?? 0;
      _updateRank();
      _isLoading = false;
    });
  }

  void _updateRank() {
    if (_masterPoints >= 10000) {
      _rankTitle = "LEGGENDA";
    } else if (_masterPoints >= 1000) {
      _rankTitle = "GRAN MAESTRO";
    } else if (_masterPoints >= 250) {
      _rankTitle = "MAESTRO";
    } else if (_masterPoints >= 75) {
      _rankTitle = "ESPERTO";
    } else {
      _rankTitle = "NEOFITA";
    }
  }

  Future<void> _startMasterChallenge(BuildContext context) async {
    HapticFeedback.heavyImpact();
    // Genera impostazioni difficili casuali
    final random = Random();
    
    // Codice tra 5 e 6
    final codeLength = 5 + random.nextInt(2); 
    
    // Tentativi ridotti: Tra 8 e 10
    final maxRows = 8 + random.nextInt(3);
    
    // Duplicati sempre attivi per la difficoltà
    const allowDuplicates = true;
    
    final settings = GameSettings(
      codeLength: codeLength,
      maxRows: maxRows,
      allowDuplicates: allowDuplicates,
      numberOfColors: 6, // Sempre 6 colori
    );

    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(
          settings: settings,
          levelId: 999, // ID speciale per master
        ),
      ),
    );

    if (result != null) {
      _processGameResult(result);
    }
  }

  Future<void> _processGameResult(bool won) async {
    final prefs = await SharedPreferences.getInstance();
    int pointsChange = 0;

    if (won) {
      pointsChange = 50;
      _matchesWon++;
      await prefs.setInt('master_wins', _matchesWon);
    } else {
      pointsChange = -20;
    }

    _masterPoints += pointsChange;
    // Evita punti negativi
    if (_masterPoints < 0) _masterPoints = 0;
    
    await prefs.setInt('master_points', _masterPoints);
    
    setState(() {
      _updateRank();
    });

    if (mounted) {
      if (won) {
         _showResultDialog(context, "VITTORIA!", "+$pointsChange Punti Maestro", Colors.green, Icons.emoji_events);
      } else {
         _showResultDialog(context, "SCONFITTA", "$pointsChange Punti Maestro", Colors.red, Icons.sentiment_dissatisfied);
      }
    }
  }

  void _showResultDialog(BuildContext context, String title, String sub, Color color, IconData icon) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: color, width: 2)),
        title: Column(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("OK", style: TextStyle(color: Colors.white))
          )
        ],
      )
    );
  }

  // Helper per calcolare range e prossimo obiettivo
  // Ritorna (min, max, nextRankName)
  (int, int, String) _getNextRankTarget() {
    if (_masterPoints >= 10000) return (10000, 10000, "MAX");
    if (_masterPoints >= 1000) return (1000, 10000, "LEGGENDA");
    if (_masterPoints >= 250) return (250, 1000, "GRAN MAESTRO");
    if (_masterPoints >= 75) return (75, 250, "MAESTRO");
    return (0, 75, "ESPERTO");
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF1A1A1A), body: Center(child: CircularProgressIndicator(color: Colors.amber)));

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      appBar: AppBar(
        title: const Text("ZONA MAESTRI", style: TextStyle(color: Colors.amberAccent, letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.amberAccent),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRankBadge(),
              const SizedBox(height: 30),
               Text(
                "$_masterPoints PT",
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.amber, blurRadius: 15)],
                ),
              ),
              Text(
                _rankTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Vittorie Totali: $_matchesWon",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              
              _buildLevelMap(),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () => _startMasterChallenge(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.black,
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flash_on, size: 30),
                      SizedBox(width: 15),
                      Text("SFIDA RANGO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Vinci per guadagnare punti rango.\nLe sconfitte ti penalizzano.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelMap() {
    final (min, max, nextRank) = _getNextRankTarget();
    final bool isMax = _masterPoints >= 10000;
    
    // Calcolo progresso relativo al livello
    // Esempio: ho 150 pt. Sono tra 75 e 250.
    // Progresso relativo = (150 - 75) / (250 - 75) = 75 / 175 = 0.42
    
    double progress = 1.0;
    if (!isMax) {
      progress = (_masterPoints - min) / (max - min);
      if (progress < 0) progress = 0;
      if (progress > 1) progress = 1;
    }
    
    final int percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_rankTitle, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(isMax ? "MASSIMO" : nextRank, style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              // Sfondo track
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Fill progressivo
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 12,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.amber[800]!, Colors.amberAccent]),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 8)]
                    ),
                  );
                }
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              isMax ? "GRADO MASSIMO RAGGIUNTO" : "$percentage% al prossimo rango",
              style: const TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge() {
    IconData icon;
    Color color;
    
    if (_masterPoints >= 1000) { icon = Icons.diamond; color = Colors.cyanAccent; }
    else if (_masterPoints >= 250) { icon = Icons.workspace_premium; color = Colors.amber; }
    else if (_masterPoints >= 75) { icon = Icons.verified; color = Colors.purpleAccent; }
    else { icon = Icons.shield; color = Colors.grey; }

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 4),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 5)
        ]
      ),
      child: Icon(icon, size: 80, color: color),
    );
  }
}
