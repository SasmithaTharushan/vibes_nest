import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _readDate(Object? value) => value is Timestamp
    ? value.toDate()
    : value is DateTime
        ? value
        : DateTime.now();

/// A single mood check-in. [mood] is 0 (low), 1 (okay) or 2 (good).
class MoodEntry {
  final String id;
  final int mood;
  final DateTime createdAt;

  const MoodEntry({required this.id, required this.mood, required this.createdAt});

  static const labels = ['😞', '😐', '😊'];

  factory MoodEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return MoodEntry(
      id: doc.id,
      mood: (d['mood'] as num?)?.toInt() ?? 1,
      createdAt: _readDate(d['createdAt']),
    );
  }

  Map<String, dynamic> toMap() =>
      {'mood': mood, 'createdAt': Timestamp.fromDate(createdAt)};
}

/// One night of sleep.
class SleepEntry {
  final String id;
  final DateTime bedTime;
  final DateTime wakeTime;
  final DateTime createdAt;

  const SleepEntry({
    required this.id,
    required this.bedTime,
    required this.wakeTime,
    required this.createdAt,
  });

  Duration get duration => wakeTime.difference(bedTime);
  double get hours => duration.inMinutes / 60;

  /// 1–5 stars based on hours slept.
  int get quality {
    final h = hours;
    if (h < 4) return 1;
    if (h < 6) return 2;
    if (h < 7) return 3;
    if (h <= 9) return 5;
    return 4; // more than 9 hours: oversleeping can leave you groggy
  }

  factory SleepEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return SleepEntry(
      id: doc.id,
      bedTime: _readDate(d['bedTime']),
      wakeTime: _readDate(d['wakeTime']),
      createdAt: _readDate(d['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'bedTime': Timestamp.fromDate(bedTime),
        'wakeTime': Timestamp.fromDate(wakeTime),
        'hours': hours,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// A "Let It Go" journal note.
class JournalEntry {
  final String id;
  final String text;
  final DateTime createdAt;

  const JournalEntry({required this.id, required this.text, required this.createdAt});

  factory JournalEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return JournalEntry(
      id: doc.id,
      text: d['text'] as String? ?? '',
      createdAt: _readDate(d['createdAt']),
    );
  }

  Map<String, dynamic> toMap() =>
      {'text': text, 'createdAt': Timestamp.fromDate(createdAt)};
}

/// A to-do item for tomorrow (shown on the sleep page).
class TaskItem {
  final String id;
  final String text;
  final bool done;
  final DateTime createdAt;

  const TaskItem({
    required this.id,
    required this.text,
    required this.done,
    required this.createdAt,
  });

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return TaskItem(
      id: doc.id,
      text: d['text'] as String? ?? '',
      done: d['done'] as bool? ?? false,
      createdAt: _readDate(d['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'done': done,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

/// Works out the real bed and wake times for a night, handling midnight:
/// bed at 23:00 and wake at 07:00 means you woke up the next day.
({DateTime bed, DateTime wake}) resolveNight({
  required int bedHour,
  required int bedMinute,
  required int wakeHour,
  required int wakeMinute,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  var wake = DateTime(today.year, today.month, today.day, wakeHour, wakeMinute);
  var bed = DateTime(today.year, today.month, today.day, bedHour, bedMinute);
  if (!bed.isBefore(wake)) {
    bed = bed.subtract(const Duration(days: 1));
  }
  return (bed: bed, wake: wake);
}

/// A message in the "Talk to Nest" conversation.
class ChatMessage {
  final String id;
  final bool fromUser;
  final String text;

  /// Name of a [CompanionTool] to offer as a button under this reply.
  final String? tool;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.fromUser,
    required this.text,
    required this.createdAt,
    this.tool,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return ChatMessage(
      id: doc.id,
      fromUser: d['role'] == 'user',
      text: d['text'] as String? ?? '',
      tool: d['tool'] as String?,
      createdAt: _readDate(d['createdAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'role': fromUser ? 'user' : 'model',
        'text': text,
        if (tool != null) 'tool': tool,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
