import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // URL corretto per Altervista
  static const String _baseUrl = 'https://grz.altervista.org/html/classifica_globale.html';
  
  // URL per il salvataggio (l'endpoint API originale)
  static const String _saveUrl = 'https://grz.altervista.org/api/save_score.php';

  static Future<bool> saveProgress(String username, int level) async {
    debugPrint("Tentativo di salvataggio per $username al livello $level...");

    try {
      // Prima prova con l'URL diretto alla classifica (nel caso funzioni)
      final directResponse = await http.post(
        Uri.parse(_baseUrl),
        body: {
          'username': username,
          'level': level.toString(),
          'secret_key': 'chiave_segreta_123',
        },
      );

      if (directResponse.statusCode == 200) {
        debugPrint("✅ Salvataggio riuscito (URL diretto): ${directResponse.body}");
        return true;
      }

      // Se il primo fallisce, prova con l'endpoint API
      debugPrint("Primo tentativo fallito, provo con l'endpoint API...");
      final apiResponse = await http.post(
        Uri.parse(_saveUrl),
        body: {
          'username': username,
          'level': level.toString(),
          'secret_key': 'chiave_segreta_123',
        },
      );

      if (apiResponse.statusCode == 200) {
        debugPrint("✅ Salvataggio riuscito (API): ${apiResponse.body}");
        return true;
      } else {
        debugPrint("❌ Errore Server: ${apiResponse.statusCode} - ${apiResponse.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Errore Connessione: $e");
      return false;
    }
  }

  // Questo controlla solo se hai internet e se il sito è su
  static Future<bool> checkWebsiteStatus() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Errore controllo sito: $e");
      return false;
    }
  }
}