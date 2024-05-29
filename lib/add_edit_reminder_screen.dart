import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:task/color_constant.dart';
import 'package:task/models/priority_model.dart' as task_priority;
import 'package:task/models/reminder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task/providers/reminder_provider.dart';
import 'main.dart';
import 'package:timezone/timezone.dart' as tz;

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder;
  final int? index;

  const AddEditReminderScreen({Key? key, this.reminder, this.index})
      : super(key: key);

  @override
  _AddEditReminderScreenState createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  task_priority.Priority _priority = task_priority.Priority.Low;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _title = widget.reminder!.title;
      _description = widget.reminder!.description;
      _date = widget.reminder!.time;
      _time = TimeOfDay.fromDateTime(widget.reminder!.time);
      _priority = widget.reminder!.priority;
    } else {
      _title = '';
      _description = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: ColorConstants.linearGradientColor5)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _title,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.white)),
                  onSaved: (value) {
                    _title = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _description,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.white)),
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Date: ${_date.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _date) {
                          setState(() {
                            _date = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Time: ${_time.format(context)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: _time,
                        );
                        if (picked != null && picked != _time) {
                          setState(() {
                            _time = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
                DropdownButtonFormField<task_priority.Priority>(
                  value: _priority,
                  dropdownColor: ColorConstants.darkred,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Priority',
                      labelStyle: TextStyle(color: Colors.white)),
                  onChanged: (task_priority.Priority? newValue) {
                    setState(() {
                      _priority = newValue!;
                    });
                  },
                  items: task_priority.Priority.values
                      .map((task_priority.Priority classType) {
                    return DropdownMenuItem<task_priority.Priority>(
                      value: classType,
                      child: Text(classType.toString().split('.').last),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final reminder = Reminder(
                        title: _title,
                        description: _description,
                        time: DateTime(
                          _date.year,
                          _date.month,
                          _date.day,
                          _time.hour,
                          _time.minute,
                        ),
                        priority: _priority,
                      );

                      if (widget.reminder == null) {
                        Provider.of<ReminderProvider>(context, listen: false)
                            .addReminder(reminder);
                      } else {
                        Provider.of<ReminderProvider>(context, listen: false)
                            .updateReminder(widget.index!, reminder);
                      }

                      await _scheduleNotification(reminder);

                      Navigator.pop(context);
                    }
                  },
                  child: Text(widget.reminder == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminder Channel',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      reminder.time.year,
      reminder.time.month,
      reminder.time.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      // Attempt to schedule using zonedSchedule
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        reminder.title,
        reminder.description,
        scheduledDate,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      // If zonedSchedule throws an exact_alarms_not_permitted exception, fall back to schedule
      if (e.code == 'exact_alarms_not_permitted') {
        final now = tz.TZDateTime.now(tz.local);
        final difference = scheduledDate.difference(now);
        final seconds = difference.inSeconds.round();
        final scheduledTime = now.add(Duration(seconds: seconds));

        await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          reminder.title,
          reminder.description,
          scheduledTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        print('Failed to schedule notification: $e');
      }
    }
  }
}
