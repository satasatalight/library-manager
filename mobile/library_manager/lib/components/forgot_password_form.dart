import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ForgotPasswordForm extends Container {
  // final VoidCallback onResetRequested;
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
  final dio = Dio();
  final TextEditingController emailCont = TextEditingController();
  final TextEditingController codeCont = TextEditingController();
  final TextEditingController newPasswordCont = TextEditingController();

  Container currentForm = Container();
  FilledButton currentButton = FilledButton(onPressed: () => {}, child: Text("Submit Password Reset Request"));

  void submitResetRequest() async {
    final email = emailCont.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email.')),
      );
      return;
    }

    try {
      Response res = await dio.post(
          "https://library-manager-ashy.vercel.app/users/login/reset_request",
          data: {'email': email}
      );

      if (res.statusCode == 200 && res.data['status'] == 'success') {
        setState(() {
          currentForm = VerifyForm(codeCont: codeCont, newPasswordCont: newPasswordCont);
          currentButton = FilledButton(onPressed: submitReset, child: Text("Reset Password"));
        });
      }
    }

    on DioException catch (e){
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.response?.data['reason']}')),
        );
      }
    }
  }

  void submitReset() {
  }

  @override
  initState() {
    super.initState();
    currentButton = FilledButton(onPressed: submitResetRequest, child: Text("Submit Password Reset Request"));
    currentForm = EmailForm(emailCont: emailCont);
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
  final TextEditingController emailCont;

  EmailForm({super.key, required this.emailCont});

  @override
  Widget? get child => Column(
    children: [
      TextField(
        controller: emailCont,
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
  final TextEditingController codeCont;
  final TextEditingController newPasswordCont;

  VerifyForm({super.key, required this.codeCont, required this.newPasswordCont});

  @override
  Widget? get child => Column(
    children: [
      TextField(
        controller: codeCont,
        decoration: const InputDecoration(
          labelText: 'Verification Code',
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 20,),
      TextField(
        controller: newPasswordCont,
        decoration: const InputDecoration(
          labelText: 'New Password',
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 20,)
    ],
  );
}