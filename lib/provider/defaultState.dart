import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Defaultstate extends ChangeNotifier {
  String name = "";
  String address = "";
  double latitude = 0;
  double longitude = 0;

  DateTime selectedTime = DateTime.now();
  List<String> selectedFriends = [];
  void setName(String input) {
    name = input;
    notifyListeners();
  }

  void setAddress(String input) {
    address = input;
    notifyListeners();
  }

  void setLatitude(double input) {
    latitude = input;
    notifyListeners();
  }

  void setLongitude(double input) {
    longitude = input;
    notifyListeners();
  }

  void setSelectedTime(DateTime time) {
    selectedTime = time;
    notifyListeners();
  }

  void addSelectedFriends(String friend) {
    selectedFriends.add(friend);
    notifyListeners();
  }

  void deleteSelectedFriends(String friend) {
    selectedFriends.remove(friend);
    notifyListeners();
  }
}
