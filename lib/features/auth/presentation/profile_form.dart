import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/current_user_provider.dart';
import '../../../core/auth/division.dart';
import '../../../core/auth/photo_picker.dart';
import '../../../core/auth/sports_role.dart';
import '../../../core/auth/user_store.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/route_guard.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/security/input_validators.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/neon_dropdown_field.dart';
import '../../../core/widgets/neon_text_field.dart';
import '../../../core/widgets/role_option_card.dart';
import '../../../core/widgets/user_avatar.dart';

/// The profile form: photo, name, division and role. Used for the first set-up
/// ([isSetup] true) and for editing later.
///
/// It is saved on the phone first, so it works without internet.
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key, required this.isSetup, this.from});

  final bool isSetup;

  /// Where to go after the first set-up. Checked by [safeReturnPath].
  final String? from;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  Division? _division;
  late SportsRole _role;
  Uint8List? _photo;
  bool _photoChanged = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _name = TextEditingController(text: user?.displayName ?? '');
    _division = user?.division;
    _role = user?.sportsRole ?? SportsRole.fan;
    _photo = ref.read(profilePhotoProvider);
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickPhoto() async {
    final s = context.s;
    try {
      final bytes = await ref.read(photoPickerProvider).pickFromGallery();
      if (!mounted || bytes == null) {
        return;
      }
      if (bytes.length > UserStore.maxPhotoBytes) {
        _showMessage(s.photoFailed);
        return;
      }
      setState(() {
        _photo = bytes;
        _photoChanged = true;
      });
    } catch (_) {
      if (mounted) {
        _showMessage(s.photoFailed);
      }
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final s = context.s;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    try {
      await ref.read(profileControllerProvider).save(
            name: _name.text,
            division: _division,
            role: _role,
            photo: _photo,
            photoChanged: _photoChanged,
          );
      if (!mounted) {
        return;
      }
      if (widget.isSetup) {
        router.go(safeReturnPath(widget.from) ?? AppRoutes.home);
      } else {
        messenger.showSnackBar(SnackBar(content: Text(s.profileSaved)));
        if (router.canPop()) {
          router.pop();
        } else {
          router.go(AppRoutes.profile);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        messenger.showSnackBar(SnackBar(content: Text(s.authSomethingWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final p = context.palette;
    final t = context.appText;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: GestureDetector(
              onTap: _saving ? null : _pickPhoto,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(name: _name.text, photo: _photo, size: 104),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.accent,
                        border: Border.all(color: p.bgBase, width: 2),
                      ),
                      child: Icon(
                        Icons.photo_camera_outlined,
                        size: 18,
                        color: p.isDark ? const Color(0xFF03210F) : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Wrap(
              spacing: AppSpacing.sm,
              children: [
                TextButton(
                  onPressed: _saving ? null : _pickPhoto,
                  child: Text(_photo == null ? s.photoAdd : s.photoChange),
                ),
                if (_photo != null)
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _photo = null;
                              _photoChanged = true;
                            }),
                    child: Text(s.photoRemove),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NeonTextField(
                  label: s.profileName,
                  hint: s.profileNameHint,
                  controller: _name,
                  prefixIcon: Icons.person_outline,
                  isRequired: true,
                  enabled: !_saving,
                  maxLength: 60,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    final issue = InputValidators.validatePersonName(value);
                    return issue == null ? null : s.validation(issue);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                NeonDropdownField<Division>(
                  label: s.profileDivision,
                  hint: s.profileDivisionHint,
                  prefixIcon: Icons.location_on_outlined,
                  clearLabel: s.profileDivisionNone,
                  value: _division,
                  items: [
                    for (final division in Division.values)
                      (division, division.labelFor(s.language)),
                  ],
                  onChanged: (value) => setState(() => _division = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(s.profileRoleTitle, style: t.heading),
          const SizedBox(height: AppSpacing.sm),
          // The three cards get the same height (IntrinsicHeight gives the stretching
          // row a height to work with).
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RoleOptionCard(
                    icon: Icons.emoji_events_outlined,
                    title: s.roleOrganizerTitle,
                    body: s.roleOrganizerBody,
                    selected: _role == SportsRole.organizer,
                    onTap: () => setState(() => _role = SportsRole.organizer),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RoleOptionCard(
                    icon: Icons.sports_soccer,
                    title: s.rolePlayerTitle,
                    body: s.rolePlayerBody,
                    selected: _role == SportsRole.player,
                    onTap: () => setState(() => _role = SportsRole.player),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: RoleOptionCard(
                    icon: Icons.groups_outlined,
                    title: s.roleFanTitle,
                    body: s.roleFanBody,
                    selected: _role == SportsRole.fan,
                    onTap: () => setState(() => _role = SportsRole.fan),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(s.roleNote, style: t.caption.copyWith(fontSize: 12)),
          const SizedBox(height: AppSpacing.xl),
          NeonButton(
            label: widget.isSetup ? s.profileContinue : s.profileSave,
            icon: widget.isSetup ? Icons.arrow_forward : Icons.check,
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
