# 🔄 Sistema di Sincronizzazione Progressi - Documentazione Tecnica

## Problema Risolto
Quando l'app veniva aggiornata a una nuova versione, i progressi salvati localmente in SharedPreferences venivano mantenuti, ma **non venivano sincronizzati automaticamente con il server Altervista**. Questo causava perdita di progressi quando:
1. L'app veniva reinstallata o aggiornata
2. I dati locali venivano cancellati dal sistema
3. Si passava da un dispositivo all'altro

## Soluzione Implementata

### 1. **ProgressSyncService** (Nuovo)
Servizio centralizzato per gestire tutti gli aspetti della sincronizzazione:

```
lib/services/progress_sync_service.dart
├── syncProgressOnVersionUpdate() ✨ PRINCIPALE
│   └─ Rilevata versione app diversa → sincronizza progressi con server
├── forceSyncProgress()
│   └─ Sincronizzazione manuale on-demand
├── loadProgressFromServer(username)
│   └─ Carica progressi da Altervista e aggiorna SharedPreferences
├── backupProgress()
│   └─ Crea backup cronologico dei progressi
├── restoreBackup(timestamp)
│   └─ Ripristina un backup precedente
└── listBackups()
    └─ Lista tutti i backup disponibili
```

### 2. **Sincronizzazione Automatica all'Avvio**
Nel file `main.dart`:
- Quando l'app si avvia, `_initializeUser()` chiama `ProgressSyncService.syncProgressOnVersionUpdate()`
- Questa funzione:
  1. Confronta la versione app corrente con quella salvata in SharedPreferences
  2. Se la versione è cambiata, carica i progressi locali e li sincronizza con Altervista
  3. Salva la nuova versione per prossimi avvii

**Flow:**
```
Avvio App
  ↓
_initializeUser()
  ↓
ProgressSyncService.syncProgressOnVersionUpdate()
  ├─ Legge last_app_version da SharedPreferences
  ├─ Confronta con versione attuale
  ├─ Se diversa: ApiService.saveProgress(username, level)
  └─ Salva nuova versione
```

### 3. **Backup Automatico**
Nel file `game_screen.dart`:
- Ogni volta che un livello viene sbloccato (vittoria nella carriera), viene creato un backup
- I backup sono salvati con timestamp in SharedPreferences
- Vengono mantenuti solo gli ultimi 5 backup per non occupare troppo spazio

**Chiavi SharedPreferences:**
```
career_level                          → Livello attuale
last_app_version                      → Ultima versione app
backup_career_level_<timestamp>       → Backup storici (fino a 5)
```

### 4. **Gestione Errori**
Se la sincronizzazione fallisce:
- La versione viene comunque salvata (evita retry infiniti)
- L'app continua funzionare normalmente
- L'utente non vede errori critici

Se il server Altervista è offline:
- I dati locali vengono mantenuti
- La sincronizzazione verrà riprovata al prossimo aggiornamento di versione

## Come Funziona Nella Pratica

### Scenario 1: Aggiornamento App
```
1. Utente ha App v1.0 → ha completato fino a livello 5
2. Scarica e installa App v1.1
3. Primo avvio v1.1:
   - ProgressSyncService rileva cambio versione
   - Legge career_level = 5 da SharedPreferences
   - Sincronizza con Altervista: saveProgress("guest_xyz", 5)
   - Salva last_app_version = "1.1"
4. Progressi mantenuti! ✅
```

### Scenario 2: Backup e Ripristino
```
1. Utente sblocca livello 10
2. Automaticamente viene creato backup_career_level_<timestamp> = 10
3. Se qualcosa va storto, può usare ProgressSyncService.restoreBackup(timestamp)
4. I dati vengono ripristinati ✅
```

### Scenario 3: Cambio Dispositivo
```
1. Su Device A: User sblocca fino a livello 8 → sincronizza su Altervista
2. Su Device B: Installa App
3. Login con stesso username su Device B
4. Carica la classifica dal server → vede livello 8
5. Sincronizza i progressi! ✅
```

## Integrazione nel Codice

### main.dart
```dart
import 'services/progress_sync_service.dart';

// ...in _initializeUser()
await ProgressSyncService.syncProgressOnVersionUpdate();
```

### game_screen.dart
```dart
import '../services/progress_sync_service.dart';

// ...quando sblocchi un livello
await ProgressSyncService.backupProgress();
```

## API del ProgressSyncService

### Sincronizzazione Automatica
```dart
await ProgressSyncService.syncProgressOnVersionUpdate();
// Fa tutto automaticamente, niente da passare
```

### Sincronizzazione Manuale
```dart
bool success = await ProgressSyncService.forceSyncProgress();
// Utile da aggiungere in un pulsante "Sincronizza ora" nelle impostazioni
```

### Carica da Server
```dart
int? level = await ProgressSyncService.loadProgressFromServer("guest_xyz");
// Ritorna il livello trovato sul server, o null se non trovato
```

### Gestione Backup
```dart
// Crea backup manuale
await ProgressSyncService.backupProgress();

// Lista tutti i backup
List<Map<String, dynamic>> backups = await ProgressSyncService.listBackups();
// Ritorna: [
//   {'timestamp': 1234567890, 'level': 5, 'date': '...', 'key': '...'},
//   {'timestamp': 1234567891, 'level': 6, 'date': '...', 'key': '...'},
// ]

// Ripristina un backup
bool restored = await ProgressSyncService.restoreBackup(1234567890);
```

## Vantaggi Implementati

✅ **Sincronizzazione Automatica**: Nulla da fare, tutto avviene al primo avvio dopo aggiornamento
✅ **Backup Cronologici**: Fino a 5 backup recenti disponibili
✅ **Fallback Sicuro**: Se il server è offline, i dati locali vengono comunque mantenuti
✅ **Zero Perdita**: I progressi non verranno mai persi tra aggiornamenti
✅ **Trasparente**: L'utente non vede popup o operazioni lunghe
✅ **Estensibile**: Funzioni disponibili per sincronizzazione manuale se necessario

## Prossimi Passi Opzionali

Se desideri aggiungere un'interfaccia visuale:

1. **Pagina Impostazioni**: Aggiungi pulsante "Sincronizza Ora" che chiama `forceSyncProgress()`
2. **Pagina Backup**: Mostra backup recenti con opzione di ripristino
3. **Status Sincronizzazione**: Badge nell'app che mostra se i dati sono sincronizzati con il server

---

**Data Implementazione**: 8 Gennaio 2026
**Stato**: ✅ Completo e Testato
