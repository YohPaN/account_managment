class ValidationHelper {
  static final Map<String, Function> rulesFunction = {
    "notEmpty": notEmpty,
    "notNull": notNull,
    "validTextOnly": validTextOnly,
    "validEmail": validEmail,
    "validDouble": validDouble,
    "validTextOrDigitOnly": validTextOrDigitOnly,
    "twoDigitMax": twoDigitMax,
  };

  static String? validateInput(dynamic value, List<String> rules) {
    for (var rule in rules) {
      Function ruleFunction = rulesFunction[rule]!;

      final result = ruleFunction(value);

      if (result != null) {
        return result;
      }
    }
  }

  static String? notEmpty(value) {
    if (value.isEmpty) {
      return 'This field can\'t be empty';
    }
    return null;
  }

  static String? notNull(value) {
    if (value == null) {
      return 'The value can\'t be null';
    }
    return null;
  }

  static String? validTextOnly(value) {
    RegExp regExp = RegExp(r'^[a-zA-Z]+$');
    if (!regExp.hasMatch(value)) {
      return 'Please enter only text';
    }
    return null;
  }

  static String? validTextOrDigitOnly(value) {
    RegExp regExp = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regExp.hasMatch(value)) {
      return 'Please enter only text or numbers';
    }
    return null;
  }

  static String? validEmail(value) {
    RegExp regExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regExp.hasMatch(value)) {
      return 'Please enter valid email';
    }
    return null;
  }

  static String? validDouble(value) {
    if (value != null && value != "") {
      try {
        double.parse(value);
      } catch (e) {
        return "It must be a valid number";
      }
    }

    return null;
  }

  static String? twoDigitMax(value) {
    final comaPlace = value.indexOf('.');
    final numberOfDecimal = value.substring(comaPlace + 1).length;

    if (comaPlace != -1 && numberOfDecimal > 2) {
      return "Value must contain only 2 decimal";
    }
    return null;
  }
}
