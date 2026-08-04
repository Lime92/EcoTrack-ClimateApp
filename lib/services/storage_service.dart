import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/eco_log_model.dart';

class StorageService {
  static const String _logsKey = 'eco_logs';
  static const String _userPointsKey = 'user_points';
  static const String _completedChallengesKey = 'completed_challenges';
  static const String _lastChallengeDateKey = 'last_challenge_date';

  static String _getTodayDeviceDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static Future<void> saveLog(EcoLogModel log) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsJson = prefs.getStringList(_logsKey) ?? [];

    logsJson.removeWhere((item) {
      final map = jsonDecode(item);
      return map['date'] == log.date;
    });

    logsJson.add(jsonEncode(log.toJson()));
    await prefs.setStringList(_logsKey, logsJson);
  }

  static Future<List<EcoLogModel>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logsJson = prefs.getStringList(_logsKey) ?? [];

    return logsJson
        .map((item) => EcoLogModel.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userPointsKey) ?? 0;
  }

  static Future<void> addPoints(int pts) async {
    final prefs = await SharedPreferences.getInstance();
    int current = await getPoints();
    await prefs.setInt(_userPointsKey, current + pts);
  }

  static Future<List<String>> getCompletedChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDeviceDate();
    final lastDate = prefs.getString(_lastChallengeDateKey) ?? '';

    if (lastDate != todayStr) {
      await prefs.setStringList(_completedChallengesKey, []);
      await prefs.setString(_lastChallengeDateKey, todayStr);
      return [];
    }

    return prefs.getStringList(_completedChallengesKey) ?? [];
  }

  static Future<void> toggleChallenge(String id, int pts) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _getTodayDeviceDate();
    List<String> completed = await getCompletedChallenges();

    if (completed.contains(id)) {
      completed.remove(id);
      await addPoints(-pts);
    } else {
      completed.add(id);
      await addPoints(pts);
    }

    await prefs.setString(_lastChallengeDateKey, todayStr);
    await prefs.setStringList(_completedChallengesKey, completed);
  }
}