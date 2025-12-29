import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_model.dart';
import 'game_screen.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  int highestLevelUnlocked = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestLevelUnlocked = prefs.getInt('career_level') ?? 1;
      isLoading = false;
    });
  }

  Future<void> _saveProgress(int level) async {
    final prefs = await SharedPreferences.getInstance();
    if (level > highestLevelUnlocked) {
      await prefs.setInt('career_level', level);
      setState(() {
        highestLevelUnlocked = level;
      });
    }
  }

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('career_level', 1);
    setState(() => highestLevelUnlocked = 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("MAPPA CARRIERA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        actions: [
          IconButton(onPressed: _resetProgress, icon: const Icon(Icons.refresh, size: 20, color: Colors.grey))
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: LevelsData.allLevels.length,
            itemBuilder: (ctx, index) {
              final level = LevelsData.allLevels[index];
              final bool isLocked = level.id > highestLevelUnlocked;
              final bool isCompleted = level.id < highestLevelUnlocked;
              final bool isCurrent = level.id == highestLevelUnlocked;

              return Transform.scale(
                scale: isCurrent ? 1.02 : 1.0,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: isCurrent ? 8 : (isLocked ? 0 : 4),
                  color: isLocked 
                      ? (isDark ? Colors.white10 : Colors.grey[300]) 
                      : (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: isCurrent ? const BorderSide(color: Colors.orangeAccent, width: 2) : BorderSide.none
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    leading: Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey : (isCompleted ? Colors.green : Colors.orange),
                        shape: BoxShape.circle,
                        boxShadow: [
                          // Corretto withValues
                          if(!isLocked) BoxShadow(color: (isCompleted ? Colors.green : Colors.orange).withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Center(
                        child: isLocked 
                          ? const Icon(Icons.lock, color: Colors.white)
                          : (isCompleted 
                              ? const Icon(Icons.check, color: Colors.white, size: 30)
                              : Text("${level.id}", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                      ),
                    ),
                    title: Text(
                      level.title.toUpperCase(), 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isLocked ? Colors.grey : (isDark ? Colors.white : Colors.black87)
                      )
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(level.description, style: TextStyle(color: isLocked ? Colors.grey[600] : (isDark ? Colors.grey[400] : Colors.grey[600]))),
                    ),
                    trailing: isLocked 
                      ? null 
                      : const Icon(Icons.play_circle_fill_rounded, size: 40, color: Colors.orangeAccent),
                    onTap: () {
                      if (isLocked) {
                        HapticFeedback.vibrate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          // Corretta interpolazione stringa
                          SnackBar(content: Text("Completa il Livello $highestLevelUnlocked per sbloccare questo."), duration: const Duration(seconds: 1))
                        );
                      } else {
                        _playLevel(level);
                      }
                    },
                  ),
                ),
              );
            },
          ),
    );
  }

  void _playLevel(GameLevel level) async {
    HapticFeedback.mediumImpact();
    final bool? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => GameScreen(settings: level.settings, levelId: level.id)
      )
    );

    if (result == true && level.id == highestLevelUnlocked) {
      await Future.delayed(const Duration(milliseconds: 300)); 
      _saveProgress(highestLevelUnlocked + 1);
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("LIVELLO SUCCESSIVO SBLOCCATO! 🎉"), 
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    }
  }
}