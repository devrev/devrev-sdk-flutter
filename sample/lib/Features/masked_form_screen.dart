import 'package:flutter/material.dart';
import 'masked_form_helpers.dart';

class MaskedFormScreen extends StatefulWidget {
  const MaskedFormScreen({super.key});

  @override
  State<MaskedFormScreen> createState() => _MaskedFormScreenState();
}

class _MaskedFormScreenState extends State<MaskedFormScreen>
    with MaskedFormTransitionMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ssnController = TextEditingController();
  final _cardNumberController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ssnController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const currentPath = '/masked-form/personal';

    return maskedFormScaffold(
      title: 'Personal Info',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            maskedFormStepIndicator(currentPath),
            maskedFormDescription,
            const SizedBox(height: 16),
            maskedTextField(
              controller: _nameController,
              label: 'Full Name',
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _phoneController,
              label: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _addressController,
              label: 'Address',
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _ssnController,
              label: 'Social Security Number',
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _cardNumberController,
              label: 'Credit Card Number',
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 24),
            maskedFormFlowActions(
              context: context,
              currentPath: currentPath,
              formKey: _formKey,
              savedMessage: 'Personal info saved',
            ),
          ],
        ),
      ),
    );
  }
}
