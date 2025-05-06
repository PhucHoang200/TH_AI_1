import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(
    MaterialApp(
      title: 'Minimax Algorithm - Pacman vs Ghost',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MinimaxScreen(),
    ),
  );
}

class MinimaxScreen extends StatefulWidget {
  @override
  _MinimaxScreenState createState() => _MinimaxScreenState();
}

class _MinimaxScreenState extends State<MinimaxScreen> {
  // Ma trận 3x3
  List<List<String>> grid = List.generate(
    3,
    (_) => List.generate(3, (_) => ''),
  );

  // Vị trí Pacman, Ghost và cánh cửa
  int pacmanX = 0, pacmanY = 0;
  int ghostX = 0, ghostY = 1;
  int doorX = 1, doorY = 1;

  bool isRunning = false;

  // Danh sách lưu log các bước di chuyển
  List<String> logs = [];

  // Bộ nhớ cache để lưu trạng thái đã duyệt
  Set<String> visitedStates = {};

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    setState(() {
      grid = List.generate(3, (_) => List.generate(3, (_) => ''));
      grid[pacmanX][pacmanY] = 'P'; // Pacman
      grid[ghostX][ghostY] = 'G'; // Ghost
      grid[doorX][doorY] = 'D'; // Door

      // Xóa log
      logs.clear();
      logs.add('Trò chơi bắt đầu!');
      visitedStates.clear();
    });
  }

  // Hàm di chuyển Pacman
  void _movePacman() {
    var bestMove = _minimax(pacmanX, pacmanY, true, 5); // Giới hạn độ sâu là 5
    setState(() {
      grid[pacmanX][pacmanY] = '';
      pacmanX = bestMove['x']!;
      pacmanY = bestMove['y']!;
      grid[pacmanX][pacmanY] = 'P';

      // Thêm log cho bước di chuyển của Pacman
      logs.add('Pacman di chuyển đến ($pacmanX, $pacmanY)');
    });

    // Kiểm tra điều kiện thắng/thua
    if (pacmanX == doorX && pacmanY == doorY) {
      logs.add('Pacman thắng! Pacman đã đến cửa.');
      _showDialog('Pacman thắng! Pacman đã đến cửa.');
      return;
    } else if (pacmanX == ghostX && pacmanY == ghostY) {
      logs.add('Ghost thắng! Ghost đã bắt được Pacman.');
      _showDialog('Ghost thắng! Ghost đã bắt được Pacman.');
      return;
    }

    // Sau khi Pacman di chuyển, Ghost sẽ di chuyển
    _moveGhost();
  }

  // Hàm di chuyển Ghost
  void _moveGhost() {
    var bestMove = _minimax(ghostX, ghostY, false, 5); // Giới hạn độ sâu là 5
    setState(() {
      grid[ghostX][ghostY] = '';
      ghostX = bestMove['x']!;
      ghostY = bestMove['y']!;
      grid[ghostX][ghostY] = 'G';

      // Thêm log cho bước di chuyển của Ghost
      logs.add('Ghost di chuyển đến ($ghostX, $ghostY)');
    });

    // Kiểm tra điều kiện thắng/thua
    if (ghostX == pacmanX && ghostY == pacmanY) {
      logs.add('Ghost thắng! Ghost đã bắt được Pacman.');
      _showDialog('Ghost thắng! Ghost đã bắt được Pacman.');
      return;
    } else if (ghostX == doorX && ghostY == doorY) {
      logs.add('Ghost thắng! Ghost đã đến cửa trước.');
      _showDialog('Ghost thắng! Ghost đã đến cửa trước.');
      return;
    }
  }

  // ...existing code...

  // Thuật toán Minimax
  Map<String, int> _minimax(int x, int y, bool isPacman, int depth) {
    // Điều kiện dừng: Độ sâu tối đa
    if (depth == 0) {
      return {'score': 0, 'x': x, 'y': y};
    }

    // Điều kiện dừng: Trạng thái kết thúc
    if (x == pacmanX && y == pacmanY && !isPacman) {
      return {'score': 1, 'x': x, 'y': y}; // Ghost ăn Pacman
    }
    if (x == doorX && y == doorY) {
      return {'score': isPacman ? 1 : -1, 'x': x, 'y': y};
    }

    // Tránh trùng lặp trạng thái
    String stateKey = '$pacmanX,$pacmanY,$ghostX,$ghostY';
    if (visitedStates.contains(stateKey)) {
      // Nếu trạng thái đã được duyệt, trả về điểm hòa
      logs.add('Trạng thái đã được duyệt: $stateKey');
      _showDialog('Thuật toán dừng lại do trạng thái trùng lặp!');
      setState(() {
        isRunning = false;
      });
      return {'score': 0, 'x': x, 'y': y};
    }
    visitedStates.add(stateKey);

    // Tìm tất cả các nước đi hợp lệ (chỉ lên, xuống, trái, phải)
    List<Map<String, int>> moves = [];
    for (var direction in [
      {'dx': -1, 'dy': 0}, // Lên
      {'dx': 1, 'dy': 0}, // Xuống
      {'dx': 0, 'dy': -1}, // Trái
      {'dx': 0, 'dy': 1}, // Phải
    ]) {
      int newX = x + direction['dx']!;
      int newY = y + direction['dy']!;
      if (newX >= 0 && newX < 3 && newY >= 0 && newY < 3) {
        // Pacman chỉ được di chuyển vào ô trống
        if (isPacman && grid[newX][newY] == '') {
          moves.add({'x': newX, 'y': newY});
        }
        // Ghost có thể di chuyển vào bất kỳ ô nào (bao gồm cả ô của Pacman)
        if (!isPacman) {
          moves.add({'x': newX, 'y': newY});
        }
      }
    }

    // Nếu không còn nước đi, trả về điểm hòa
    if (moves.isEmpty) {
      return {'score': 0, 'x': x, 'y': y};
    }

    // Tính điểm cho từng nước đi
    Map<String, int>? bestMove;
    int bestScore = isPacman ? -999 : 999;

    for (var move in moves) {
      int newX = move['x']!;
      int newY = move['y']!;

      // Giả lập nước đi
      int oldPacmanX = pacmanX, oldPacmanY = pacmanY;
      int oldGhostX = ghostX, oldGhostY = ghostY;

      if (isPacman) {
        pacmanX = newX;
        pacmanY = newY;
      } else {
        ghostX = newX;
        ghostY = newY;
      }

      // Đệ quy Minimax
      var result = _minimax(pacmanX, pacmanY, !isPacman, depth - 1);

      // Hoàn tác nước đi
      pacmanX = oldPacmanX;
      pacmanY = oldPacmanY;
      ghostX = oldGhostX;
      ghostY = oldGhostY;

      // Cập nhật nước đi tốt nhất
      if (isPacman && result['score']! > bestScore) {
        bestScore = result['score']!;
        bestMove = move;
      } else if (!isPacman && result['score']! < bestScore) {
        bestScore = result['score']!;
        bestMove = move;
      }
    }

    return {'score': bestScore, 'x': bestMove!['x']!, 'y': bestMove['y']!};
  }

  // ...existing code...

  // Hiển thị thông báo kết quả
  void _showDialog(String message) {
    setState(() {
      isRunning = false;
    });
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Kết quả'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _initializeGrid();
                },
                child: Text('Chơi lại'),
              ),
            ],
          ),
    );
  }

  // Chạy thuật toán tự động
  void _runAlgorithm() async {
    setState(() {
      isRunning = true;
    });

    while (isRunning) {
      // Pacman di chuyển trước
      await Future.delayed(Duration(seconds: 1));
      _movePacman();

      // Kiểm tra nếu trò chơi đã kết thúc sau khi Pacman di chuyển
      if (!isRunning) break;

      // Ghost di chuyển sau
      await Future.delayed(Duration(seconds: 1));
      _moveGhost();

      // Kiểm tra nếu trò chơi đã kết thúc sau khi Ghost di chuyển
      if (!isRunning) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minimax Algorithm - Pacman vs Ghost')),
      body: Column(
        children: [
          // Hiển thị ma trận 3x3
          Expanded(
            flex: 3,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                int x = index ~/ 3;
                int y = index % 3;
                return Container(
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        grid[x][y] == 'P'
                            ? Colors.yellow
                            : grid[x][y] == 'G'
                            ? Colors.red
                            : grid[x][y] == 'D'
                            ? Colors.green
                            : Colors.grey[300],
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      grid[x][y],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Hiển thị log
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(logs[index], style: TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),

          // Nút chạy thuật toán
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: isRunning ? null : _runAlgorithm,
              child: Text('Chạy thuật toán'),
            ),
          ),
        ],
      ),
    );
  }
}
