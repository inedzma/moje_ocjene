import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/predmet_model.dart';

class LocalStorageService {
  static const String _predmetiKey = 'predmeti';

  // Sprema listu predmeta u lokalnu memoriju
  static Future<void> savePredmeti(List<Predmet> predmeti) async {
    final prefs = await SharedPreferences.getInstance();

    // Pretvaramo listu predmeta u JSON string
    final jsonString = jsonEncode(predmeti.map((p) => p.toJson()).toList());

    await prefs.setString(_predmetiKey, jsonString);
  }

  // Učitava listu predmeta iz memorije
  static Future<List<Predmet>> loadPredmeti() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_predmetiKey);

    if (jsonString == null) return [];

    final decoded = jsonDecode(jsonString) as List;
    return decoded.map((item) => Predmet.fromJson(item)).toList();
  }

  // Briše sve predmete (npr. za reset)
  static Future<void> clearPredmeti() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_predmetiKey);
  }
}
