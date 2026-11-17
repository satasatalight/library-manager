import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:library_manager/pages/library.dart';

class ForgotPasswordForm extends Container {
  final VoidCallback onBackToLogin;

  ForgotPasswordForm({super.key, required this.onBackToLogin});

  @override
  Widget? get child => Column(
    children: [
      ChangeForm(),
      TextButton(
        onPressed: () {
          onBackToLogin();
        },
        child: const Text("Back to Login"),
      ),
    ],
  );
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
  FilledButton currentButton = FilledButton(
    onPressed: () => {},
    child: Text("Submit Password Reset Request"),
  );
  String email = "";

  void submitResetRequest() async {
    email = emailCont.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Please enter an email.')),
      );
      return;
    }

    try {
      Response res = await dio.post(
        "https://library-manager-ashy.vercel.app/users/login/reset_request",
        data: {'email': email},
      );

      if (res.statusCode == 200 && res.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Success! Check your email for a verification code',
              ),
            ),
          );
        }

        setState(() {
          currentForm = VerifyForm(
            codeCont: codeCont,
            newPasswordCont: newPasswordCont,
          );
          currentButton = FilledButton(
            onPressed: submitReset,
            child: Text("Reset Password"),
          );
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.response?.data['reason']}')),
        );
      }
    }
  }

  void submitReset() async {
    final code = codeCont.text.trim();
    final newPassword = newPasswordCont.text;

    if (code.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Please fill in all fields.')),
      );
      return;
    }

    try {
      Response res = await dio.post(
        "https://library-manager-ashy.vercel.app/users/login/reset",
        data: {'email': email, 'code': code, 'new_password': newPassword},
      );

      if (res.statusCode == 200 && res.data['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully Reset! Logging in now...')),
          );
        }

        final secureStorage = const FlutterSecureStorage();

        try {
          final response = await dio.post(
            'https://library-manager-ashy.vercel.app/users/login',
            data: {'email': email, 'password': newPassword},
          );

          final data = response.data;

          if (response.statusCode == 200 &&
              data['status'] == 'success' &&
              data['token'] is String) {
            await secureStorage.write(key: 'token', value: data['token']);

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Library()),
              );
            }
          }
        } on DioException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.response?.data['reason']}')),
            );
          }
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.response?.data['reason']}')),
        );
      }
    }
  }

  @override
  initState() {
    super.initState();
    currentButton = FilledButton(
      onPressed: submitResetRequest,
      child: Text("Submit Password Reset Request"),
    );
    currentForm = EmailForm(emailCont: emailCont);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [currentForm, currentButton]);
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
      SizedBox(height: 20),
    ],
  );
}

class VerifyForm extends Container {
  final TextEditingController codeCont;
  final TextEditingController newPasswordCont;

  VerifyForm({
    super.key,
    required this.codeCont,
    required this.newPasswordCont,
  });

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
      SizedBox(height: 20),
      TextField(
        controller: newPasswordCont,
        decoration: const InputDecoration(
          labelText: 'New Password',
          border: OutlineInputBorder(),
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}
