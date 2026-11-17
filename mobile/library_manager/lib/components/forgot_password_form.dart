import 'package:flutter/material.dart';

class ForgotPasswordForm extends Container {
  // final VoidCallback onResetRequested;

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
  FilledButton currentButton = FilledButton(onPressed: () => {}, child: Text("Submit Password Reset Request"));

  void submitResetRequest() {
    setState(() {
      currentForm = VerifyForm();
      currentButton = FilledButton(onPressed: submitReset, child: Text("Reset Password"));
    });
  }

  void submitReset() {
  }

  @override
  initState() {
    super.initState();
    currentButton = FilledButton(onPressed: submitResetRequest, child: Text("Submit Password Reset Request"));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        currentForm,
        currentButton
      ],
    );
  }
}

class EmailForm extends Container {
  EmailForm({super.key});

  final TextEditingController _emailCont = TextEditingController();

  @override
  Widget? get child => Column(
    children: [
      TextField(
        controller: _emailCont,
        decoration: const InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 20,)
    ],
  );
}

class VerifyForm extends Container {
  VerifyForm({super.key});

  final TextEditingController _codeCont = TextEditingController();
  final TextEditingController _newPasswordCont = TextEditingController();

  @override
  Widget? get child => Column(
    children: [
      TextField(
        controller: _codeCont,
        decoration: const InputDecoration(
          labelText: 'Verification Code',
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 20,),
      TextField(
        controller: _newPasswordCont,
        decoration: const InputDecoration(
          labelText: 'New Password',
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 20,)
    ],
  );
}