# Offline-First Architecture (Step 0.8)

Village grounds often have weak or no internet. The app must keep working there and
catch up later. This is the foundation every feature builds on.

## The rules

1. **Writes go to the outbox first.** Any change a user makes (score event, team
   registration, announcement) is saved on the phone immediately, then sent to the
   server when possible. The screen never waits for the internet.
2. **Reads show saved data first.** Screens show the last copy from the cache, then
   refresh from the server when online.
3. **Order is kept.** Changes are sent in the order they were made.
4. **Nothing is applied twice.** Every change has a unique id sent to the server, so a
   retried request is ignored if it already went through.
5. **The user can always see the state.** A bar above the bottom navigation shows
   "Offline", "Syncing", "N changes waiting" or "N changes could not be saved".

## Pieces (all in `lib/core`)

| File | Job |
|---|---|
| `network/connectivity_providers.dart` | `isOnlineProvider`: the one place to ask "are we online?" |
| `sync/pending_operation.dart` | One queued change (type, data, attempts, status) |
| `sync/outbox.dart` | The queue. Saved after every change. Safe against two writes at once |
| `sync/outbox_storage.dart` | Where the queue is stored (SharedPreferences now, replaceable) |
| `sync/sync_handler.dart` | Interface each feature implements to send its changes |
| `sync/sync_engine.dart` | Sends the queue: on start, when internet returns, on new change, every 30s, on "Sync now" |
| `sync/retry_policy.dart` | Wait 5s, 10s, 20s ... up to 5 minutes between retries |
| `cache/json_cache.dart` | Saved copy of server data for offline reading |
| `widgets/sync_status_banner.dart` | The status bar |

## What happens to a change

```
User taps "Goal"  ->  saved in outbox on the phone  ->  screen updates at once
                                  |
                    online?  yes -> handler sends it -> server accepts -> removed
                             no  -> waits, shown as "waiting to sync"
                                  |
        temporary error (busy, timeout) -> retry later, queue pauses to keep order
        permanent refusal (invalid)     -> marked "failed", rest of the queue continues
```

## How a feature adds an offline action

1. Pick a type name, for example `match.score_event`.
2. Write a handler:

```dart
class ScoreEventHandler implements SyncHandler {
  @override
  Future<SyncResult> handle(PendingOperation op) async {
    // Send op.payload to the server. Send op.id as the idempotency key.
    // Return SyncSuccess(), SyncRetry('reason') or SyncRejected('reason').
  }
}
```

3. Register it in `main.dart` under `syncHandlersProvider`.
4. Save changes with `ref.read(outboxProvider.notifier).enqueue('match.score_event', {...})`.

## Cached reading

```dart
final cache = ref.read(jsonCacheProvider);
final saved = cache.read('fixtures:$tournamentId');   // show this first
// when online: fetch from server, then
await cache.write('fixtures:$tournamentId', freshJson);
```

## Limits to know

- "Online" means the phone is connected to a network. It does not prove the internet
  works. That is why a failed request is treated as "retry later".
- SharedPreferences is fine for hundreds of queued changes and small caches. If the app
  later needs large offline data (full fixtures of many tournaments, with history),
  move storage to SQLite. Only `outbox_storage.dart` and `json_cache.dart` change.
- One failing change pauses the queue so order is preserved. If that ever blocks
  unrelated work, split into separate queues per tournament.
- Conflicts (two scorers editing the same match) are decided by the server when the
  backend is connected. Score changes are stored as events, not overwritten totals, so
  they merge safely.

## How to test on a phone

Profile tab, then **Offline sync tester** (development build):

1. Turn on "Simulate offline" (or use airplane mode).
2. Tap "Add score draft" three times. The queue shows 3 waiting, and the bar says Offline.
3. Turn offline off. Within a moment the bar says Syncing, then disappears, and the
   queue empties.
4. Choose "Temporary error", add a draft: it stays waiting and the attempt count goes up.
5. Choose "Rejects changes", add a draft: it turns Failed. Switch back to Working and
   tap "Retry failed": it clears.
6. Close the app fully while changes are waiting, open it again: they are still there.
