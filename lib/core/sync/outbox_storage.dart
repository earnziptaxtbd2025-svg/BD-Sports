import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/shared_preferences_provider.dart';
import 'pending_operation.dart';

/// Where the outbox is saved on the phone. Swappable (for example for SQLite
/// later) without touching the rest of the sync code.
abstract interface class OutboxStorage {
  Future<List<PendingOperation>> load();

  Future<void> save(List<PendingOperation> operations);
}

class InMemoryOutboxStorage implements OutboxStorage {
  List<PendingOperation> _items = <PendingOperation>[];

  @override
  Future<List<PendingOperation>> load() async =>
      List<PendingOperation>.of(_items);

  @override
  Future<void> save(List<PendingOperation> operations) async {
    _items = List<PendingOperation>.of(operations);
  }
}

class SharedPrefsOutboxStorage implements OutboxStorage {
  SharedPrefsOutboxStorage(this._prefs);

  static const String _key = 'outbox_v1';

  final SharedPreferences _prefs;

  @override
  Future<List<PendingOperation>> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <PendingOperation>[];
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) =>
              PendingOperation.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      // A damaged file must never crash the app. Start with an empty queue.
      return <PendingOperation>[];
    }
  }

  @override
  Future<void> save(List<PendingOperation> operations) async {
    final encoded = jsonEncode(operations.map((op) => op.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }
}

final outboxStorageProvider = Provider<OutboxStorage>(
  (ref) => SharedPrefsOutboxStorage(ref.watch(sharedPreferencesProvider)),
);
