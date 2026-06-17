import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _key = 'recent_song_ids';

  static final ValueNotifier<int> historyUpdated = ValueNotifier(0);

  static Future<void> saveSong(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];

    history.remove(id.toString());
    history.insert(0, id.toString());

    if (history.length > 8) history = history.sublist(0, 8);

    await prefs.setStringList(_key, history);
    historyUpdated.value++;
  }

  static Future<List<int>> getRecentIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    return history.map((e) => int.parse(e)).toList();
  }
}
