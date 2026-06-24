import 'package:devrev_sdk_flutter/devrev.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef MaskedFormFlowStep = ({String title, String path});

const List<MaskedFormFlowStep> maskedFormFlowSteps = [
  (title: 'Personal Info', path: '/masked-form/personal'),
  (title: 'Contact Info (Unmasked)', path: '/masked-form/contact'),
  (title: 'Payment Details', path: '/masked-form/payment'),
  (title: 'Account Security', path: '/masked-form/security'),
];

int maskedFormStepIndex(String path) =>
    maskedFormFlowSteps.indexWhere((step) => step.path == path);

String? maskedFormNextPath(String path) {
  final index = maskedFormStepIndex(path);
  if (index < 0 || index >= maskedFormFlowSteps.length - 1) return null;
  return maskedFormFlowSteps[index + 1].path;
}

Future<void> navigateToMaskedForm(BuildContext context, String path) async {
  await DevRev.updateTransitioningState(true, isNavigation: true);
  if (!context.mounted) return;
  context.push(path);
}

void resumeRecordingWhenRouteVisible(BuildContext context) {
  final animation = ModalRoute.of(context)?.animation;
  if (animation == null ||
      animation.status == AnimationStatus.completed ||
      animation.status == AnimationStatus.dismissed) {
    DevRev.updateTransitioningState(false, isNavigation: true);
    return;
  }

  void onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animation.removeStatusListener(onAnimationStatus);
      DevRev.updateTransitioningState(false, isNavigation: true);
    }
  }

  animation.addStatusListener(onAnimationStatus);
}

mixin MaskedFormTransitionMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      resumeRecordingWhenRouteVisible(context);
    });
  }
}

Widget maskedFormStepIndicator(String path) {
  final step = maskedFormStepIndex(path);
  if (step < 0) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      'Step ${step + 1} of ${maskedFormFlowSteps.length}: '
      '${maskedFormFlowSteps[step].title}',
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

Widget maskedFormFlowActions({
  required BuildContext context,
  required String currentPath,
  required GlobalKey<FormState> formKey,
  String? savedMessage,
}) {
  final nextPath = maskedFormNextPath(currentPath);
  final isLastStep = nextPath == null;

  Future<void> onContinue() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (savedMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(savedMessage)),
      );
    }

    if (isLastStep) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Onboarding complete')),
      );
      context.go('/router-navigation');
      return;
    }

    await navigateToMaskedForm(context, nextPath);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton(
        onPressed: onContinue,
        child: Text(isLastStep ? 'Finish' : 'Continue'),
      ),
      if (Navigator.of(context).canPop()) ...[
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Back'),
        ),
      ],
    ],
  );
}

Widget maskedTextField({
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  int maxLines = 1,
  String? Function(String?)? validator,
}) {
  return DevRevMask(
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

Widget maskedFormScaffold({
  required String title,
  required Widget body,
}) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: body,
    ),
  );
}

const maskedFormDescription = Text(
  'All fields below are wrapped with DevRevMask and will be '
  'hidden in session recordings.',
  style: TextStyle(color: Colors.grey),
);
