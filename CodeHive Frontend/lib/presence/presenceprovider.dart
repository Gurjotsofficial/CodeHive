import 'package:flutter/material.dart';

class PresenceProvider extends ChangeNotifier {

  List<String> activeUsers = [];

  void updatePresence(List<String> users) {
    activeUsers = users;
    notifyListeners();
  }

  void clearPresence() {
    activeUsers = [];
    notifyListeners();
  }

}