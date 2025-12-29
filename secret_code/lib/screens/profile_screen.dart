import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _currentLevel = 1;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLevel = prefs.getInt('career_level') ?? 1;
      _nameController.text = prefs.getString('player_name') ?? "Agente Segreto";
    });
  }

  Future<void> _saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', _nameController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nome salvato nel telefono!"))
    );
  }

  Future<void> _syncToAltervista() async {
    setState(() => _isSyncing = true);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', _nameController.text);

    // Procediamo direttamente con il salvataggio
    bool success = await ApiService.saveProgress(_nameController.text, _currentLevel);

    setState(() => _isSyncing = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Progressi salvati con successo su Altervista!"), 
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        )
      );
    } else {
      // Messaggio più specifico per l'errore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Errore nel salvataggio. Verifica:\n• Connessione internet attiva\n• Nome utente non vuoto\n• URL Altervista corretto"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text("AREA PERSONALE")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orangeAccent,
              child: Text(
                _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : "A",
                style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text("NOME AGENTE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Inserisci il tuo nome",
                    ),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    onSubmitted: (_) => _saveName(),
                  ),
                  const Divider(height: 30),
                  const Text("LIVELLO RAGGIUNTO", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text(
                    "$_currentLevel", 
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.orangeAccent)
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isSyncing ? null : _syncToAltervista,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSyncing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload),
                        SizedBox(width: 15),
                        Text("SALVA SU ALTERVISTA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}