import 'package:flutter/material.dart';
import 'masked_form_helpers.dart';

class PaymentDetailsFormScreen extends StatefulWidget {
  const PaymentDetailsFormScreen({super.key});

  @override
  State<PaymentDetailsFormScreen> createState() =>
      _PaymentDetailsFormScreenState();
}

class _PaymentDetailsFormScreenState extends State<PaymentDetailsFormScreen>
    with MaskedFormTransitionMixin {
  final _formKey = GlobalKey<FormState>();
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _billingZipController = TextEditingController();

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _billingZipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const currentPath = '/masked-form/payment';

    return maskedFormScaffold(
      title: 'Payment Details',
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            maskedFormStepIndicator(currentPath),
            maskedFormDescription,
            const SizedBox(height: 16),
            maskedTextField(
              controller: _cardholderController,
              label: 'Cardholder Name',
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _cardNumberController,
              label: 'Card Number',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _expiryController,
              label: 'Expiry (MM/YY)',
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _cvvController,
              label: 'CVV',
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            maskedTextField(
              controller: _billingZipController,
              label: 'Billing ZIP Code',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            maskedFormFlowActions(
              context: context,
              currentPath: currentPath,
              formKey: _formKey,
              savedMessage: 'Payment details saved',
            ),
          ],
        ),
      ),
    );
  }
}
