import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  // --- CONFIGURAZIONE TEST ---
  // Per TESTARE IL BLOCCO: Imposta questa versione a "9.9.9"
  // Per il RILASCIO: Impostala alla versione minima reale (es. "2.0.0")
  static const String _minimumRequiredVersion = "2.0.0";
  
  // URL del file remoto per controllo aggiornamenti (opzionale se usi solo il blocco locale)
  static const String _versionCheckUrl = "https://grz.altervista.org/html/latest_version.txt";

  static Future<PackageInfo> getCurrentVersion() async {
    return await PackageInfo.fromPlatform();
  }

  static Future<bool> isVersionSupported() async {
    try {
      final packageInfo = await getCurrentVersion();
      final currentVersion = packageInfo.version;
      
      debugPrint("🔍 Versione App: $currentVersion");
      debugPrint("🔒 Minima Richiesta: $_minimumRequiredVersion");
      
      // Controllo: Se la versione corrente è minore della minima richiesta -> BLOCCA
      if (_compareVersions(currentVersion, _minimumRequiredVersion) < 0) {
        debugPrint("❌ BLOCCO ATTIVO: La versione è obsoleta.");
        return false; // Non supportata -> Mostra schermata di blocco
      }
      
      debugPrint("✅ Versione OK.");
      return true; // Supportata -> Vai al menu
    } catch (e) {
      debugPrint("⚠️ Errore controllo versione: $e");
      return true; // In caso di errore, lasciamo passare per non bloccare utenti a caso
    }
  }

  static Future<String?> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(_versionCheckUrl));
      if (response.statusCode == 200) {
        final latestVersion = response.body.trim();
        final packageInfo = await getCurrentVersion();
        if (_compareVersions(latestVersion, packageInfo.version) > 0) {
          return latestVersion;
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