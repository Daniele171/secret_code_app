# 📋 Elenco File per Deploy su Altervista

## 📁 **DA COPIARE DALLA CARTELLA "sito"**

### **Cartella `/html/` su Altervista:**
```
sito/html/min_version.txt         →  /html/min_version.txt
sito/html/latest_version.txt      →  /html/latest_version.txt  
sito/html/classifica_globale.html →  /html/classifica_globale.html
```

### **Cartella `/php/` su Altervista:**
```
sito/php/save_score.php           →  /php/save_score.php
```

## 🎯 **COMANDI PER COPIARE RAPIDAMENTE**

Se hai accesso via terminale/FTP:

```bash
# Copia i file versioni
cp /Users/daniele/Downloads/sito/html/min_version.txt /path/to/altervista/html/
cp /Users/daniele/Downloads/sito/html/latest_version.txt /path/to/altervista/html/
cp /Users/daniele/Downloads/sito/html/classifica_globale.html /path/to/altervista/html/

# Copia il file PHP
cp /Users/daniele/Downloads/sito/php/save_score.php /path/to/altervista/php/
```

## 🧪 **PER TESTARE IL BLOCCO APP:**

### **1. Modifica min_version.txt sul sito:**
Prima del deploy, cambia temporaneamente il valore:

```bash
# Invece di "1.0.0", metti una versione più alta
echo "3.0.0" > /Users/daniele/Downloads/sito/html/min_version.txt
```

### **2. Carica su Altervista**

### **3. Testa l'app:**
```bash
cd /Users/daniele/Desktop/secret_code/secret_code
flutter clean
flutter run
```

### **4. Dovrebbe apparire la schermata di blocco!**

### **5. Per sbloccare:**
Rimetti "1.0.0" in min_version.txt e ricarica.

## ✅ **VERIFICA DEPLOY**

Dopo il caricamento, testa che funzioni:

```bash
# Testa che i file siano raggiungibili
curl https://grz.altervista.org/html/min_version.txt
# Dovrebbe restituire: 1.0.0 (o 3.0.0 per il test)

curl https://grz.altervista.org/html/latest_version.txt  
# Dovrebbe restituire: 2.0.1

# Test PHP (dovrebbe dare errore 405 Method Not Allowed, ma essere raggiungibile)
curl https://grz.altervista.org/php/save_score.php
```

## 🔍 **COME VEDERE I LOG DEBUG**

Quando testi l'app Flutter, nei log vedrai:

```
🌍 Richiedo versione minima da: https://grz.altervista.org/html/min_version.txt
📡 Risposta HTTP: 200 - 3.0.0
✅ Versione minima ottenuta dal server: 3.0.0
📱 Versione App installata: 2.0.1
🔍 Confronto versioni: 2.0.1 vs 3.0.0
📊 Risultato confronto: -1 (negativo = blocco)
❌ BLOCCO ATTIVO: La versione è troppo vecchia.
🔒 Blocco attivo - App: 2.0.1, Minima: 3.0.0
```

Questo ti conferma che il sistema funziona!
