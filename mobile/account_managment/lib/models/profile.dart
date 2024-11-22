class Profile {
  String firstName;
  String lastName;
  double? salary;

  Profile({
    required this.firstName,
    required this.lastName,
    this.salary,
  });

  // factory RepoResponse.fromJson(Map<String, dynamic> parsedJson) {
  //   return RepoResponse(
  //       data: parsedJson['data'],
  //       success: parsedJson['success'],
  //       error: parsedJson['error']);
  // }
}
