import 'package:flutter/material.dart';
import 'masked_form_helpers.dart';

class UnmaskedFormScreen extends StatefulWidget {
  const UnmaskedFormScreen({super.key});

  @override
  State<UnmaskedFormScreen> createState() => _UnmaskedFormScreenState();
}

class _UnmaskedFormScreenState extends State<UnmaskedFormScreen>
    with MaskedFormTransitionMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return maskedFormScaffold(
      title: 'Contact Info',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            maskedFormStepIndicator('/masked-form/contact'),
            const Text(
              'No fields on this screen are masked. Everything here '
              'should be visible in recordings.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            maskedFormFlowActions(
              context: context,
              currentPath: '/masked-form/contact',
              formKey: _formKey,
              savedMessage: 'Contact info saved',
            ),
          ],
        ),
      ),
    );
  }
}
