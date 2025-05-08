class HillClimbingGraph {
  final int n;
  final List<List<List<int>>> adj;
  List<bool> visited = [];
  List<String> steps = [];

  HillClimbingGraph(this.n, List<List<int>> edges)
    : adj = List.generate(n, (_) => []) {
    _buildGraph(edges);
  }

  void _buildGraph(List<List<int>> edges) {
    for (var edge in edges) {
      int u = edge[0], v = edge[1], cost = edge[2];
      adj[u].add([v, cost]);
      adj[v].add([u, cost]);
    }
  }

  void _logStep(int step, String message) {
    steps.add("--- Bước $step ---\n$message");
  }

  List<int> hillClimbing(int src, int target) {
    visited = List.filled(n, false);
    steps.clear();
    List<int> path = [];
    int step = 1;
    int current = src;
    path.add(current);
    visited[current] = true;

    while (true) {
      StringBuffer log = StringBuffer("Đang xét đỉnh: $current\n");

      if (current == target) {
        log.write("Đã đến đích!");
        _logStep(step, log.toString());
        break;
      }

      List<List<int>> neighbors = _getUnvisitedNeighbors(current);

      if (neighbors.isEmpty) {
        log.write(
          "Không còn lựa chọn tốt hơn -> Dừng lại (local maximum hoặc dead end)",
        );
        _logStep(step, log.toString());
        break;
      }

      log.write("Các đỉnh kề chưa duyệt:\n");
      for (var n in neighbors) {
        log.write("  - Đỉnh ${n[1]} với cost = ${n[0]}\n");
      }

      neighbors.sort((a, b) => a[0].compareTo(b[0]));

      log.write("Sau khi sắp xếp theo cost tăng dần:\n");
      for (var n in neighbors) {
        log.write("  - Đỉnh ${n[1]} với cost = ${n[0]}\n");
      }

      int nextNode = neighbors[0][1];
      int nextCost = neighbors[0][0];

      log.write("Chọn đỉnh $nextNode có cost nhỏ nhất = $nextCost");

      _logStep(step, log.toString());

      current = nextNode;
      path.add(current);
      visited[current] = true;
      step++;
    }

    return path;
  }

  List<List<int>> _getUnvisitedNeighbors(int current) {
    List<List<int>> neighbors = [];
    for (var neighborInfo in adj[current]) {
      int neighbor = neighborInfo[0];
      int cost = neighborInfo[1];
      if (!visited[neighbor]) {
        neighbors.add([cost, neighbor]);
      }
    }
    return neighbors;
  }
}
