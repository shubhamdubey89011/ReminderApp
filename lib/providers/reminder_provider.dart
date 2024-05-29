// lib/providers/remainder_provider.dart
import 'package:flutter/material.dart';
import 'package:task/models/reminder.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => _reminders;

  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  void updateReminder(int index, Reminder reminder) {
    _reminders[index] = reminder;
    notifyListeners();
  }

  void deleteReminder(int index) {
    _reminders.removeAt(index);
    notifyListeners();
  }
}
