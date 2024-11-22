class RepoResponse {
  Map<String, dynamic>? data;
  bool success = false;
  String? error;

  RepoResponse({
    this.data,
    required this.success,
    this.error,
  });
}
