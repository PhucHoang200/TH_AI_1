import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_application_1/best_first.dart';
import 'package:flutter_application_1/hill_climbing.dart';
import 'package:flutter_application_1/a_star.dart';
import 'package:flutter_application_1/branch_and_bound.dart';

class GraphSearchScreen extends StatefulWidget {
  @override
  _GraphSearchScreenState createState() => _GraphSearchScreenState();
}

class _GraphSearchScreenState extends State<GraphSearchScreen> {
  dynamic graph;
  List<String> logs = [];
  List<int> path = [];

  final int nodeCount = 14;
  int startNode = 0;
  int endNode = 10;

  final edges = [
    [0, 1, 3],
    [0, 2, 6],
    [0, 3, 5],
    [1, 4, 9],
    [1, 5, 8],
    [2, 6, 12],
    [2, 7, 14],
    [3, 8, 7],
    [8, 9, 5],
    [8, 10, 6],
    [9, 11, 1],
    [9, 12, 10],
    [9, 13, 2],
  ];

  final List<int> heuristic = [10, 9, 7, 8, 6, 5, 4, 3, 2, 1, 0, 2, 3, 4];

  String selectedAlgo = 'Best-First Search';
  final List<String> algoOptions = [
    'Best-First Search',
    'Hill Climbing',
    'A* Search',
    'Branch and Bound',
  ];

  void runAlgorithm() {
    if (selectedAlgo == 'Best-First Search') {
      graph = BestFirstGraph(nodeCount, edges);
      path = graph.bestFirstSearch(startNode, endNode);
    } else if (selectedAlgo == 'Hill Climbing') {
      graph = HillClimbingGraph(nodeCount, edges);
      path = graph.hillClimbing(startNode, endNode);
    } else if (selectedAlgo == 'A* Search') {
      graph = AStarGraph(nodeCount, edges, heuristic, 1);
      path = graph.aStarSearch(startNode, endNode);
    } else if (selectedAlgo == 'Branch and Bound') {
      graph = BranchAndBoundGraph(nodeCount, edges);
      path = graph.branchAndBound(startNode, endNode);
    }
    print("Selected Algorithm: $selectedAlgo");
    print("Start Node: $startNode, End Node: $endNode");
    print("Path: $path");

    // Kiểm tra kiểu dữ liệu của steps và xử lý tương ứng
    print("Steps type: ${graph.steps.runtimeType}");
    print("Steps content: ${graph.steps}");

    if (graph.steps is List<String>) {
      logs = List<String>.from(graph.steps);
    } else if (graph.steps is List<StepLog>) {
      logs = graph.steps.map((step) => step.toString()).toList();
    } else if (graph.steps is List<dynamic>) {
      logs = graph.steps.map((step) => step.toString()).toList();
    } else {
      logs = [];
    }

    setState(() {});
  }

  List<DropdownMenuItem<int>> buildDropdownItems() {
    return List.generate(
      nodeCount,
      (i) => DropdownMenuItem(value: i, child: Text('Đỉnh $i')),
    );
  }

  @override
  void initState() {
    super.initState();
    runAlgorithm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Best-First Search & Hill Climbing')),
      body: Column(
        children: [
          // Chọn đỉnh + thuật toán
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: startNode,
                    items: buildDropdownItems(),
                    onChanged: (val) {
                      if (val != null) setState(() => startNode = val);
                    },
                    decoration: InputDecoration(labelText: 'Bắt đầu'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: endNode,
                    items: buildDropdownItems(),
                    onChanged: (val) {
                      if (val != null) setState(() => endNode = val);
                    },
                    decoration: InputDecoration(labelText: 'Kết thúc'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: selectedAlgo,
              items:
                  algoOptions
                      .map(
                        (algo) =>
                            DropdownMenuItem(value: algo, child: Text(algo)),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedAlgo = val);
              },
              decoration: InputDecoration(labelText: 'Thuật toán'),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(onPressed: runAlgorithm, child: Text("Chạy")),
          Divider(),

          // Vẽ đồ thị
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(12),
              child: CustomPaint(
                painter: GraphPainter(graph: graph, path: path),
                child: Container(),
              ),
            ),
          ),

          // Log các bước
          Expanded(
            flex: 3,
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: logs.length,
              itemBuilder:
                  (context, index) => Card(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        logs[index],
                        style: TextStyle(fontFamily: 'Courier'),
                      ),
                    ),
                  ),
            ),
          ),
          Divider(),

          // Hiển thị đường đi
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Đường đi: ${path.join(" -> ")}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final dynamic graph;
  final List<int> path;

  GraphPainter({required this.graph, required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    if (graph == null || graph.adj.isEmpty) return;

    final paintNode = Paint()..color = Colors.blue;
    final paintEdge =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 2;
    final paintPath =
        Paint()
          ..color = Colors.red
          ..strokeWidth = 3;

    final radius = 15.0;
    final center = Offset(size.width / 2, size.height / 2);
    final double r = min(size.width, size.height) / 2.5;

    final positions = List<Offset>.generate(graph.n, (i) {
      double angle = 2 * pi * i / graph.n;
      return Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
    });

    for (int u = 0; u < graph.n; u++) {
      for (var edge in graph.adj[u]) {
        int v = edge[0];
        if (u < v) {
          canvas.drawLine(positions[u], positions[v], paintEdge);
        }
      }
    }

    for (int i = 0; i < path.length - 1; i++) {
      int u = path[i];
      int v = path[i + 1];
      canvas.drawLine(positions[u], positions[v], paintPath);
    }

    for (int i = 0; i < graph.n; i++) {
      canvas.drawCircle(positions[i], radius, paintNode);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        positions[i] - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
