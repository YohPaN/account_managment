class Account {
  int id;
  String name;
  String? total;

  Account({
    required this.id,
    required this.name,
    this.total,
  });
}
