import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../sync/pending_operation.dart';
import '../sync/sync_handler.dart';

/// Decides if a database error is temporary (try again) or final (stop).
/// Error codes starting with 08 (connection), 53 (resources) and 57 (timeout or
/// shutdown) are temporary. A missing code means no answer came, also temporary.
SyncResult classifyDatabaseError(String? code, String message) {
  final value = code ?? '';
  if (value.isEmpty ||
      value.startsWith('08') ||
      value.startsWith('53') ||
      value.startsWith('57')) {
    return SyncRetry(message);
  }
  return SyncRejected(message);
}

/// Saves the name, division and role of the signed-in person on the server. Safe to
/// send twice: it is an upsert on the person's own row.
class ProfileSyncHandler implements SyncHandler {
  ProfileSyncHandler(this._client);

  static const String type = 'profile.upsert';

  final SupabaseClient _client;

  @override
  Future<SyncResult> handle(PendingOperation operation) async {
    // Always the signed-in person, never an id from the queued data.
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const SyncRetry('Not signed in yet.');
    }

    final data = operation.payload;
    try {
      await _client.from('profiles').upsert(<String, dynamic>{
        'id': userId,
        'phone': data['phone'],
        'display_name': data['display_name'],
        'division': data['division'],
        'sports_role': data['sports_role'],
      }, onConflict: 'id');
      return const SyncSuccess();
    } on PostgrestException catch (error) {
      return classifyDatabaseError(error.code, error.message);
    } catch (error) {
      return SyncRetry(error.toString());
    }
  }
}

/// Uploads or removes the profile photo on the server.
class ProfilePhotoSyncHandler implements SyncHandler {
  ProfilePhotoSyncHandler(this._client);

  static const String type = 'profile.photo';
  static const String _bucket = 'avatars';

  final SupabaseClient _client;

  @override
  Future<SyncResult> handle(PendingOperation operation) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return const SyncRetry('Not signed in yet.');
    }

    final path = '$userId/avatar.jpg';
    final storage = _client.storage.from(_bucket);

    try {
      if (operation.payload['remove'] == true) {
        await storage.remove(<String>[path]);
        await _client
            .from('profiles')
            .update(<String, dynamic>{'photo_url': null}).eq('id', userId);
        return const SyncSuccess();
      }

      final encoded = operation.payload['base64'];
      if (encoded is! String || encoded.isEmpty) {
        return const SyncRejected('Photo data is missing.');
      }

      final Uint8List bytes;
      try {
        bytes = base64Decode(encoded);
      } catch (_) {
        return const SyncRejected('Photo data is damaged.');
      }

      await storage.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      final url = storage.getPublicUrl(path);
      await _client.from('profiles').update(<String, dynamic>{
        'photo_url': '$url?v=${DateTime.now().millisecondsSinceEpoch}',
      }).eq('id', userId);
      return const SyncSuccess();
    } on StorageException catch (error) {
      final status = int.tryParse(error.statusCode ?? '');
      if (status != null && status >= 400 && status < 500) {
        return SyncRejected(error.message);
      }
      return SyncRetry(error.message);
    } on PostgrestException catch (error) {
      return classifyDatabaseError(error.code, error.message);
    } catch (error) {
      return SyncRetry(error.toString());
    }
  }
}
