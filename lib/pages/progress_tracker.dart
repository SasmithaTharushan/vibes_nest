import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../models/wellness_models.dart';
import '../services/app_services.dart';

class ProgressTrackerPage extends StatelessWidget {
  const ProgressTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppServices.repo(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<MoodEntry>>(
        stream: repo.watchMoods(),
        builder: (context, snapshot) {
          final moods = snapshot.data ?? const <MoodEntry>[];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'How are you feeling right now?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < MoodEntry.labels.length; i++)
                    IconButton(
                      tooltip: const ['Low', 'Okay', 'Good'][i],
                      icon: Text(MoodEntry.labels[i],
                          style: const TextStyle(fontSize: 36)),
                      onPressed: () async {
                        await repo.addMood(i);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mood saved')));
                        }
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (snapshot.hasError)
                const Text('Could not load your moods. Check your connection.',
                    textAlign: TextAlign.center)
              else if (!snapshot.hasData)
                const Center(child: CircularProgressIndicator())
              else if (moods.isEmpty)
                const Text('No mood logs yet. Start tracking today!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey))
              else ...[
                Text('Last ${moods.length} check-ins',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(height: 200, child: _MoodChart(moods: moods)),
                const SizedBox(height: 24),
                const Text('History',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                for (final m in moods.reversed.take(10))
                  ListTile(
                    dense: true,
                    leading: Text(MoodEntry.labels[m.mood],
                        style: const TextStyle(fontSize: 24)),
                    title: Text(
                        DateFormat('EEE d MMM, h:mm a').format(m.createdAt)),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _MoodChart extends StatelessWidget {
  const _MoodChart({required this.moods});

  final List<MoodEntry> moods;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 2,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                  MoodEntry.labels[value.round().clamp(0, 2)],
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < moods.length; i++)
                FlSpot(i.toDouble(), moods[i].mood.toDouble()),
            ],
            isCurved: true,
            preventCurveOverShooting: true,
            gradient: const LinearGradient(
                colors: [Colors.blueGrey, Colors.lightBlue]),
            barWidth: 4,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
