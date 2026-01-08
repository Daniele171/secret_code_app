import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'api_service.dart';

class ProgressSyncService {
  /// Verifica se c'è stato un aggiornamento di versione e sincronizza i progressi
  static Future<void> syncProgressOnVersionUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Ottieni la versione salvata l'ultima volta
      final lastVersion = prefs.getString('last_app_version');
      
      debugPrint("🔄 Controllo aggiornamento versione: Last=$lastVersion, Current=$currentVersion");
      
      // Se è la prima volta o c'è stato un aggiornamento
      if (lastVersion == null || lastVersion != currentVersion) {
        debugPrint("📦 Aggiornamento versione rilevato! Sincronizzazione progressi...");
        
        // Ottieni il progresso locale
        final localLevel = prefs.getInt('career_level') ?? 1;
        final username = prefs.getString('username') ?? 'unknown';
        
        debugPrint("💾 Progressi locali: $username - Livello $localLevel");
        
        // Sincronizza con il server
        bool syncSuccess = await ApiService.saveProgress(username, localLevel);
        
        if (syncSuccess) {
          debugPrint("✅ Progressi sincronizzati con successo!");
          // Salva la versione corrente
          await prefs.setString('last_app_version', currentVersion);
        } else {
          debugPrint("⚠️ Sincronizzazione fallita, ma continuo comunque");
          // Salva comunque la versione per evitare di riprovare infinitamente
          await prefs.setString('last_app_version', currentVersion);
        }
      } else {
        debugPrint("✓ Nessun aggiornamento rilevato");
      }
    } catch (e) {
      debugPrint("❌ Errore durante sincronizzazione versione: $e");
    }
  }

  /// Forza la sincronizzazione manuale dei progressi
  static Future<bool> forceSyncProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localLevel = prefs.getInt('career_level') ?? 1;
      final username = prefs.getString('username') ?? 'unknown';
      
      debugPrint("🔄 Sincronizzazione manuale: $username - Livello $localLevel");
      
      return await ApiService.saveProgress(username, localLevel);
    } catch (e) {
      debugPrint("❌ Errore sincronizzazione manuale: $e");
      return false;
    }
  }

  /// Carica i progressi dal server e aggiorna SharedPreferences
  /// Utile se i dati locali sono corrotti
  static Future<int?> loadProgressFromServer(String username) async {
    try {
      debugPrint("📥 Caricamento progressi da server per: $username");
      
      final leaderboard = await ApiService.loadLeaderboard();
      
      // Cerca l'utente nella classifica
      for (var entry in leaderboard) {
        if (entry['username'] == username) {
          final level = entry['level'];
          debugPrint("✅ Progresso trovato su server: Livello $level");
          
          // Aggiorna SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('career_level', level);
          
          return level;
        }
      }
      
      debugPrint("⚠️ Utente non trovato nella classifica del server");
      return null;
    } catch (e) {
      debugPrint("❌ Errore caricamento progressi da server: $e");
      return null;
    }
  }

  /// Backup locale dei progressi in caso di emergenza
  static Future<void> backupProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final level = prefs.getInt('career_level') ?? 1;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Salva un backup con timestamp
      await prefs.setInt('backup_career_level_$timestamp', level);
      
      // Mantieni solo gli ultimi 5 backup
      final keys = prefs.getKeys();
      final backupKeys = keys.where((k) => k.startsWith('backup_career_level_')).toList();
      if (backupKeys.length > 5) {
        backupKeys.sort();
        for (int i = 0; i < backupKeys.length - 5; i++) {
          await prefs.remove(backupKeys[i]);
        }
      }
      
      debugPrint("💾 Backup progressi creato: Livello $level");
    } catch (e) {
      debugPrint("❌ Errore backup progressi: $e");
    }
  }

  /// Ripristina un backup precedente
  static Future<bool> restoreBackup(int timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupKey = 'backup_career_level_$timestamp';
      
      if (!prefs.containsKey(backupKey)) {
        debugPrint("❌ Backup non trovato: $backupKey");
        return false;
      }
      
      final level = prefs.getInt(backupKey)!;
      await prefs.setInt('career_level', level);
      
      debugPrint("✅ Backup ripristinato: Livello $level");
      return true;
    } catch (e) {
      debugPrint("❌ Errore ripristino backup: $e");
      return false;
    }
  }

  /// Lista tutti i backup disponibili
  static Future<List<Map<String, dynamic>>> listBackups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final backupKeys = keys.where((k) => k.startsWith('backup_career_level_')).toList();
      
      backupKeys.sort((a, b) => b.compareTo(a)); // Ordina decrescente (più recenti per primi)
      
      return backupKeys.map((key) {
        final timestamp = int.parse(key.replaceFirst('backup_career_level_', ''));
        final level = prefs.getInt(key)!;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        
        return {
          'timestamp': timestamp,
          'level': level,
          'date': date.toString(),
          'key': key,
        };
      }).toList();
    } catch (e) {
      debugPrint("❌ Errore lettura backup: $e");
      return [];
    }
  }
}
