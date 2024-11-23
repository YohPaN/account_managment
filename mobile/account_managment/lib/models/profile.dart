class Profile {
  String firstName;
  String lastName;
  double? salary;

  Profile({
    required this.firstName,
    required this.lastName,
    this.salary,
  });

// TODO: use factory ?
  static Profile deserialize(jsonProfile) {
    return Profile(
        firstName: jsonProfile["first_name"],
        lastName: jsonProfile["last_name"],
        salary: double.parse(jsonProfile["salary"]));
  }

  static Profile updateData(jsonProfile, Profile profile) {
    return Profile(
        firstName: jsonProfile["first_name"] ?? profile.firstName,
        lastName: jsonProfile["last_name"] ?? profile.lastName,
        salary: jsonProfile["salary"] ?? profile.salary);
  }
}
