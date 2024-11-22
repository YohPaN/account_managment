class RepoResponse {
  Map<String, dynamic>? data;
  bool success = false;
  String message;

  RepoResponse({
    this.data,
    required this.success,
    required this.message,
  });
}
