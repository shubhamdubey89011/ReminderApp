// lib/models/reminder.dart
import 'package:task/models/priority_model.dart';

class Reminder {
  String title;
  String description;
  DateTime time;
  Priority priority;

  Reminder({
    required this.title,
    required this.description,
    required this.time,
    this.priority = Priority.Low,
  });
}
