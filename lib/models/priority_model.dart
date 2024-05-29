// lib/models/priority_model.dart
// ignore_for_file: constant_identifier_names

enum Priority { High, Medium, Low }

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
