import 'dart:math';
import 'package:flutter/material.dart';

// I Colori disponibili
final Map<String, Color> kGameColors = {
  'orange': const Color(0xFFFF6A00),
  'yellow': const Color(0xFFFFD900),
  'red':    const Color(0xFFFF4136),
  'green':  const Color(0xFF2ECC40),
  'blue':   const Color(0xFF0074D9),
  'brown':  const Color(0xFF914713),
  'purple': const Color(0xFF9B59B6),
  'pink':   const Color(0xFFE91E63),
  'cyan':   const Color(0xFF00BCD4),
  'gray':   const Color(0xFF95A5A6),
};

class GameLogic {
  static List<String> generateSecretCode(int length, List<String> availableColors, bool allowDuplicates) {
    final random = Random();
    
    if (allowDuplicates) {
      return List.generate(length, (_) => availableColors[random.nextInt(availableColors.length)]);
    } else {
      List<String> shuffled = List.from(availableColors)..shuffle(random);
      return shuffled.take(length).toList();
    }
  }

  static Map<String, int> checkGuess(List<String> secret, List<String?> guess) {
    int blackPegs = 0;
    int whitePegs = 0;
    
    List<String?> secretCopy = List.from(secret);
    List<String?> guessCopy = List.from(guess);

    // 1. Neri
    for (int i = 0; i < guess.length; i++) {
      if (guessCopy[i] == secretCopy[i]) {
        blackPegs++;
        guessCopy[i] = null;
        secretCopy[i] = 'MATCHED';
      }
    }

    // 2. Bianchi
    for (int i = 0; i < guess.length; i++) {
      if (guessCopy[i] != null) {
        int indexInSecret = secretCopy.indexOf(guessCopy[i]);
        if (indexInSecret != -1) {
          whitePegs++;
          secretCopy[indexInSecret] = 'USED';
        }
      }
    }

    return {'black': blackPegs, 'white': whitePegs};
  }
}