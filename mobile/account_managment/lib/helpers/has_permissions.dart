class HasPermissions {
  static Map<String, List<dynamic>> permissionsMap = {
    "create": [
      "add",
    ],
    "updateOrDelete": [
      "change",
      "delete",
    ],
    "update": [
      "change",
    ],
    "delete": [
      "delete",
    ],
  };

  static bool hasPermissions(
      {required String ressource,
      required String action,
      required List<dynamic> permissions,
      bool strict = true}) {
    final List<dynamic> permissionsNeeded = permissionsMap[action]!;

    if (permissions.contains("owner")) {
      return true;
    }
    final permissionRessource =
        permissionsNeeded.map((permission) => "${permission}_$ressource");

    if (!strict) {
      return permissionRessource.any(permissions.contains);
    }

    return permissionRessource.every(permissions.contains);
  }

  static bool hasSpecificPerm(
      {required String permission, required List<dynamic> permissions}) {
    if (permissions.contains("owner")) {
      return true;
    }
    return permissions.contains(permission);
  }
}
