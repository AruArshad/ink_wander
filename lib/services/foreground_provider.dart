import 'package:flutter/material.dart';

class AppForegroundState extends ChangeNotifier {
  bool _isForeground = false;

  bool get isForeground => _isForeground;

  void setIsForeground(bool value) {
    _isForeground = value;
    notifyListeners();
  }
}
