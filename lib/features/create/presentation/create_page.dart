import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screen_spec.dart';
import '../../navigation/presentation/hub_page.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return HubPage(
      title: s.tabCreate,
      hub: HubTab.create,
      intro: s.createIntro,
    );
  }
}
