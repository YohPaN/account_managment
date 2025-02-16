import 'package:account_managment/models/base_model.dart';

class Contributor extends BaseModel {
  String username;
  String? state = "PENDING";

  Contributor({
    required this.username,
    this.state,
  }) : super.fromJson({});

  factory Contributor.fromJson(Map<String, dynamic> json, dynamic other) {
    return Contributor(
      username: json["user"]["username"],
      state: json["state"],
    );
  }
}
