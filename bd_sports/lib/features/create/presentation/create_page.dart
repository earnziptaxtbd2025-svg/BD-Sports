import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_page.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      title: 'Create',
      icon: Icons.add_circle_outline,
      description: 'Create a tournament in 5 to 10 minutes. Built in Step 1.3.',
    );
  }
}
