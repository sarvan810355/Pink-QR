import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/qr_history_item.dart';

/// Persists generated/scanned QR history locally as JSON via shared_preferences.
class HistoryService extends ChangeNotifier {
  static const _storageKey = 'qr_bloom_history_v1';

  List<QrHistoryItem> _items = [];
  bool _loaded = false;

  List<QrHistoryItem> get items => List.unmodifiable(_items);
  List<QrHistoryItem> get favorites =>
      _items.where((e) => e.isFavorite).toList(growable: false);
  bool get isLoaded => _loaded;

  int get totalCount => _items.length;
  int get scanCount =>
      _items.where((e) => e.source == QrSourceKind.scanned).length;
  int get generatedCount =>
      _items.where((e) => e.source == QrSourceKind.generated).length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List;
      _items = list
          .map((e) => QrHistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  Future<void> add(QrHistoryItem item) async {
    _items.insert(0, item);
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(isFavorite: !_items[idx].isFavorite);
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await _persist();
  }

  List<QrHistoryItem> search(String query) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return _items
        .where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.rawData.toLowerCase().contains(q))
        .toList(growable: false);
  }
}
