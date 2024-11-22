import 'package:flutter/material.dart';

class NavigationIndex extends ChangeNotifier {
  var _index = 0;

  int get getIndex {
    return _index;
  }

  void changeIndex(index) {
    _index = index;
    notifyListeners();
  }
}
