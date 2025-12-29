import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_settings.dart';
import '../logic/game_logic.dart';

class GameScreen extends StatefulWidget {
  final GameSettings settings;
  final int? levelId; 

  const GameScreen({super.key, required this.settings, this.levelId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<String> secretCode;
  late List<List<String?>> grid;
  late List<Map<String, int>?> feedbacks;
  late List<String> currentColors;

  int currentRow = 0;
  String? selectedColor;
  bool isGameOver = false;
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  Timer? _gameTimer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    currentColors = kGameColors.keys.toList();
    selectedColor = currentColors[0];
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.bounceOut),
    );
    
    _startNewGame();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _stopTimer();
    _secondsElapsed = 0;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
  }

  String _formatTimer(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _startNewGame() {
    setState(() {
      secretCode = GameLogic.generateSecretCode(
        widget.settings.codeLength, 
        currentColors,
        widget.settings.allowDuplicates
      );
      grid = List.generate(widget.settings.maxRows, (_) => List.filled(widget.settings.codeLength, null));
      feedbacks = List.filled(widget.settings.maxRows, null);
      currentRow = 0;
      isGameOver = false;
    });
    _startTimer();
    _animationController.forward(from: 0.0);
  }

  void _handleHoleTap(int row, int col) {
    if (isGameOver || row != currentRow) return;
    HapticFeedback.selectionClick();
    setState(() {
      grid[row][col] = selectedColor;
    });
    _animationController.forward(from: 0.0);
  }

  void _clearCurrentRow() {
    if (isGameOver) return;
    HapticFeedback.lightImpact();
    setState(() {
      grid[currentRow] = List.filled(widget.settings.codeLength, null);
    });
  }

  void _surrender() {
    if (isGameOver) return;
    HapticFeedback.heavyImpact();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("Ti arrendi?"),
      content: const Text("Il gioco finirà e vedrai la soluzione."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ANNULLA")),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            _endGame(false);
          }, 
          child: const Text("ARRENDITI", style: TextStyle(color: Colors.red))
        ),
      ],
    ));
  }

  void _checkRow() {
    if (grid[currentRow].contains(null)) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Completa la riga prima di verificare!", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        )
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final result = GameLogic.checkGuess(secretCode, grid[currentRow]);

    setState(() {
      feedbacks[currentRow] = result;
      bool win = result['black'] == widget.settings.codeLength;

      if (win) {
        _endGame(true);
      } else {
        currentRow++;
        if (currentRow >= widget.settings.maxRows) {
          _endGame(false);
        } else {
          Future.delayed(const Duration(milliseconds: 300), () {
             if(_scrollController.hasClients) {
               _scrollController.animateTo(
                 _scrollController.position.minScrollExtent,
                 duration: const Duration(milliseconds: 500), 
                 curve: Curves.easeOut
               );
             }
          });
        }
      }
    });
  }

  void _endGame(bool win) {
    isGameOver = true;
    _stopTimer();
    if (win) {
      _animationController.repeat(reverse: true);
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false, 
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          // Corretto const e BoxShadow
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              win 
                ? (widget.levelId != null ? "LIVELLO COMPLETATO!" : "VITTORIA!") 
                : "GAME OVER", 
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: win ? const Color(0xFF2ECC40) : const Color(0xFFFF4136)
              )
            ),
            const SizedBox(height: 10),
            Text("Tempo impiegato: ${_formatTimer(_secondsElapsed)}", 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("Il codice segreto era:", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: secretCode.map((c) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 45, height: 45,
                decoration: BoxDecoration(
                  color: kGameColors[c],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  // Corretto withValues
                  boxShadow: [BoxShadow(color: kGameColors[c]!.withValues(alpha: 0.6), blurRadius: 10)]
                ),
              )).toList(),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () { 
                      Navigator.pop(ctx); 
                      Navigator.pop(context, win); 
                    }, 
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      foregroundColor: textColor
                    ),
                    child: Text(widget.levelId != null ? "MAPPA" : "MENU"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { 
                      Navigator.pop(ctx); 
                      _startNewGame(); 
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15), 
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white
                    ),
                    child: const Text("RIGIOCA"),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: widget.levelId != null 
          ? Text("LIVELLO ${widget.levelId}", style: const TextStyle(fontWeight: FontWeight.bold))
          : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, size: 20),
              const SizedBox(width: 8),
              Text(_formatTimer(_secondsElapsed), style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            ],
          ),
        actions: [
          IconButton(
            onPressed: _surrender, 
            icon: const Icon(Icons.flag_outlined),
            tooltip: "Arrenditi",
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: widget.settings.maxRows,
              reverse: true,
              itemBuilder: (ctx, index) => _buildGameRow(index),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                // Corretto withValues
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1), 
                  blurRadius: 15, 
                  offset: const Offset(0, -5)
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: currentColors.map((c) {
                      bool isSelected = selectedColor == c;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => selectedColor = c);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: isSelected ? 48 : 40,
                          height: isSelected ? 48 : 40,
                          decoration: BoxDecoration(
                            color: kGameColors[c],
                            shape: BoxShape.circle,
                            border: isSelected 
                              ? Border.all(color: isDark ? Colors.white : Colors.black87, width: 3) 
                              : null,
                            boxShadow: [
                              if (isSelected)
                                // Corretto withValues
                                BoxShadow(
                                  color: kGameColors[c]!.withValues(alpha: 0.4), 
                                  blurRadius: 12, 
                                  spreadRadius: 2
                                )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: IconButton(
                        icon: Icon(Icons.cleaning_services_rounded, color: isDark ? Colors.white70 : Colors.black54),
                        onPressed: _clearCurrentRow,
                        tooltip: "Pulisci riga",
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isGameOver ? null : _checkRow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 4,
                        ),
                        child: const Text("VERIFICA CODICE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGameRow(int rowIndex) {
    bool isActive = rowIndex == currentRow && !isGameOver;
    if (rowIndex > currentRow) {
       return Opacity(opacity: 0.1, child: _dummyRow()); 
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color rowBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color activeBorder = Theme.of(context).colorScheme.primary;

    return Opacity(
      opacity: (rowIndex == currentRow) ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: rowBg,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: activeBorder, width: 2) : null,
          boxShadow: [
             if (rowIndex == currentRow)
               // Corretto withValues
               BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)
          ]
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text(
                "${rowIndex + 1}", 
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600], 
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.settings.codeLength, (colIndex) {
                  String? colorName = grid[rowIndex][colIndex];
                  bool hasColor = colorName != null;
                
                  return AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: hasColor && isActive ? (_bounceAnimation.value * 0.1 + 0.9) : 1.0,
                        child: GestureDetector(
                          onTap: () => _handleHoleTap(rowIndex, colIndex),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: hasColor ? kGameColors[colorName] : (isDark ? Colors.white10 : const Color(0xFFEEEEEE)),
                              shape: BoxShape.circle,
                              border: !hasColor ? Border.all(color: isDark ? Colors.white24 : Colors.black12) : null,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            Container(
              width: 44, height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildFeedbackGrid(feedbacks[rowIndex]),
            )
          ],
        ),
      ),
    );
  }

  Widget _dummyRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 54,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black12,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildFeedbackGrid(Map<String, int>? feedback) {
    if (feedback == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(child: Icon(Icons.more_horiz, size: 16, color: isDark ? Colors.white24 : Colors.black26));
    }

    List<Widget> pegs = [];
    for (int i = 0; i < feedback['black']!; i++) {
      pegs.add(_buildPeg(type: 'black'));
    }
    for (int i = 0; i < feedback['white']!; i++) {
      pegs.add(_buildPeg(type: 'white'));
    }
    
    while(pegs.length < 4) {
      pegs.add(const SizedBox(width: 10, height: 10));
    }

    return Center(
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: pegs,
      ),
    );
  }

  Widget _buildPeg({required String type}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    BoxBorder? border;

    if (type == 'black') {
      color = Colors.black;
      if (isDark) {
        border = Border.all(color: Colors.white54, width: 1);
      } else {
        color = const Color(0xFF222222);
      }
    } else {
      color = Colors.white;
      if (!isDark) {
        border = Border.all(color: Colors.grey[400]!, width: 1);
      }
    }

    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
        boxShadow: [
          if (type == 'black' && !isDark) 
             // Corretto const
             const BoxShadow(color: Colors.black26, blurRadius: 2)
        ]
      ),
    );
  }
}