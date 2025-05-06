class HillClimbingGraph {
  int n;
  List<List<List<int>>> adj;
  List<bool> visited = [];
  List<String> steps = []; // Sửa thành List<String>

  HillClimbingGraph(this.n, List<List<int>> edges)
    : adj = List.generate(n, (_) => []) {
    for (var edge in edges) {
      int u = edge[0], v = edge[1], cost = edge[2];
      adj[u].add([v, cost]);
      adj[v].add([u, cost]);
    }
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
      String log = "--- Bước $step ---\n";
      log += "Đang xét đỉnh: $current\n";

      if (current == target) {
        log += "Đã đến đích!";
        steps.add(log); // Sửa thành steps.add(log)
        break;
      }

      List<List<int>> neighbors = [];

      for (var neighborInfo in adj[current]) {
        int neighbor = neighborInfo[0];
        int cost = neighborInfo[1];
        if (!visited[neighbor]) {
          neighbors.add([cost, neighbor]);
        }
      }

      if (neighbors.isEmpty) {
        log +=
            "Không còn lựa chọn tốt hơn -> Dừng lại (local maximum hoặc dead end)";
        steps.add(log); // Sửa thành steps.add(log)
        break;
      }

      neighbors.sort((a, b) => a[0].compareTo(b[0]));
      int nextCost = neighbors[0][0];
      int nextNode = neighbors[0][1];

      log += "Chọn đỉnh $nextNode có cost nhỏ nhất = $nextCost\n";
      steps.add(log); // Sửa thành steps.add(log)

      current = nextNode;
      path.add(current);
      visited[current] = true;
      step++;
    }

    return path;
  }
}
