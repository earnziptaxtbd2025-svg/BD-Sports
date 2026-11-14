import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/shared_preferences_provider.dart';

/// Who is allowed to see something or contact the person.
enum Audience {
  everyone('Everyone'),
  teammates('My teams only'),
  nobody('Only me');

  const Audience(this.label);

  final String label;
}

/// How the person looking at a profile is related to its owner.
enum ViewerRelation { owner, teammate, other }

/// Privacy choices of one person.
///
/// Defaults are private. Anything unknown or missing is treated as the most private
/// choice, never the most open one.
class PrivacySettings {
  const PrivacySettings({
    required this.phone,
    required this.age,
    required this.photo,
    required this.messages,
    required this.findableByPhone,
    required this.showInTalentSearch,
    required this.showStats,
  });

  /// Safe starting choices. Under-18 players get stricter ones.
  factory PrivacySettings.defaults({bool isMinor = false}) {
    return PrivacySettings(
      phone: Audience.nobody,
      age: isMinor ? Audience.nobody : Audience.teammates,
      photo: isMinor ? Audience.teammates : Audience.everyone,
      messages: isMinor ? Audience.nobody : Audience.teammates,
      findableByPhone: false,
      showInTalentSearch: !isMinor,
      showStats: true,
    );
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    Audience audience(Object? value) => Audience.values.firstWhere(
          (a) => a.name == value,
          orElse: () => Audience.nobody,
        );

    return PrivacySettings(
      phone: audience(json['phone']),
      age: audience(json['age']),
      photo: audience(json['photo']),
      messages: audience(json['messages']),
      findableByPhone: json['findableByPhone'] == true,
      showInTalentSearch: json['showInTalentSearch'] == true,
      showStats: json['showStats'] == true,
    );
  }

  final Audience phone;
  final Audience age;
  final Audience photo;
  final Audience messages;
  final bool findableByPhone;
  final bool showInTalentSearch;
  final bool showStats;

  PrivacySettings copyWith({
    Audience? phone,
    Audience? age,
    Audience? photo,
    Audience? messages,
    bool? findableByPhone,
    bool? showInTalentSearch,
    bool? showStats,
  }) {
    return PrivacySettings(
      phone: phone ?? this.phone,
      age: age ?? this.age,
      photo: photo ?? this.photo,
      messages: messages ?? this.messages,
      findableByPhone: findableByPhone ?? this.findableByPhone,
      showInTalentSearch: showInTalentSearch ?? this.showInTalentSearch,
      showStats: showStats ?? this.showStats,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'phone': phone.name,
        'age': age.name,
        'photo': photo.name,
        'messages': messages.name,
        'findableByPhone': findableByPhone,
        'showInTalentSearch': showInTalentSearch,
        'showStats': showStats,
      };

  /// Decides if a viewer may see something shared with [audience].
  static bool canView(Audience audience, ViewerRelation relation) {
    if (relation == ViewerRelation.owner) {
      return true;
    }
    switch (audience) {
      case Audience.everyone:
        return true;
      case Audience.teammates:
        return relation == ViewerRelation.teammate;
      case Audience.nobody:
        return false;
    }
  }
}

/// Holds the person's privacy choices and saves them on the phone.
/// They are linked to the account when sign-in and the backend are added.
class PrivacySettingsNotifier extends Notifier<PrivacySettings> {
  static const String _key = 'privacy_settings_v1';

  @override
  PrivacySettings build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_key);
    if (raw == null) {
      return PrivacySettings.defaults();
    }
    try {
      return PrivacySettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return PrivacySettings.defaults();
    }
  }

  Future<void> update(PrivacySettings next) async {
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_key, jsonEncode(next.toJson()));
  }
}

final privacySettingsProvider =
    NotifierProvider<PrivacySettingsNotifier, PrivacySettings>(
  PrivacySettingsNotifier.new,
);
