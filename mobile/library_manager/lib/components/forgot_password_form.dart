import 'package:flutter/material.dart';

class ForgotPasswordForm extends Container {
  ForgotPasswordForm({super.key});

  @override
  Widget? get child => ChangeForm();
}

class ChangeForm extends StatefulWidget {
  const ChangeForm({super.key});

  @override
  State<ChangeForm> createState() => _ChangeFormState();
}

class _ChangeFormState extends State<ChangeForm> {
  Container currentForm = EmailForm();

  void submitResetRequest() {
    setState(() {
      currentForm = VerifyForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        currentForm,
        FilledButton(onPressed: submitResetRequest, child: Text("Submit Password Reset Request"))
      ],
    );
  }
}

class EmailForm extends Container {
  EmailForm({super.key});

  @override
  Widget? get child => Text("Put email form here");
}

class VerifyForm extends Container {
  VerifyForm({super.key});

  @override
  Widget? get child => Text("Put verify form here");
}