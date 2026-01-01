class GameSettings {
  int codeLength;
  int maxRows;
  bool allowDuplicates;
  int numberOfColors; // Numero di colori disponibili (8 = base, 12 = tutti)

  GameSettings({
    this.codeLength = 4, 
    this.maxRows = 10,
    this.allowDuplicates = true,
    this.numberOfColors = 4, // Default: solo i colori base
  });
}