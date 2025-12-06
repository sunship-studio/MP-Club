import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mpc_mobile_app/data/models/Exercise.dart';

class RecentSearchesService {
  static const String _key = 'recent_tutorial_searches';
  static const int _maxRecentSearches = 10;

  /// Save a tutorial search
  static Future<void> saveSearch(Exercise exercise) async {
    final prefs = await SharedPreferences.getInstance();
    final searchesJson = prefs.getStringList(_key) ?? [];

    // Convert to Exercise objects
    final searches = searchesJson
        .map((json) => Exercise.fromJson(jsonDecode(json)))
        .toList();

    // Remove if already exists (to move it to the top)
    searches.removeWhere((e) => e.id == exercise.id);

    // Add to the beginning
    searches.insert(0, exercise);

    // Keep only the latest searches
    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }

    // Convert back to JSON strings and save
    final updatedSearchesJson = searches
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(_key, updatedSearchesJson);
  }

  /// Get all recent searches
  static Future<List<Exercise>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searchesJson = prefs.getStringList(_key) ?? [];

    return searchesJson
        .map((json) => Exercise.fromJson(jsonDecode(json)))
        .toList();
  }

  /// Remove a specific search
  static Future<void> removeSearch(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final searchesJson = prefs.getStringList(_key) ?? [];

    final searches = searchesJson
        .map((json) => Exercise.fromJson(jsonDecode(json)))
        .toList();

    searches.removeWhere((e) => e.id == exerciseId);

    final updatedSearchesJson = searches
        .map((e) => jsonEncode(e.toJson()))
        .toList();

    await prefs.setStringList(_key, updatedSearchesJson);
  }

  /// Clear all recent searches
  static Future<void> clearAllSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
