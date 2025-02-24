import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

class ProgressTrackerPage extends StatefulWidget {
  const ProgressTrackerPage({super.key});

  @override
  _ProgressTrackerPageState createState() => _ProgressTrackerPageState();
}

class _ProgressTrackerPageState extends State<ProgressTrackerPage> {
  List<int> _moodData = [];
  List<String> _moodLabels = ['😞', '😐', '😊'];

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _moodData = (prefs
              .getStringList('mood_data')
              ?.map((e) => int.parse(e))
              .toList() ??
          []);
    });
  }

  Future<void> _saveMood(int mood) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _moodData.add(mood);
    });
    await prefs.setStringList(
        'mood_data', _moodData.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress Tracker"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "How was your day?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (index) {
                return IconButton(
                  icon: Text(
                    _moodLabels[index],
                    style: const TextStyle(fontSize: 30),
                  ),
                  onPressed: () => _saveMood(index),
                );
              }),
            ),
            const SizedBox(height: 20),
            _moodData.isEmpty
                ? const Center(
                    child: Text(
                      "No mood logs yet. Start tracking today!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(_moodData.length, (index) {
                              return FlSpot(index.toDouble(),
                                  _moodData[index].toDouble());
                            }),
                            isCurved: true,
                            gradient: LinearGradient(
                                colors: [Colors.blueGrey, Colors.lightBlue]),
                            barWidth: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
