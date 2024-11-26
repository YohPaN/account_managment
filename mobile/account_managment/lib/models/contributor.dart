class Contributor {
  String username;
  String? state = "PENDING";

  Contributor({
    required this.username,
    this.state,
  });

  static Contributor deserialize(jsonContributor) {
    return Contributor(
      username: jsonContributor["user"]["username"],
      state: jsonContributor["state"],
    );
  }
}
