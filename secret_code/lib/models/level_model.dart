import 'game_settings.dart';

class GameLevel {
  final int id;
  final String title;
  final String description;
  final GameSettings settings;

  GameLevel({
    required this.id,
    required this.title,
    required this.description,
    required this.settings,
  });
}

class LevelsData {
  static List<GameLevel> allLevels = [
    // LIV 1: Tutorial
    GameLevel(
      id: 1,
      title: "Riscaldamento",
      description: "Codice a 3 colori. Nessun duplicato.",
      settings: GameSettings(codeLength: 3, maxRows: 10, allowDuplicates: false),
    ),
    // LIV 2: Facile
    GameLevel(
      id: 2,
      title: "Primi Passi",
      description: "Codice a 4 colori. Nessun duplicato.",
      settings: GameSettings(codeLength: 4, maxRows: 10, allowDuplicates: false),
    ),
    // LIV 3: Normale
    GameLevel(
      id: 3,
      title: "La Sfida",
      description: "Codice a 4 colori. I duplicati ora sono permessi!",
      settings: GameSettings(codeLength: 4, maxRows: 10, allowDuplicates: true),
    ),
    // LIV 4: Pressione
    GameLevel(
      id: 4,
      title: "Conto alla rovescia",
      description: "4 colori, duplicati, ma solo 8 tentativi.",
      settings: GameSettings(codeLength: 4, maxRows: 8, allowDuplicates: true),
    ),
    // LIV 5: Esperto
    GameLevel(
      id: 5,
      title: "High Five",
      description: "Codice a 5 colori. Nessun duplicato.",
      settings: GameSettings(codeLength: 5, maxRows: 12, allowDuplicates: false, numberOfColors: 5),
    ),
    // LIV 6: Maestro
    GameLevel(
      id: 6,
      title: "Caos Calmo",
      description: "5 colori con duplicati. Hai 12 tentativi.",
      settings: GameSettings(codeLength: 5, maxRows: 12, allowDuplicates: true, numberOfColors: 5),
    ),
    // LIV 7: Cecchino
    GameLevel(
      id: 7,
      title: "Il Cecchino",
      description: "Codice a 4 colori standard, ma solo 6 tentativi. Non sbagliare.",
      settings: GameSettings(codeLength: 4, maxRows: 6, allowDuplicates: true),
    ),
    // LIV 8: Elite
    GameLevel(
      id: 8,
      title: "Elite Six",
      description: "Codice a 6 colori (lungo). No duplicati.",
      settings: GameSettings(codeLength: 6, maxRows: 12, allowDuplicates: false, numberOfColors: 6),
    ),
    // LIV 9: Gran Maestro
    GameLevel(
      id: 9,
      title: "Incubo Logico",
      description: "6 colori. Duplicati ammessi. Buona fortuna.",
      settings: GameSettings(codeLength: 6, maxRows: 12, allowDuplicates: true, numberOfColors: 6),
    ),
    // LIV 10: Impossibile
    GameLevel(
      id: 10,
      title: "THE FINAL BOSS",
      description: "6 colori. Duplicati. Solo 8 tentativi. Sei pronto?",
      settings: GameSettings(codeLength: 6, maxRows: 8, allowDuplicates: true, numberOfColors: 6),
    ),
  ];
}