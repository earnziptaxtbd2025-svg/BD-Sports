import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/current_user_provider.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_tile.dart';
import '../../../core/widgets/stadium_background.dart';
import '../../auth/presentation/profile_form.dart';

/// Edit the profile after the first set-up (Step 1.1). The mobile number is shown but
/// cannot be changed here.
class EditProfilePage extends ConsumerWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = context.s;
    final user = ref.watch(currentUserProvider);
    final title = Screens.byId('settings.edit')?.titleFor(s.language) ?? s.profileSave;
    final phone = user?.phone;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StadiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (phone != null) ...[
                GlassTile(
                  icon: Icons.phone_android,
                  title: phone,
                  subtitle: s.authPhoneLabel,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              const ProfileForm(isSetup: false),
            ],
          ),
        ),
      ),
    );
  }
}
