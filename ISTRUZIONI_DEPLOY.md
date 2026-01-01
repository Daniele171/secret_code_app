# 🚀 Istruzioni Deploy su Altervista

## 📤 **FILE DA CARICARE**

### **1. File Versioni (HTML)**
Carica questi file nella cartella `/html/` del tuo sito Altervista:

- `min_version.txt` → `https://grz.altervista.org/html/min_version.txt`
- `latest_version.txt` → `https://grz.altervista.org/html/latest_version.txt`

### **2. File PHP**
Carica questo file nella cartella `/php/` del tuo sito Altervista:

- `save_score.php` → `https://grz.altervista.org/php/save_score.php`

### **3. File Classifica**
Carica questo file nella cartella `/html/` del tuo sito Altervista:

- `classifica_globale.html` → `https://grz.altervista.org/html/classifica_globale.html`

## 🔧 **COME CARICARE SU ALTERVISTA**

### **Metodo 1: File Manager Altervista**
1. Vai su [Altervista.org](https://altervista.org)
2. Accedi al tuo pannello di controllo
3. Clicca su "File Manager"
4. Naviga nella cartella corretta (`/html/` o `/php/`)
5. Carica i file uno per uno

### **Metodo 2: FTP (consigliato)**
```bash
# Usa FileZilla o un client FTP
Host: ftp.grz.altervista.org
Username: il tuo username Altervista
Password: la tua password
```

### **Metodo 3: Git (se hai configurato)**
```bash
git add .
git commit -m "Aggiorna sistema versioni e API"
git push origin main
```

## ✅ **VERIFICA DEPLOY**

Dopo il caricamento, testa che i file siano raggiungibili:

```bash
# Test versioni
curl https://grz.altervista.org/html/min_version.txt
curl https://grz.altervista.org/html/latest_version.txt

# Test PHP (dovrebbe dare errore POST, ma essere raggiungibile)
curl https://grz.altervista.org/php/save_score.php
```

---

## 🧪 **2. COME TESTARE IL BLOCCO APP**

### **Per vedere la schermata di blocco:**

1. **Cambia min_version.txt** nel sito a una versione più alta della tua app:
   ```
   # Invece di 1.0.0, metti:
   3.0.0
   ```

2. **Ricompila l'app Flutter:**
   ```bash
   cd /Users/daniele/Desktop/secret_code/secret_code
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Risultato atteso:**
   - L'app dovrebbe mostrare la schermata di blocco
   - Dovrebbe dire "È richiesta la versione 3.0.0 o superiore"
   - Dovrebbe mostrare la tua versione attuale (2.0.1)

### **Per sbloccare l'app:**
Cambia `min_version.txt` di nuovo a `1.0.0` e riavvia l'app.

### **Test avanzato:**
Cambia a versioni diverse per vedere come cambia il messaggio:
- `1.5.0` → Dovrebbe bloccare (perché 2.0.1 < 1.5.0 è FALSO)
- `2.0.0` → Dovrebbe bloccare (perché 2.0.1 < 2.0.0 è FALSO)
- `2.0.2` → Dovrebbe bloccare (perché 2.0.1 < 2.0.2 è VERO)
- `3.0.0` → Dovrebbe bloccare (perché 2.0.1 < 3.0.0 è VERO)
