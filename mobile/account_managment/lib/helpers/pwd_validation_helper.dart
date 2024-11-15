class PwdValidationHelper {
  static final Map<String, Function> passwordRulesFunction = {
    "atLeast8Char": atLeast8Char,
    "atLeastLowerCase": atLeastLowerCase,
    "atLeastUpperCase": atLeastUpperCase,
    "atLeastDigit": atLeastDigit,
    "atLeastSpecialChar": atLeastSpecialChar,
  };

  static String? validatePassword(
      {required String password,
      String? comparisonSame,
      String? comparisonDifferent}) {
    List<String> returnList = [];
    for (var passwordRuleFunction in passwordRulesFunction.values) {
      final result = passwordRuleFunction(password);

      if (result != null) {
        returnList.add(result);
      }
    }

    if (comparisonSame != null && comparisonSame != password) {
      returnList.add("You must provide the same password");
    }

    if (comparisonDifferent != null && comparisonDifferent == password) {
      returnList.add("You current password is the same");
    }

    if (returnList.isNotEmpty) {
      return returnList.join('\n');
    }

    return null;
  }

  static String? atLeast8Char(value) {
    RegExp regExp = RegExp(r'^.{8,}$');
    if (!regExp.hasMatch(value)) {
      return '- Your password must contain 8 characteres';
    }
    return null;
  }

  static String? atLeastLowerCase(value) {
    RegExp regExp = RegExp(r'(?=.*[a-z])');
    if (!regExp.hasMatch(value)) {
      return '- Your password must contain a lower case characteres';
    }
    return null;
  }

  static String? atLeastUpperCase(value) {
    RegExp regExp = RegExp(r'(?=.*[A-Z])');
    if (!regExp.hasMatch(value)) {
      return '- Your password must contain a upper case characteres';
    }
    return null;
  }

  static String? atLeastDigit(value) {
    RegExp regExp = RegExp(r'(?=.*\d)');
    if (!regExp.hasMatch(value)) {
      return '- Your password must contain one digit';
    }
    return null;
  }

  static String? atLeastSpecialChar(value) {
    RegExp regExp = RegExp(r'(?=.*[@$!%*?&])');
    if (!regExp.hasMatch(value)) {
      return '- Your password must contain a special charactere';
    }
    return null;
  }
}
