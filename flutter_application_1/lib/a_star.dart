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
  final int n;
  final List<List<Neighbor>> adj;
  final List<int> heuristic;
  List<bool> visited;
  List<int> path;
  int step;
  List<StepLog> steps = [];
  PriorityQueue<AStarNode> pq;

  AStarGraph(this.n, List<List<int>> edges, this.heuristic, this.step)
    : assert(heuristic.length == n, 'Heuristic phải có độ dài bằng số đỉnh'),
      adj = List.generate(n, (_) => []),
      visited = List.filled(n, false),
      path = [],
      steps = [],
      pq = PriorityQueue<AStarNode>((a, b) => a.fCost.compareTo(b.fCost)) {
    // Xây dựng đồ thị từ danh sách các cạnh
    for (var edge in edges) {
      int u = edge[0], v = edge[1], cost = edge[2];
      adj[u].add(Neighbor(v, cost));
      adj[v].add(Neighbor(u, cost));
    }
  }

  void reset() {
    path.clear();
    visited = List.filled(n, false);
    step = 1;
    pq.clear();
    steps.clear(); // Xóa danh sách các bước
  }

  List<int> aStarSearch(int src, int target) {
    reset();
    pq.add(
      AStarNode(heuristic[src], 0, src),
    ); // f_cost = heuristic[src], g_cost = 0
    visited[src] = true;

    while (pq.isNotEmpty) {
      var current = pq.removeFirst();
      int fCost = current.fCost, gCost = current.gCost, node = current.node;
      path.add(node);

      String log = "--- Bước $step ---\n";
      log += "Đang xét đỉnh: $node (g_cost: $gCost, f_cost: $fCost)\n";

      if (node == target) {
        log += "Đã đến đích!";
        steps.add(StepLog(step, log)); // Thêm log dưới dạng StepLog
        break;
      }

      log += "Các đỉnh kề (chưa duyệt):\n";
      for (var neighbor in adj[node]) {
        int newGCost = gCost + neighbor.cost;
        int newFCost = newGCost + heuristic[neighbor.to];

        if (!visited[neighbor.to]) {
          pq.add(AStarNode(newFCost, newGCost, neighbor.to));
          log +=
              "  - Đỉnh ${neighbor.to} với chi phí cạnh = ${neighbor.cost}, g_cost = $newGCost, f_cost = $newFCost\n";
        }
      }

      visited[node] = true; // Đánh dấu sau khi xử lý xong

      var openListSorted =
          pq.toList()..sort((a, b) => a.fCost.compareTo(b.fCost));
      log += "Danh sách mở: $openListSorted\n";
      steps.add(StepLog(step, log)); // Thêm log dưới dạng StepLog
      step++;
    }

    if (path.isEmpty || path.last != target) {
      steps.add(StepLog(step, "Không tìm thấy đường đi từ $src đến $target."));
    }

    return path;
  }
}
