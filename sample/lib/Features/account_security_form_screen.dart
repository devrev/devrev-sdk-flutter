import 'package:flutter/material.dart';
import 'masked_form_helpers.dart';

class AccountSecurityFormScreen extends StatefulWidget {
  const AccountSecurityFormScreen({super.key});

  @override
  State<AccountSecurityFormScreen> createState() =>
      _AccountSecurityFormScreenState();
}

class _AccountSecurityFormScreenState extends State<AccountSecurityFormScreen>
    with MaskedFormTransitionMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _recoveryEmailController = TextEditingController();
  final _twoFactorCodeController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _recoveryEmailController.dispose();
    _twoFactorCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const currentPath = '/masked-form/security';

    return maskedFormScaffold(
      title: 'Account Security',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            maskedFormStepIndicator(currentPath),
            maskedFormDescription,
            const SizedBox(height: 16),
            maskedTextField(
              controller: _currentPasswordController,
              label: 'Current Password',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _newPasswordController,
              label: 'New Password',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _recoveryEmailController,
              label: 'Recovery Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _twoFactorCodeController,
              label: 'Two-Factor Authentication Code',
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            maskedFormFlowActions(
              context: context,
              currentPath: currentPath,
              formKey: _formKey,
              savedMessage: 'Security settings updated',
            ),
          ],
        ),
      ),
    );
  }
}
