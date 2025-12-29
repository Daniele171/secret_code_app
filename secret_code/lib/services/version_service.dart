import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  // Versione minima richiesta (le versioni precedenti verranno bloccate)
  static const String _minimumRequiredVersion = "2.0.0";
  
  // URL per controllare l'ultima versione disponibile
  static const String _versionCheckUrl = "https://grz.altervista.org/html/latest_version.txt";

  // Ottiene le informazioni della versione corrente dell'app
  static Future<PackageInfo> getCurrentVersion() async {
    return await PackageInfo.fromPlatform();
  }

  // Verifica se la versione corrente è supportata
  static Future<bool> isVersionSupported() async {
    try {
      final currentVersion = await getCurrentVersion();
      final current = currentVersion.version;
      
      debugPrint("Versione corrente: $current");
      debugPrint("Versione minima richiesta: $_minimumRequiredVersion");
      
      return _compareVersions(current, _minimumRequiredVersion) >= 0;
    } catch (e) {
      debugPrint("Errore nel controllo versione: $e");
      // In caso di errore, permettiamo l'uso per evitare blocchi accidentali
      return true;
    }
  }

  // Controlla se c'è una versione più recente disponibile online
  static Future<String?> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(_versionCheckUrl));
      
      if (response.statusCode == 200) {
        final latestVersion = response.body.trim();
        final currentVersion = await getCurrentVersion();
        
        if (_compareVersions(latestVersion, currentVersion.version) > 0) {
          return latestVersion;
        }
      }
      return null;
    } catch (e) {
      debugPrint("Errore controllo aggiornamenti: $e");
      return null;
    }
  }

  // Confronta due versioni (formato: x.y.z)
  // Ritorna: 1 se v1 > v2, 0 se v1 == v2, -1 se v1 < v2
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.parse).toList();
    final parts2 = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final part1 = i < parts1.length ? parts1[i] : 0;
      final part2 = i < parts2.length ? parts2[i] : 0;
      
      if (part1 > part2) return 1;
      if (part1 < part2) return -1;
    }
    
    return 0;
  }

  // Forza una versione minima (per test o emergenze)
  static void setMinimumVersion(String version) {
    // Questo metodo potrebbe essere usato in emergenze per aggiornare rapidamente
    // la versione minima richiesta senza dover ridistribuire l'app
    debugPrint("ATTENZIONE: Versione minima forzata a $version");
  }
}
