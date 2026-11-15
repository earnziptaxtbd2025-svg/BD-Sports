import 'package:flutter/material.dart';

import '../../../core/navigation/screen_spec.dart';
import '../../navigation/presentation/hub_page.dart';

class MySportsPage extends StatelessWidget {
  const MySportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HubPage(
      title: 'My Sports',
      hub: HubTab.mySports,
      intro: 'Everything that belongs to you.',
    );
  }
}
