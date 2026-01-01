class GameSettings {
  int codeLength;
  int maxRows;
  bool allowDuplicates;
  int numberOfColors;

  GameSettings({
    this.codeLength = 4, 
    this.maxRows = 10,
    this.allowDuplicates = true,
    this.numberOfColors = 4,
  });
}