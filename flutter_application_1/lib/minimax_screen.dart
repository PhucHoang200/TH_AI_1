import 'package:flutter/material.dart';
import 'dart:async';

class MinimaxScreen extends StatefulWidget {
  const MinimaxScreen({super.key});
  @override
  _MinimaxScreenState createState() => _MinimaxScreenState();
}

class _MinimaxScreenState extends State<MinimaxScreen> {
  late GameState game;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    game = GameState(onGameEnd: _showDialog);
  }

  void _showDialog(String message) {
    setState(() => isRunning = false);
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Kết quả'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => game.reset());
                },
                child: Text('Chơi lại'),
              ),
            ],
          ),
    );
  }

  void _runGame() async {
    setState(() => isRunning = true);

    while (isRunning) {
      await Future.delayed(Duration(seconds: 1));
      setState(() => game.movePacman());
      if (!isRunning) break;

      await Future.delayed(Duration(seconds: 1));
      setState(() => game.moveGhost());
      if (!isRunning) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minimax - Pacman vs Ghost')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                int x = index ~/ 3, y = index % 3;
                String value = game.grid[x][y];
                Color color =
                    {
                      'P': Colors.yellow,
                      'G': Colors.red,
                      'D': Colors.green,
                    }[value] ??
                    Colors.grey[300]!;
                return Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(color: color, border: Border.all()),
                  child: Center(
                    child: Text(value, style: TextStyle(fontSize: 24)),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: game.logs.length,
              padding: EdgeInsets.all(8),
              itemBuilder:
                  (_, i) => Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(game.logs[i], style: TextStyle(fontSize: 16)),
                    ),
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: isRunning ? null : _runGame,
              child: Text('Chạy thuật toán'),
            ),
          ),
        ],
      ),
    );
  }
}

class GameState {
  final Function(String) onGameEnd;
  List<List<String>> grid = List.generate(
    3,
    (_) => List.generate(3, (_) => ''),
  );
  int pacX = 0, pacY = 0;
  int ghostX = 0, ghostY = 1;
  final int doorX = 1, doorY = 1;
  List<String> logs = [];
  Set<String> visited = {};

  GameState({required this.onGameEnd}) {
    reset();
  }

  void reset() {
    grid = List.generate(3, (_) => List.generate(3, (_) => ''));
    pacX = 0;
    pacY = 0;
    ghostX = 0;
    ghostY = 1;
    grid[pacX][pacY] = 'P';
    grid[ghostX][ghostY] = 'G';
    grid[doorX][doorY] = 'D';
    logs.clear();
    visited.clear();
    logs.add('Trò chơi bắt đầu!');
  }

  void movePacman() {
    final move = _minimax(pacX, pacY, true, 5);
    grid[pacX][pacY] = '';
    pacX = move['x']!;
    pacY = move['y']!;
    grid[pacX][pacY] = 'P';
    logs.add('Pacman đến ($pacX, $pacY)');

    if (_checkEnd()) return;
  }

  void moveGhost() {
    final move = _minimax(ghostX, ghostY, false, 5);
    grid[ghostX][ghostY] = '';
    ghostX = move['x']!;
    ghostY = move['y']!;
    grid[ghostX][ghostY] = 'G';
    logs.add('Ghost đến ($ghostX, $ghostY)');

    _checkEnd();
  }

  bool _checkEnd() {
    if (pacX == doorX && pacY == doorY) {
      logs.add('Pacman thắng!');
      onGameEnd('Pacman thắng!');
      return true;
    }
    if ((pacX == ghostX && pacY == ghostY) ||
        (ghostX == doorX && ghostY == doorY)) {
      logs.add('Ghost thắng!');
      onGameEnd('Ghost thắng!');
      return true;
    }
    return false;
  }

  Map<String, int> _minimax(int x, int y, bool isPacman, int depth) {
    if (depth == 0) return {'score': 0, 'x': x, 'y': y};
    if (x == pacX && y == pacY && !isPacman)
      return {'score': 1, 'x': x, 'y': y};
    if (x == doorX && y == doorY)
      return {'score': isPacman ? 1 : -1, 'x': x, 'y': y};

    final stateKey = '$pacX,$pacY,$ghostX,$ghostY';
    if (visited.contains(stateKey)) {
      logs.add('Trạng thái lặp lại: $stateKey');
      onGameEnd('Thuật toán dừng: trạng thái lặp lại');
      return {'score': 0, 'x': x, 'y': y};
    }
    visited.add(stateKey);

    final directions = [
      {'dx': -1, 'dy': 0},
      {'dx': 1, 'dy': 0},
      {'dx': 0, 'dy': -1},
      {'dx': 0, 'dy': 1},
    ];

    List<Map<String, int>> moves = [];
    for (var dir in directions) {
      int nx = x + dir['dx']!, ny = y + dir['dy']!;
      if (nx >= 0 && nx < 3 && ny >= 0 && ny < 3) {
        if (isPacman && grid[nx][ny] == '') moves.add({'x': nx, 'y': ny});
        if (!isPacman) moves.add({'x': nx, 'y': ny});
      }
    }

    if (moves.isEmpty) return {'score': 0, 'x': x, 'y': y};

    int bestScore = isPacman ? -999 : 999;
    Map<String, int> bestMove = moves.first;

    for (var move in moves) {
      int oldPX = pacX, oldPY = pacY;
      int oldGX = ghostX, oldGY = ghostY;

      if (isPacman) {
        pacX = move['x']!;
        pacY = move['y']!;
      } else {
        ghostX = move['x']!;
        ghostY = move['y']!;
      }

      var result = _minimax(pacX, pacY, !isPacman, depth - 1);

      pacX = oldPX;
      pacY = oldPY;
      ghostX = oldGX;
      ghostY = oldGY;

      if (isPacman && result['score']! > bestScore) {
        bestScore = result['score']!;
        bestMove = move;
      } else if (!isPacman && result['score']! < bestScore) {
        bestScore = result['score']!;
        bestMove = move;
      }
    }

    return {'score': bestScore, 'x': bestMove['x']!, 'y': bestMove['y']!};
  }
}
