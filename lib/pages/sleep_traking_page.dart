import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../models/wellness_models.dart';
import '../services/app_services.dart';

class SleepTrackingPage extends StatefulWidget {
  const SleepTrackingPage({super.key});

  @override
  State<SleepTrackingPage> createState() => _SleepTrackingPageState();
}

/// Advice for a night's sleep, based on hours slept.
({String message, String tip, Color color}) sleepAdvice(double hours) {
  if (hours < 4) {
    return (
      message: 'Very little sleep. Try to get 7–9 hours.',
      tip: 'Prioritise rest over late-night tasks tonight.',
      color: Colors.red,
    );
  }
  if (hours < 6) {
    return (
      message: 'Not quite enough sleep.',
      tip: 'Try an earlier, screen-free wind-down routine.',
      color: Colors.orange,
    );
  }
  if (hours < 7) {
    return (
      message: 'Almost there!',
      tip: 'An extra 30–60 minutes could make a real difference.',
      color: Colors.amber.shade800,
    );
  }
  if (hours <= 9) {
    return (
      message: 'Great sleep! Keep it up.',
      tip: 'A consistent bedtime keeps this going.',
      color: Colors.green,
    );
  }
  return (
    message: 'Long sleep.',
    tip: 'Oversleeping can leave you groggy. Aim for 7–9 hours.',
    color: Colors.blueGrey,
  );
}

class _SleepTrackingPageState extends State<SleepTrackingPage> {
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;
  final _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isBedTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isBedTime ? _bedTime : _wakeTime) ??
          (isBedTime
              ? const TimeOfDay(hour: 23, minute: 0)
              : const TimeOfDay(hour: 7, minute: 0)),
    );
    if (picked == null) return;
    setState(() => isBedTime ? _bedTime = picked : _wakeTime = picked);
  }

  ({DateTime bed, DateTime wake})? get _night {
    if (_bedTime == null || _wakeTime == null) return null;
    return resolveNight(
      bedHour: _bedTime!.hour,
      bedMinute: _bedTime!.minute,
      wakeHour: _wakeTime!.hour,
      wakeMinute: _wakeTime!.minute,
    );
  }

  Future<void> _saveNight() async {
    final night = _night;
    if (night == null) return;
    await AppServices.repo(context).addSleep(night.bed, night.wake);
    if (!mounted) return;
    setState(() {
      _bedTime = null;
      _wakeTime = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Sleep saved')));
  }

  Future<void> _addTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    _taskController.clear();
    await AppServices.repo(context).addTask(text);
  }

  Widget _stars(int quality) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Icon(Icons.star,
              color: i < quality ? Colors.amber : Colors.grey.shade300,
              size: 22),
        ),
      );

  String _formatHours(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final repo = AppServices.repo(context);
    final night = _night;
    final preview = night == null
        ? null
        : SleepEntry(
            id: '', bedTime: night.bed, wakeTime: night.wake,
            createdAt: DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Sleep & Tomorrow')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Log last night',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: const Text('Went to bed'),
              subtitle: Text(_bedTime?.format(context) ?? 'Select time'),
              trailing: const Icon(Icons.bedtime),
              onTap: () => _pickTime(true),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Woke up'),
              subtitle: Text(_wakeTime?.format(context) ?? 'Select time'),
              trailing: const Icon(Icons.wb_sunny),
              onTap: () => _pickTime(false),
            ),
          ),
          if (preview != null) ...[
            const SizedBox(height: 12),
            Builder(builder: (context) {
              final advice = sleepAdvice(preview.hours);
              return Card(
                color: advice.color.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(_formatHours(preview.hours),
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                      _stars(preview.quality),
                      const SizedBox(height: 8),
                      Text(advice.message,
                          style: TextStyle(
                              color: advice.color,
                              fontWeight: FontWeight.bold)),
                      Text(advice.tip, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _saveNight,
                        icon: const Icon(Icons.save),
                        label: const Text('Save this night'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          const SizedBox(height: 24),
          const Text('Recent nights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          StreamBuilder<List<SleepEntry>>(
            stream: repo.watchSleep(),
            builder: (context, snapshot) {
              final nights = snapshot.data ?? const <SleepEntry>[];
              if (!snapshot.hasData) {
                return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()));
              }
              if (nights.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No nights logged yet.',
                      style: TextStyle(color: Colors.grey)),
                );
              }
              final avg = nights.map((n) => n.hours).reduce((a, b) => a + b) /
                  nights.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Average: ${_formatHours(avg)} a night'),
                  ),
                  for (final n in nights)
                    Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => repo.deleteSleep(n.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                            DateFormat('EEE d MMM').format(n.wakeTime)),
                        subtitle: Text(
                            '${DateFormat.jm().format(n.bedTime)} → ${DateFormat.jm().format(n.wakeTime)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatHours(n.hours),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            _stars(n.quality),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text("Tomorrow's tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _taskController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addTask(),
            decoration: InputDecoration(
              hintText: 'Add a task so it stops spinning in your head',
              suffixIcon: IconButton(
                  icon: const Icon(Icons.add), onPressed: _addTask),
            ),
          ),
          StreamBuilder<List<TaskItem>>(
            stream: repo.watchTasks(),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? const <TaskItem>[];
              return Column(
                children: [
                  for (final t in tasks)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: t.done,
                      onChanged: (v) => repo.setTaskDone(t.id, v ?? false),
                      title: Text(
                        t.text,
                        style: TextStyle(
                          decoration:
                              t.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      secondary: IconButton(
                        tooltip: 'Delete task',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => repo.deleteTask(t.id),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
