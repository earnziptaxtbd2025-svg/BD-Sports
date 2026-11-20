import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/current_user_provider.dart';
import '../../../core/config/env.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screen_spec.dart';
import '../../../core/navigation/screens.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/brand_app_bar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_tile.dart';
import '../../../core/widgets/neon_button.dart';
import '../../../core/widgets/screen_tile.dart';
import '../../../core/widgets/stadium_background.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../auth/presentation/auth_messages.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final t = context.appText;
    final s = context.s;
    final user = ref.watch(currentUserProvider);
    final settings = Screens.forArea(ScreenArea.settings);

    return Scaffold(
      appBar: BrandAppBar(title: s.tabProfile),
      body: StadiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.md,
            AppSpacing.screenH,
            AppSpacing.xl,
          ),
          children: [
            GlassCard(
              glowColor: p.accent,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  UserAvatar(
                    name: user?.displayName ?? '',
                    photo: ref.watch(profilePhotoProvider),
                    size: 60,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? s.notSignedIn,
                          style: t.heading,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user == null
                              ? s.profileSignedOutHint
                              : (user.phone ?? s.accountRole(user.accountRole)),
                          style: t.caption,
                        ),
                        if (user != null && user.hasProfile) ...[
                          const SizedBox(height: AppSpacing.xs + 2),
                          Wrap(
                            spacing: AppSpacing.xs + 2,
                            runSpacing: AppSpacing.xs,
                            children: [
                              AppBadge(
                                label: sportsRoleTitle(s, user.sportsRole),
                                tone: AppBadgeTone.success,
                              ),
                              if (user.division != null)
                                AppBadge(
                                  label: user.division!.labelFor(s.language),
                                  tone: AppBadgeTone.info,
                                  icon: Icons.location_on_outlined,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (user == null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    NeonButton(
                      label: s.signIn,
                      expand: false,
                      onPressed: () => context.push(AppRoutes.signIn),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final spec in settings) ...[
              ScreenTile(spec: spec),
              const SizedBox(height: AppSpacing.sm + 2),
            ],
            if (user != null) ...[
              const SizedBox(height: AppSpacing.sm),
              NeonButton(
                label: s.signOut,
                icon: Icons.logout,
                style: NeonButtonStyle.outline,
                onPressed: () => _confirmSignOut(context, ref),
              ),
            ],
            if (Env.devToolsEnabled) ...[
              const SizedBox(height: AppSpacing.md),
              _DevTile(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Role & Permission tester',
                path: AppRoutes.devRoles,
              ),
              _DevTile(
                icon: Icons.account_tree_outlined,
                title: 'Screen map',
                path: AppRoutes.devScreens,
              ),
              _DevTile(
                icon: Icons.palette_outlined,
                title: 'Design gallery',
                path: AppRoutes.devDesign,
              ),
              _DevTile(
                icon: Icons.link,
                title: 'Public link tester',
                path: AppRoutes.devLinks,
              ),
              _DevTile(
                icon: Icons.sync_alt,
                title: 'Offline sync tester',
                path: AppRoutes.devSync,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
  final s = context.s;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(s.signOutTitle),
      content: Text(s.signOutBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(s.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(s.signOut),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await ref.read(authControllerProvider).signOut();
  }
}

/// A developer tool entry, shown only in development builds.
class _DevTile extends StatelessWidget {
  const _DevTile({required this.icon, required this.title, required this.path});

  final IconData icon;
  final String title;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: GlassTile(
        icon: icon,
        title: title,
        subtitle: 'Developer tool, removed in the final release.',
        trailing: Icon(Icons.chevron_right, color: context.palette.textSecondary),
        onTap: () => context.push(path),
      ),
    );
  }
}
