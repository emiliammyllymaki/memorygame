import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static late SharedPreferences _prefs;
  static const String _key = 'completed_levels';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<int> getCompletedLevels() {
    final list = _prefs.getStringList(_key) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  static Future<void> markLevelCompleted(int level) async {
    final completed = getCompletedLevels();
    if (!completed.contains(level)) {
      completed.add(level);
      await _prefs.setStringList(
          _key, completed.map((e) => e.toString()).toList());
    }
  }

  static bool isLevelCompleted(int level) {
    return getCompletedLevels().contains(level);
  }

  static bool isLevelUnlocked(int level) {
    if (level == 1) return true;
    return isLevelCompleted(level - 1);
  }

  static Future<void> resetProgress() async {
    await _prefs.remove(_key);
  }
}
