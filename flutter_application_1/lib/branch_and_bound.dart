import 'package:collection/collection.dart';

class BranchAndBoundGraph {
  final int n;
  final List<List<List<int>>> adj;
  List<bool> visited = [];
  List<String> steps = [];

  BranchAndBoundGraph(this.n, List<List<int>> edges)
    : adj = List.generate(n, (_) => []) {
    for (var edge in edges) {
      int u = edge[0], v = edge[1], cost = edge[2];
      adj[u].add([v, cost]);
      adj[v].add([u, cost]);
    }
  }

  List<int> branchAndBound(int src, int target) {
    visited = List.filled(n, false);
    steps.clear();
    List<int> path = [];
    int step = 1;

    // PriorityQueue to store paths with their costs
    PriorityQueue<List<dynamic>> pq = PriorityQueue<List<dynamic>>(
      (a, b) => a[0].compareTo(b[0]),
    ); // Compare by cost
    pq.add([
      0,
      [src],
    ]); // Initial path with cost 0

    while (pq.isNotEmpty) {
      var current = pq.removeFirst();
      int cost = current[0];
      List<int> currentPath = current[1];
      int node = currentPath.last;

      String log = "--- Bước $step ---\n";
      log += "Đang xét đường đi: $currentPath (cost: $cost)\n";

      if (node == target) {
        log += "Đã đến đích với đường đi tối ưu!";
        steps.add(log);
        path = currentPath;
        break;
      }

      if (!visited[node]) {
        visited[node] = true;

        log += "Các đỉnh kề (chưa duyệt):\n";
        for (var neighbor in adj[node]) {
          int neighborNode = neighbor[0];
          int edgeCost = neighbor[1];
          if (!visited[neighborNode]) {
            List<int> newPath = List.from(currentPath)..add(neighborNode);
            pq.add([cost + edgeCost, newPath]);
            log +=
                "  - Đỉnh $neighborNode với cost = ${cost + edgeCost}, đường đi: $newPath\n";
          }
        }
      }

      steps.add(log);
      step++;
    }

    return path;
  }
}
