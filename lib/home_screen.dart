import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task/add_edit_reminder_screen.dart';
import 'package:task/color_constant.dart';
import 'package:task/models/priority_model.dart' as task_priority;
import 'package:task/models/reminder.dart';
import 'package:task/providers/reminder_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  task_priority.Priority? _filterPriority;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          PopupMenuButton<task_priority.Priority>(
            onSelected: (priority) {
              setState(() {
                _filterPriority = priority;
              });
            },
            itemBuilder: (context) => task_priority.Priority.values
                .map((priority) => PopupMenuItem(
                      value: priority,
                      child: Text(priority.toString().split('.').last),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: ColorConstants.linearGradientColor5)),
        child: Consumer<ReminderProvider>(
          builder: (context, reminderProvider, child) {
            List<Reminder> reminders = reminderProvider.reminders;
            if (_filterPriority != null) {
              reminders = reminders
                  .where((reminder) => reminder.priority == _filterPriority)
                  .toList();
            }
            reminders
                .sort((a, b) => a.priority.index.compareTo(b.priority.index));

            return ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return ListTile(
                  textColor: Colors.white,
                  title: Text(reminder.title),
                  subtitle: Text(reminder.description),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      reminderProvider.deleteReminder(index);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditReminderScreen(
                          reminder: reminder,
                          index: index,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditReminderScreen(),
            ),
          );
        },
      ),
    );
  }
}
