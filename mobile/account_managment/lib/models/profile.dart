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
      salary: double.parse(
        jsonProfile["salary"],
      ),
    );
  }
}
