import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SleepTrackingPage extends StatefulWidget {
  const SleepTrackingPage({super.key});

  @override
  _SleepTrackingPageState createState() => _SleepTrackingPageState();
}

class _SleepTrackingPageState extends State<SleepTrackingPage> {
  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;
  double sleepQuality = 3.0;
  List<Map<String, dynamic>> sleepRecords = [];
  List<Map<String, dynamic>> tasks = [];
  String warningMessage = "";
  String sleepSuggestion = "";

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('sleepRecords');

      if (data != null && data.isNotEmpty) {
        setState(() {
          sleepRecords = List<Map<String, dynamic>>.from(jsonDecode(data));
        });
      }
    } catch (e) {
      print("Error loading sleep data: $e");
    }
  }

  Future<void> _pickTime(BuildContext context, bool isSleepTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          sleepTime = picked;
        } else {
          wakeTime = picked;
          _calculateSleepQuality();
        }
      });
    }
  }

  void _calculateSleepQuality() {
    if (sleepTime != null && wakeTime != null) {
      int sleepDuration = ((wakeTime!.hour * 60 + wakeTime!.minute) -
              (sleepTime!.hour * 60 + sleepTime!.minute)) ~/
          60;

      if (sleepDuration < 4) {
        sleepQuality = 1.0;
        warningMessage = "Very poor sleep! Try to sleep at least 6-8 hours.";
        sleepSuggestion = "Prioritize rest over late-night tasks.";
      } else if (sleepDuration < 6) {
        sleepQuality = 2.5;
        warningMessage = "Insufficient sleep. Improve your schedule.";
        sleepSuggestion = "Schedule earlier bedtime routines.";
      } else if (sleepDuration <= 8) {
        sleepQuality = 4.0;
        warningMessage = "Good sleep! Keep up the habit.";
        sleepSuggestion = "Maintain this schedule for health.";
      } else {
        sleepQuality = 5.0;
        warningMessage = "Excellent sleep! Well done!";
        sleepSuggestion = "You're doing great!";
      }
      setState(() {});
    }
  }

  void _addTask(String task) {
    setState(() {
      tasks.add({'task': task, 'time': "Unscheduled"});
    });
  }

  void _removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  Widget _buildSleepQualityIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          Icons.star,
          color: index < sleepQuality ? Colors.amber : Colors.grey,
          size: 30,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sleep & Schedule Tracker")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text("Sleep Time"),
                subtitle: Text(sleepTime?.format(context) ?? "Select time"),
                trailing: const Icon(Icons.bedtime),
                onTap: () => _pickTime(context, true),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text("Wake Time"),
                subtitle: Text(wakeTime?.format(context) ?? "Select time"),
                trailing: const Icon(Icons.wb_sunny),
                onTap: () => _pickTime(context, false),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Sleep Quality"),
            _buildSleepQualityIcons(),
            if (warningMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  warningMessage,
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            if (sleepSuggestion.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  sleepSuggestion,
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              decoration:
                  InputDecoration(hintText: "Enter your next day's task"),
              onSubmitted: (value) {
                _addTask(value);
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    title: Text(task['task']),
                    subtitle: Text("Scheduled Time: ${task['time']}"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTask(index),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
