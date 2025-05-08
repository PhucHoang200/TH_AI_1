import 'package:collection/collection.dart';

class Neighbor {
  final int to;
  final int cost;
  Neighbor(this.to, this.cost);
}

class StepLog {
  final int stepNumber;
  final String description;

  StepLog(this.stepNumber, this.description);

  @override
  String toString() => "Step $stepNumber: $description";
}

class AStarNode {
  final int fCost;
  final int gCost;
  final int node;

  AStarNode(this.fCost, this.gCost, this.node);

  @override
  String toString() => '[f:$fCost, g:$gCost, node:$node]';
}

class AStarGraph {
  final int size;
  final List<List<Neighbor>> adjacencyList;
  final List<int> heuristic;

  late List<bool> visited;
  late List<int> path;
  late int step;
  late List<StepLog> steps;
  late PriorityQueue<AStarNode> openSet;
  late List<int?> parent;

  AStarGraph(this.size, List<List<int>> edges, this.heuristic, int initialStep)
    : assert(heuristic.length == size, 'Heuristic phải có độ dài bằng số đỉnh'),
      adjacencyList = List.generate(size, (_) => []) {
    for (var edge in edges) {
      final u = edge[0], v = edge[1], cost = edge[2];
      adjacencyList[u].add(Neighbor(v, cost));
      adjacencyList[v].add(Neighbor(u, cost));
    }
    step = initialStep;
    _initializeSearchState();
  }

  void _initializeSearchState() {
    visited = List.filled(size, false);
    path = [];
    steps = [];
    openSet = PriorityQueue(
      (AStarNode a, AStarNode b) => a.fCost.compareTo(b.fCost),
    );
    parent = List.filled(size, null); // Khởi tạo parent
  }

  void reset() {
    _initializeSearchState();
  }

  List<int> aStarSearch(int start, int goal) {
    reset();
    openSet.add(AStarNode(heuristic[start], 0, start));
    visited[start] = true;

    while (openSet.isNotEmpty) {
      final current = openSet.removeFirst();
      final node = current.node, gCost = current.gCost, fCost = current.fCost;
      path.add(node);

      var logMessage = "--- Bước $step ---\n";
      logMessage += "Đang xét đỉnh: $node (g: $gCost, f: $fCost)\n";

      if (node == goal) {
        logMessage += "Đã đến đích!";
        steps.add(StepLog(step++, logMessage));
        break;
      }

      logMessage += "Các đỉnh kề (chưa duyệt):\n";
      for (var neighbor in adjacencyList[node]) {
        final nextNode = neighbor.to;
        final edgeCost = neighbor.cost;
        final nextG = gCost + edgeCost;
        final nextF = nextG + heuristic[nextNode];

        if (!visited[nextNode]) {
          openSet.add(AStarNode(nextF, nextG, nextNode));
          parent[nextNode] = node; // Lưu lại parent của nextNode
          logMessage +=
              "  - Đỉnh $nextNode, cạnh: $edgeCost, g: $nextG, f: $nextF\n";
        }
      }

      visited[node] = true;

      final openListPreview =
          openSet.toList()..sort((a, b) => a.fCost.compareTo(b.fCost));
      logMessage += "Danh sách mở: $openListPreview\n";
      steps.add(StepLog(step++, logMessage));
    }

    if (path.isEmpty || path.last != goal) {
      steps.add(StepLog(step, "Không tìm thấy đường đi từ $start đến $goal."));
    } else {
      // Truy vết đường đi từ goal về start thông qua parent
      int? current = goal; // Thay đổi kiểu của current thành int?
      List<int> fullPath = [];
      while (current != null) {
        fullPath.add(current);
        current = parent[current];
      }
      path = fullPath.reversed.toList(); // Đảo ngược đường đi từ start -> goal
    }

    return path;
  }
}
