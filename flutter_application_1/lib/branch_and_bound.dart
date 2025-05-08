import 'package:collection/collection.dart';

class BranchAndBoundGraph {
  final int n;
  final List<List<List<int>>> adj;
  List<bool> visited = [];
  List<String> steps = [];

  BranchAndBoundGraph(this.n, List<List<int>> edges)
    : adj = List.generate(n, (_) => []) {
    _buildGraph(edges);
  }

  void _buildGraph(List<List<int>> edges) {
    for (var edge in edges) {
      int u = edge[0], v = edge[1], cost = edge[2];
      adj[u].add([v, cost]);
      adj[v].add([u, cost]); // Đồ thị vô hướng
    }
  }

  void _logStep(int step, String message) {
    steps.add('--- Bước $step ---\n$message');
  }

  List<int> branchAndBound(int src, int target) {
    visited = List.filled(n, false);
    steps.clear();
    List<int> optimalPath = [];
    int step = 1;

    // Ưu tiên đường đi có tổng cost nhỏ nhất
    final pq = PriorityQueue<MapEntry<int, List<int>>>(
      (a, b) => a.key.compareTo(b.key),
    );
    pq.add(MapEntry(0, [src]));

    while (pq.isNotEmpty) {
      final entry = pq.removeFirst();
      final cost = entry.key;
      final path = entry.value;
      final node = path.last;

      String log = "Đang xét đường đi: $path (cost: $cost)\n";

      if (node == target) {
        log += "Đã đến đích với đường đi tối ưu!";
        _logStep(step, log);
        optimalPath = path;
        break;
      }

      if (!visited[node]) {
        visited[node] = true;
        log += "Các đỉnh kề (chưa duyệt):\n";

        for (var neighbor in adj[node]) {
          int neighborNode = neighbor[0];
          int edgeCost = neighbor[1];

          if (!visited[neighborNode]) {
            final newPath = List<int>.from(path)..add(neighborNode);
            final newCost = cost + edgeCost;
            pq.add(MapEntry(newCost, newPath));
            log +=
                "  - Đỉnh $neighborNode (cost: $newCost), đường đi: $newPath\n";
          }
        }
      }

      // Ghi lại trạng thái của danh sách mở sau mỗi bước
      String openListLog = "Danh sách mở: ";
      openListLog += pq
          .toList()
          .map((entry) => "[cost: ${entry.key}, path: ${entry.value}]")
          .join(", ");
      log += openListLog;

      _logStep(step, log);
      step++;
    }

    return optimalPath;
  }
}
