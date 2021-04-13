import 'package:flutter/material.dart';

class Token extends ChangeNotifier {
  /// Internal, private state of the cart.
  String _token;
  void changeToken(String token) {
    _token = token;
    notifyListeners();
  }

  void removeToken(String token) {
    _token = "";
    notifyListeners();
  }

  String getToken() {
    return _token;
  }
}
