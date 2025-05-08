import 'package:collection/collection.dart';

class BestFirstGraph {
  final int n;
  final List<List<List<int>>> adj; // Danh sách kề
  final PriorityQueue<List<int>> pq; // Hàng đợi ưu tiên
  List<bool> visited; // Danh sách các đỉnh đã duyệt
  List<String> steps; // Các bước thực hiện

  BestFirstGraph(this.n, List<List<int>> edges)
    : adj = List.generate(n, (_) => []),
      pq = PriorityQueue<List<int>>(
        (a, b) => a[0].compareTo(b[0]),
      ), // Ưu tiên theo chi phí nhỏ nhất
      visited = List.filled(n, false),
      steps = [] {
    _buildGraph(edges); // Xây dựng đồ thị từ danh sách cạnh
  }

  // Xây dựng đồ thị từ các cạnh
  void _buildGraph(List<List<int>> edges) {
    for (var edge in edges) {
      int u = edge[0], v = edge[1], cost = edge[2];
      adj[u].add([v, cost]);
      adj[v].add([u, cost]); // Đồ thị vô hướng
    }
  }

  // Làm mới lại tất cả các trạng thái
  void _reset() {
    visited = List.filled(n, false);
    pq.clear();
    steps.clear();
  }

  // Tìm kiếm Best-First từ đỉnh src đến target
  List<int> bestFirstSearch(int src, int target) {
    _reset(); // Đặt lại các trạng thái ban đầu

    pq.add([0, src]); // Thêm đỉnh bắt đầu vào hàng đợi ưu tiên
    visited[src] = true;
    List<int> path = [];
    int step = 1;

    while (pq.isNotEmpty) {
      var current = pq.removeFirst(); // Lấy đỉnh có chi phí nhỏ nhất
      int cost = current[0], node = current[1];
      path.add(node);

      // Ghi log cho bước hiện tại
      StringBuffer log = StringBuffer("--- Bước $step ---\n");
      log.write("Đang xét đỉnh: $node (cost: $cost)\n");

      // Nếu đã đến đích, dừng thuật toán
      if (node == target) {
        log.write("Đã đến đích!\n");
        steps.add(log.toString()); // Thêm log vào steps
        break;
      }

      log.write("Các đỉnh kề chưa duyệt:\n");
      for (var neighbor in adj[node]) {
        int neighborNode = neighbor[0];
        int edgeCost = neighbor[1];
        if (!visited[neighborNode]) {
          visited[neighborNode] = true;
          pq.add([edgeCost, neighborNode]); // Thêm đỉnh kề vào hàng đợi
          log.write("  - Đỉnh $neighborNode với cost = $edgeCost\n");
        }
      }

      log.write("Danh sách mở: ${pq.toList()}\n"); // Ghi danh sách mở
      steps.add(log.toString()); // Thêm log vào steps
      step++;
    }

    return path; // Trả về đường đi
  }
}
