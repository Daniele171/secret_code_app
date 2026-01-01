import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  // CONFIGURAZIONE:
  
  // 1. URL per controllare la versione MINIMA richiesta (BLOCCO)
  static const String _minVersionUrl = "https://grz.altervista.org/html/min_version.txt";
  
  // 2. URL per controllare l'ULTIMA versione disponibile (AGGIORNAMENTO FACOLTATIVO)
  static const String _latestVersionUrl = "https://grz.altervista.org/html/latest_version.txt";

  // Fallback di sicurezza: se il sito è offline, usiamo questa come minima
  static const String _fallbackMinVersion = "2.0.0";

  /// Ottiene le informazioni della versione corrente dell'app
  static Future<PackageInfo> getCurrentVersion() async {
    return await PackageInfo.fromPlatform();
  }

  /// Ottiene la versione minima richiesta dal server
  static Future<String> getMinimumVersionRequired() async {
    try {
      debugPrint("🌍 Richiedo versione minima da: $_minVersionUrl");
      final response = await http.get(Uri.parse(_minVersionUrl)).timeout(const Duration(seconds: 5));
      debugPrint("📡 Risposta HTTP: ${response.statusCode} - ${response.body}");
      if (response.statusCode == 200) {
        String version = response.body.trim();
        debugPrint("✅ Versione minima ottenuta dal server: $version");
        return version;
      } else {
        debugPrint("⚠️ HTTP ${response.statusCode}, uso fallback: $_fallbackMinVersion");
        return _fallbackMinVersion;
      }
    } catch (e) {
      // Gestione specifica per CORS su web
      String errorMessage = e.toString();
      if (errorMessage.contains('XMLHttpRequest') || errorMessage.contains('CORS')) {
        debugPrint("🌐 Errore CORS su web, uso fallback: $_fallbackMinVersion");
        debugPrint("💡 Per le app web, il sito deve essere sullo stesso dominio");
      } else {
        debugPrint("⚠️ Errore nel recupero versione minima: $e");
      }
      debugPrint("🔄 Uso fallback: $_fallbackMinVersion");
      return _fallbackMinVersion;
    }
  }

  /// Verifica se la versione corrente è supportata controllando su ALTERVISTA.
  static Future<bool> isVersionSupported() async {
    try {
      final packageInfo = await getCurrentVersion();
      final currentVersion = packageInfo.version;
      
      // 1. Proviamo a scaricare la versione minima dal sito
      String minVersionFromServer = await getMinimumVersionRequired();

      debugPrint("📱 Versione App installata: $currentVersion");
      debugPrint("🔍 Confronto versioni: $currentVersion vs $minVersionFromServer");

      // 2. Confrontiamo: Se (App < ServerMinima) -> BLOCCA
      int comparisonResult = _compareVersions(currentVersion, minVersionFromServer);
      
      // Logica corretta: se comparisonResult >= 0 = OK, se < 0 = BLOCCO
      String resultDesc;
      if (comparisonResult >= 0) {
        resultDesc = "positivo = OK";
      } else {
        resultDesc = "negativo = blocco";
      }
      debugPrint("📊 Risultato confronto: $comparisonResult ($resultDesc)");

      if (comparisonResult < 0) {
        debugPrint("❌ BLOCCO ATTIVO: La versione è troppo vecchia.");
        return false; 
      }
      
      debugPrint("✅ Versione supportata.");
      return true; 
    } catch (e) {
      debugPrint("⚠️ Errore critico version service: $e");
      return true; // Per sicurezza non blocchiamo in caso di crash locale
    }
  }

  /// Controlla se c'è un aggiornamento facoltativo (icona settings)
  static Future<String?> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(_latestVersionUrl));
      if (response.statusCode == 200) {
        final latestVersionOnline = response.body.trim();
        final packageInfo = await getCurrentVersion();
        
        if (_compareVersions(latestVersionOnline, packageInfo.version) > 0) {
          return latestVersionOnline;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static int _compareVersions(String v1, String v2) {
    try {
      final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      for (int i = 0; i < 3; i++) {
        final p1 = i < parts1.length ? parts1[i] : 0;
        final p2 = i < parts2.length ? parts2[i] : 0;
        if (p1 > p2) return 1;
        if (p1 < p2) return -1;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}