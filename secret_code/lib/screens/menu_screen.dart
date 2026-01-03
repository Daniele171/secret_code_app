import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_settings.dart';
import 'game_screen.dart';
import 'career_screen.dart';
import 'profile_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GameSettings _settings = GameSettings();

  @override
  Widget build(BuildContext context) {
    // Ho rimosso 'isDark' qui perché non veniva usato in questa parte
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              icon: const CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("MENU PRINCIPALE", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, size: 30),
                      SizedBox(width: 15),
                      Text("CARRIERA", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              
              Text("ALLENAMENTO LIBERO", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 10),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                       _buildSettingCard(context, title: "Lunghezza Codice", value: _settings.codeLength.toString(),
                        child: Slider(
                          value: _settings.codeLength.toDouble(), min: 3, max: 6, divisions: 3, label: _settings.codeLength.toString(),
                          onChanged: (v) => setState(() {
                            _settings.codeLength = v.toInt();
                            if (!_settings.allowDuplicates && _settings.numberOfColors < _settings.codeLength) {
                              _settings.numberOfColors = _settings.codeLength;
                            }
                          }),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildSettingCard(context, title: "Tentativi", value: _settings.maxRows.toString(),
                        child: Slider(
                          value: _settings.maxRows.toDouble(), min: 6, max: 15, divisions: 9, label: _settings.maxRows.toString(), 
                          activeColor: Colors.green,
                          onChanged: (v) => setState(() => _settings.maxRows = v.toInt()),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildSettingCard(context, title: "Consenti Duplicati", value: _settings.allowDuplicates ? "SÌ" : "NO",
                        child: SwitchListTile(
                          title: const Text("Difficoltà maggiore", style: TextStyle(fontSize: 14)),
                          subtitle: Text(_settings.allowDuplicates ? "Colori ripetuti possibili" : "Nessun colore ripetuto", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          value: _settings.allowDuplicates, 
                          activeTrackColor: Colors.orangeAccent, 
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setState(() {
                            _settings.allowDuplicates = v;
                            if (!v && _settings.numberOfColors < _settings.codeLength) {
                              _settings.numberOfColors = _settings.codeLength;
                            }
                          }),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildSettingCard(context, title: "Numero Colori", value: _settings.numberOfColors.toString(),
                        child: Slider(
                          value: _settings.numberOfColors.toDouble(), 
                          min: 4, 
                          max: 10, 
                          divisions: 6, 
                          label: _settings.numberOfColors.toString(),
                          activeColor: Colors.purple,
                          onChanged: (v) => setState(() {
                            _settings.numberOfColors = v.toInt();
                            if (!_settings.allowDuplicates && _settings.numberOfColors < _settings.codeLength) {
                              _settings.codeLength = _settings.numberOfColors;
                            }
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(settings: _settings)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: const Text("GIOCA ALLENAMENTO", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, {required String title, required String value, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[200], 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}