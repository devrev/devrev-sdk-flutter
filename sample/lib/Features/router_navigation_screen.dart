import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'masked_form_helpers.dart';

class RouterNavigationScreen extends StatelessWidget {
  const RouterNavigationScreen({super.key});

  static const _entryPath = '/masked-form/personal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Router Navigation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Start the nested onboarding flow. Each screen pushes the next '
            'on top of the stack, building a deep navigation chain.',
          ),
          const SizedBox(height: 16),
          ...maskedFormFlowSteps.asMap().entries.map(
                (entry) => ListTile(
                  leading: CircleAvatar(child: Text('${entry.key + 1}')),
                  title: Text(entry.value.title),
                  subtitle: Text(entry.value.path),
                ),
              ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => navigateToMaskedForm(context, _entryPath),
            child: const Text('Start Onboarding Flow'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
