# 🧪 Guida Completa Test e Troubleshooting

## 1️⃣ Come Testare il Sistema

### Test 1: Sincronizzazione Automatica su Aggiornamento
```
Scenario: Simulare cambio versione
────────────────────────────────────
1. App v1.0 - Completa livello 5
   └─ career_level = 5 (SharedPreferences)
   
2. Modifica pubspec.yaml:
   version: 1.0.0+1  →  version: 2.0.0+1
   
3. Rebuild app:
   flutter clean && flutter run
   
4. Verifica Log Console:
   ✓ Cerca: "Aggiornamento versione rilevato"
   ✓ Cerca: "Progressi sincronizzati con successo"
   ✓ Cerca: "Versione minima ottenuta dal server"
   
5. Verifica Funzionalità:
   └─ career_level rimane 5 ✅
   └─ Nessun popup/errore ✅
   └─ Classifica mostra il tuo progresso ✅
```

**Debug Print Attesi:**
```
🔄 Controllo aggiornamento versione: Last=1.0.0, Current=2.0.0
📦 Aggiornamento versione rilevato! Sincronizzazione progressi...
💾 Progressi locali: guest_xyz - Livello 5
✅ Progressi sincronizzati con successo!
```

---

### Test 2: Backup Automatico ad Ogni Sblocco
```
Scenario: Sbloccare livelli e verificare backup
───────────────────────────────────────────────
1. Completa il livello 1 (carriera)
   └─ Vinci la partita
   
2. Verifica Log:
   ✓ Cerca: "Backup progressi creato: Livello 2"
   ✓ Cerca: "Progresso salvato online"
   
3. Completa il livello 2
   └─ Vinci la partita
   
4. Verifica Log:
   ✓ Cerca: "Backup progressi creato: Livello 3"
   
5. Ripeti per 3-5 livelli
```

**Debug Print Attesi:**
```
🔓 Livello 2 sbloccato localmente
💾 Backup progressi creato: Livello 2
☁️ Salvataggio automatico CARRIERA per utente: guest_xyz al livello 1
✅ Salvataggio riuscito su Altervista!
```

---

### Test 3: Ripristino Backup
```
Scenario: Testare il ripristino di un backup precedente
──────────────────────────────────────────────────────
1. Completa fino a livello 7 (crea vari backup)
   
2. Apri DevTools → Console Flutter
   
3. Esegui questo codice:
   ```dart
   import 'package:secret_code/services/progress_sync_service.dart';
   
   // Lista backup
   var backups = await ProgressSyncService.listBackups();
   backups.forEach((b) => print('${b['date']} - Livello ${b['level']}'));
   
   // Ripristina il primo backup (più vecchio)
   await ProgressSyncService.restoreBackup(backups.last['timestamp']);
   ```
   
4. Verifica:
   └─ career_level tornato al livello precedente ✅
   └─ Senza popup/errori ✅
```

---

### Test 4: Carica Progressi da Server
```
Scenario: Recuperare progressi da Altervista quando locali sono corrotti
────────────────────────────────────────────────────────────────────
1. Cancella manually career_level da SharedPreferences
   
2. Esegui questo codice:
   ```dart
   import 'package:secret_code/services/progress_sync_service.dart';
   
   // Carica da server
   int? level = await ProgressSyncService.loadProgressFromServer('guest_xyz');
   print('Livello caricato: $level');
   ```
   
3. Verifica:
   └─ career_level ripristinato dal server ✅
```

---

### Test 5: Offline Mode
```
Scenario: Verificare funzionamento senza connessione
──────────────────────────────────────────────────
1. Disabilita WiFi/dati mobili
   
2. Avvia app
   
3. Verifica Log:
   ✓ Cerca: "Errore nel recupero versione minima"
   ✓ Cerca: "uso fallback"
   └─ L'app continua a funzionare ✅
   
4. Gioca offline
   
5. Completa livelli
   └─ career_level aggiornato localmente ✅
   └─ Backup creato ✅
   
6. Riabilita connessione
   
7. Avvia app di nuovo
   └─ Sincronizzazione avviene automaticamente ✅
```

---

## 2️⃣ Debugging e Troubleshooting

### 🔍 Come Leggere i Log

**Aprire la console:**
```bash
# Se usi Android Studio
flutter logs | grep "SECRET\|Sincronizzazione\|Salvataggio"

# Se usi VS Code
flutter run --verbose
```

**Filtrare per parole chiave:**
```bash
flutter logs | grep -E "(🔄|📦|💾|✅|❌|⚠️|🌐)"
```

---

### ❓ Problemi Comuni e Soluzioni

#### Problema 1: "Progressi non sincronizzati dopo aggiornamento"
```
Diagnosi:
  1. Verifica di aver effettivamente aggiornato pubspec.yaml
  2. Verifica che il server Altervista sia raggiungibile
  3. Controlla i log per "Errore"
  
Soluzione:
  // Forza sincronizzazione manuale
  bool success = await ProgressSyncService.forceSyncProgress();
  if (success) print("Sincronizzato ✅");
```

