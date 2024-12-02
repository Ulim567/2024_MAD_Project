import 'package:flutter/material.dart';

class Defaultstate extends ChangeNotifier {
  String address = "";
  double latitude = 0;
  double longitude = 0;

  DateTime selectedTime = DateTime.now();
  List<String> selectedFriends = [];

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
