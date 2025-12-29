class GameSettings {
  int codeLength;
  int maxRows;
  bool allowDuplicates;

  GameSettings({
    this.codeLength = 4, 
    this.maxRows = 10,
    this.allowDuplicates = true,
  });
}