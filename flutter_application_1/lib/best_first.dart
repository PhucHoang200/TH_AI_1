import 'package:collection/collection.dart';

class BestFirstGraph {
  int n;
  List<List<List<int>>> adj;
  List<bool> visited = [];
  List<String> steps = []; // Sửa thành List<String>
  PriorityQueue<List<int>> pq;

  BestFirstGraph(this.n, List<List<int>> edges)
    : adj = List.generate(n, (_) => []),
      pq = PriorityQueue<List<int>>((a, b) => a[0].compareTo(b[0])) {
    for (var edge in edges) {
      int u = edge[0], v = edge[1], cost = edge[2];
      adj[u].add([v, cost]);
      adj[v].add([u, cost]);
    }
  }

  List<int> bestFirstSearch(int src, int target) {
    visited = List.filled(n, false);
    pq.clear();
    steps.clear();
    List<int> path = [];
    int step = 1;

    pq.add([0, src]);
    visited[src] = true;

    while (pq.isNotEmpty) {
      var current = pq.removeFirst();
      int cost = current[0], node = current[1];
      path.add(node);

      String log = "--- Bước $step ---\n";
      log += "Đang xét đỉnh: $node (cost: $cost)\n";

      if (node == target) {
        log += "Đã đến đích!";
        steps.add(log); // Sửa thành steps.add(log)
        break;
      }

      log += "Các đỉnh kề (chưa duyệt):\n";
      for (var neighborInfo in adj[node]) {
        int neighbor = neighborInfo[0];
        int edgeCost = neighborInfo[1];
        if (!visited[neighbor]) {
          visited[neighbor] = true;
          pq.add([edgeCost, neighbor]);
          log += "  - Đỉnh $neighbor với cost = $edgeCost\n";
        }
      }

      var openList = pq.toList()..sort((a, b) => a[0].compareTo(b[0]));
      log += "Danh sách mở: $openList\n";
      steps.add(log); // Sửa thành steps.add(log)
      step++;
    }

    return path;
  }
}
