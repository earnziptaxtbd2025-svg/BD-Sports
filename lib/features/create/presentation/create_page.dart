import 'package:flutter/material.dart';

import '../../../core/navigation/screen_spec.dart';
import '../../navigation/presentation/hub_page.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HubPage(
      title: 'Create',
      hub: HubTab.create,
      intro: 'Start a tournament, team, club or profile.',
    );
  }
}