#### Problema 2: "Vedo versione offline ma dovrebbe bloccare"
```
Diagnosi:
  1. Verifica che min_version.txt esista su Altervista
  2. Controlla che il valore sia corretto (es: "2.0.0")
  3. Verifica la versione app nel pubspec.yaml
  
Debugging:
  final minVersion = await VersionService.getMinimumVersionRequired();
  final currentVersion = await VersionService.getCurrentVersion();
  print("Min: $minVersion, Current: ${currentVersion.version}");
```

#### Problema 3: "SharedPreferences non persiste dopo reinstall"
```
Diagnosi:
  Android: I dati vengono cancellati quando disinstalli l'app
  
Soluzione:
  1. Il backup su Altervista risolve questo
  2. Usa ProgressSyncService.loadProgressFromServer(username)
  3. Per testing, non disinstallare, usa flutter run
```

#### Problema 4: "Troppi backup, spazio limitato"
```
Attualmente: Massimo 5 backup in SharedPreferences
Potrebbe essere migliorato in futuro con:
  - Database SQLite locale
  - Cloud Firestore
  - Rimozione automatica backup >30 giorni
```

---

## 3️⃣ Comandi Utili per Sviluppo

### Reset Completo (Per Testing)
```bash
# Cancella dati app (Android emulator)
flutter clean
adb shell pm clear com.example.secret_code
flutter run

# Cancella dati app (iOS simulator)
flutter clean
xcrun simctl erase all
flutter run
```

### Testa Connessione Altervista
```bash
# Verifica raggiungibilità
curl -I https://grz.altervista.org/html/min_version.txt

# Controlla il contenuto
curl https://grz.altervista.org/html/min_version.txt

# Verifica salvataggio progressi
curl -X POST https://grz.altervista.org/php/save_score.php \
  -d "username=test&level=5&secret_key=chiave_segreta_123"
```

### Hot Reload con Nuova Versione
```bash
# 1. Modifica pubspec.yaml (version: X.Y.Z)
# 2. Non puoi usare hot reload (build.gradle non viene reletto)
# 3. Usa questo:

flutter run --no-fast-start  # Rebuild completo
```

---

## 4️⃣ Metriche da Monitorare

### Cosa Misurare per Verificare Successo

```
✅ Tempo sincronizzazione al primo avvio: < 2 secondi
✅ Numero backup creati per 10 livelli: 10
✅ Spazio SharedPreferences usato: < 1KB
✅ Numero ritentativi in caso di errore: 1 (non infinito)
✅ Percentuale successful sync: > 95%
✅ Offline functionality: 100%
```

---

## 5️⃣ Checklist Pre-Release

- [ ] Test con 3+ dispositivi diversi
- [ ] Test aggiornamento app da v precedente
- [ ] Test offline mode
- [ ] Test ripristino backup
- [ ] Verifica log non contiene errori critici
- [ ] Verifica Altervista raggiungibile
- [ ] Verifica min_version.txt e latest_version.txt aggiornati
- [ ] Test con utenti multipli contemporaneamente
- [ ] Test perdita dati locali (ripristino da server)
- [ ] Verifica performance (niente lag o delay)

---

## 6️⃣ File Chiave per Debugging

```
lib/
├── main.dart                           ← Punto di ingresso sincronizzazione
├── services/
│   ├── version_service.dart            ← Blocco versione
│   ├── api_service.dart                ← Comunicazione Altervista
│   └── progress_sync_service.dart      ← 🆕 Sincronizzazione progressi
└── screens/
    └── game_screen.dart                ← Trigger backup (vittoria)
```

---

## 7️⃣ Esempio Log Completo Atteso

```
🆕 Nuovo utente ospite creato: guest_a1b2c3d4
🔄 Controllo aggiornamento versione: Last=null, Current=1.0.0
📦 Aggiornamento versione rilevato! Sincronizzazione progressi...
💾 Progressi locali: guest_a1b2c3d4 - Livello 1
🌍 Richiedo versione minima da: https://grz.altervista.org/html/min_version.txt?t=1234567890
📡 Risposta HTTP: 200 - 1.0.0
✅ Versione minima ottenuta dal server: 1.0.0
📱 Versione App installata: 1.0.0
🔍 Confronto versioni: 1.0.0 vs 1.0.0
📊 Risultato confronto: 0 (positivo = OK)
✅ Versione supportata.
💾 Tentativo di salvataggio per guest_a1b2c3d4 al livello 1...
📡 Risposta HTTP: 200 - {"status":"success"}
✅ Salvataggio riuscito su Altervista!
✅ Progressi sincronizzati con successo!
```

---

**Ultimo Update**: 8 Gennaio 2026
**Stato Implementazione**: ✅ Completo
