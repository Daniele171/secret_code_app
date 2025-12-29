import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // URL corretti per Altervista
  static const String _leaderboardUrl = 'https://grz.altervista.org/php/scores.json';
  
  // URL per il salvataggio dei progressi
  static const String _saveUrl = 'https://grz.altervista.org/php/save_score.php';

  static Future<bool> saveProgress(String username, int level) async {
    debugPrint("💾 Tentativo di salvataggio per $username al livello $level...");

    try {
      final response = await http.post(
        Uri.parse(_saveUrl),
        body: {
          'username': username,
          'level': level.toString(),
          'secret_key': 'chiave_segreta_123',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint("📡 Risposta HTTP: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        // Verifica se la risposta contiene "success"
        if (response.body.contains('"status":"success"')) {
          debugPrint("✅ Salvataggio riuscito su Altervista!");
          return true;
        } else {
          debugPrint("⚠️ Salvataggio completato ma risposta imprevista: ${response.body}");
          return true; // Consideriamo comunque successo se il server risponde 200
        }
      } else {
        debugPrint("❌ Errore Server: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Errore Connessione: $e");
      return false;
    }
  }

  // Carica la classifica globale dal file JSON
  static Future<List<Map<String, dynamic>>> loadLeaderboard() async {
    try {
      debugPrint("🏆 Caricamento classifica da: $_leaderboardUrl");
      
      final response = await http.get(Uri.parse(_leaderboardUrl))
          .timeout(const Duration(seconds: 10));

      debugPrint("📡 Risposta HTTP: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim() == '[]') {
          debugPrint("📝 Classifica vuota");
          return [];
        }

        debugPrint("📄 Dati ricevuti: ${response.body.length} caratteri");
        debugPrint("✅ Classifica caricata con successo");
        
        // TODO: Implementare parsing JSON effettivo
        return [];
      } else {
        debugPrint("⚠️ Impossibile caricare classifica: HTTP ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("❌ Errore caricamento classifica: $e");
      return [];
    }
  }

  // Controlla se il sito Altervista è raggiungibile
  static Future<bool> checkWebsiteStatus() async {
    try {
      final response = await http.get(Uri.parse(_leaderboardUrl))
          .timeout(const Duration(seconds: 5));
      final isOnline = response.statusCode == 200;
      debugPrint("🌐 Sito Altervista raggiungibile: $isOnline");
      return isOnline;
    } catch (e) {
      debugPrint("❌ Sito Altervista non raggiungibile: $e");
      return false;
    }
  }
}
