import 'package:flutter/material.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/navigation/screen_spec.dart';
import '../../navigation/presentation/hub_page.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return HubPage(
      title: s.tabExplore,
      hub: HubTab.explore,
      intro: s.exploreIntro,
    );
  }
}
