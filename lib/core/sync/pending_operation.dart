enum OperationStatus { pending, failed }

/// One change made on this phone that still has to reach the server.
class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.status = OperationStatus.pending,
    this.lastError,
    this.nextAttemptAt,
  });

  /// Unique id. Also sent to the server so a retried request is not applied twice.
  final String id;

  /// Which handler processes this, for example `match.score_event`.
  final String type;

  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final OperationStatus status;
  final String? lastError;

  /// Earliest time the next attempt may run (retry back-off).
  final DateTime? nextAttemptAt;

  PendingOperation copyWith({
    int? attempts,
    OperationStatus? status,
    String? lastError,
    bool clearError = false,
    DateTime? nextAttemptAt,
    bool clearNextAttempt = false,
  }) {
    return PendingOperation(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      status: status ?? this.status,
      lastError: clearError ? null : (lastError ?? this.lastError),
      nextAttemptAt:
          clearNextAttempt ? null : (nextAttemptAt ?? this.nextAttemptAt),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        'payload': payload,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'attempts': attempts,
        'status': status.name,
        'lastError': lastError,
        'nextAttemptAt': nextAttemptAt?.toUtc().toIso8601String(),
      };

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      status: OperationStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => OperationStatus.pending,
      ),
      lastError: json['lastError'] as String?,
      nextAttemptAt: json['nextAttemptAt'] == null
          ? null
          : DateTime.parse(json['nextAttemptAt'] as String).toUtc(),
    );
  }
}
