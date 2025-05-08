import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_application_1/best_first.dart';
import 'package:flutter_application_1/hill_climbing.dart';
import 'package:flutter_application_1/a_star.dart';
import 'package:flutter_application_1/branch_and_bound.dart';

enum SearchAlgorithm { bestFirst, hillClimbing, aStar, branchAndBound }

extension AlgoName on SearchAlgorithm {
  String get label {
    switch (this) {
      case SearchAlgorithm.bestFirst:
        return 'Best-First Search';
      case SearchAlgorithm.hillClimbing:
        return 'Hill Climbing';
      case SearchAlgorithm.aStar:
        return 'A* Search';
      case SearchAlgorithm.branchAndBound:
        return 'Branch and Bound';
    }
  }
}

class GraphSearchScreen extends StatefulWidget {
  const GraphSearchScreen({super.key});
  @override
  _GraphSearchScreenState createState() => _GraphSearchScreenState();
}

class _GraphSearchScreenState extends State<GraphSearchScreen> {
  final int nodeCount = 14;
  final List<int> heuristic = [10, 9, 7, 8, 6, 5, 4, 3, 2, 1, 0, 2, 3, 4];
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

  int startNode = 0;
  int endNode = 10;
  SearchAlgorithm selectedAlgo = SearchAlgorithm.bestFirst;

  List<String> logs = [];
  List<int> path = [];
  dynamic graph;

  @override
  void initState() {
    super.initState();
    runAlgorithm();
  }

  void runAlgorithm() {
    switch (selectedAlgo) {
      case SearchAlgorithm.bestFirst:
        graph = BestFirstGraph(nodeCount, edges);
        path = graph.bestFirstSearch(startNode, endNode);
        break;
      case SearchAlgorithm.hillClimbing:
        graph = HillClimbingGraph(nodeCount, edges);
        path = graph.hillClimbing(startNode, endNode);
        break;
      case SearchAlgorithm.aStar:
        graph = AStarGraph(nodeCount, edges, heuristic, 1);
        path = graph.aStarSearch(startNode, endNode);
        break;
      case SearchAlgorithm.branchAndBound:
        graph = BranchAndBoundGraph(nodeCount, edges);
        path = graph.branchAndBound(startNode, endNode);
        break;
    }

    logs = (graph.steps as List).map((e) => e.toString()).toList();
    setState(() {});
  }

  List<DropdownMenuItem<int>> get nodeItems => List.generate(
    nodeCount,
    (i) => DropdownMenuItem(value: i, child: Text('Đỉnh $i')),
  );

  List<DropdownMenuItem<SearchAlgorithm>> get algoItems =>
      SearchAlgorithm.values
          .map((algo) => DropdownMenuItem(value: algo, child: Text(algo.label)))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm trên đồ thị')),
      body: Column(
        children: [
          _buildControls(),
          ElevatedButton(onPressed: runAlgorithm, child: Text("Chạy")),
          Divider(),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CustomPaint(
                painter: GraphPainter(graph: graph, path: path),
                child: Container(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView.builder(
              itemCount: logs.length,
              padding: EdgeInsets.all(8),
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

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: startNode,
                  items: nodeItems,
                  onChanged: (val) => setState(() => startNode = val ?? 0),
                  decoration: InputDecoration(labelText: 'Bắt đầu'),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: endNode,
                  items: nodeItems,
                  onChanged: (val) => setState(() => endNode = val ?? 0),
                  decoration: InputDecoration(labelText: 'Kết thúc'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<SearchAlgorithm>(
            value: selectedAlgo,
            items: algoItems,
            onChanged: (val) => setState(() => selectedAlgo = val!),
            decoration: InputDecoration(labelText: 'Thuật toán'),
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
