class ValidationHelper {
  static String? notNullAndNotEmpty(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  static String? valideTextOnly(value) {
    RegExp regExp = RegExp(r'^[a-zA-Z]+$');
    if (!regExp.hasMatch(value) && (value != null || !value.isEmpty)) {
      return 'Please enter only text';
    }
    return null;
  }

  static String? valideEmail(value) {
    RegExp regExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regExp.hasMatch(value)) {
      return 'Please enter valid email';
    }
    return null;
  }

  static String? validDouble(value) {
    try {
      double.parse(value);
      return null;
    } catch (e) {
      return "It must be a valid number";
    }
  }

  //TODO: validate number and digit for name for exemple
  //TODO: validation for username because it could have special char ? and digit
  //TODO: can chain validation method
}
