import 'package:shared_preferences/shared_preferences.dart';

import '../data/wellness_repository.dart';

/// Copies data saved on the device by older versions of the app (before
/// accounts existed) into the user's cloud account, once.
class LocalMigration {
  static const _journalKey = 'journal_entries';
  static const _moodKey = 'mood_data';
  static const _oldProfileKeys = [
    'profile_name',
    'profile_email',
    'profile_signed_in',
  ];

  /// Returns how many items were moved to the cloud.
  static Future<int> run(WellnessRepository repo) async {
    final prefs = await SharedPreferences.getInstance();
    var moved = 0;

    final journal = prefs.getStringList(_journalKey) ?? const [];
    // Stored newest first; give older notes older timestamps to keep order.
    final now = DateTime.now();
    for (var i = 0; i < journal.length; i++) {
      final text = journal[i].trim();
      if (text.isEmpty) continue;
      await repo.addJournal(text, at: now.subtract(Duration(minutes: i)));
      moved++;
    }

    final moods = prefs.getStringList(_moodKey) ?? const [];
    for (var i = 0; i < moods.length; i++) {
      final mood = int.tryParse(moods[i]);
      if (mood == null || mood < 0 || mood > 2) continue;
      // Old moods had no dates: space them one day apart, ending today.
      await repo.addMood(mood,
          at: now.subtract(Duration(days: moods.length - 1 - i)));
      moved++;
    }

    await prefs.remove(_journalKey);
    await prefs.remove(_moodKey);
    for (final k in _oldProfileKeys) {
      await prefs.remove(k);
    }
    return moved;
  }
}
