import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RegisterForm extends StatefulWidget {
  final String initialEmail;
  final String initialPassword;
  final VoidCallback onRegistrationSuccess;
  final VoidCallback onBackToLogin;

  const RegisterForm({
    super.key,
    required this.initialEmail,
    required this.initialPassword,
    required this.onRegistrationSuccess,
    required this.onBackToLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  late final TextEditingController _emailCont;
  late final TextEditingController _passwordCont;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields with the credentials the user originally typed
    _emailCont = TextEditingController(text: widget.initialEmail);
    _passwordCont = TextEditingController(text: widget.initialPassword);
  }

  Future<void> handleRegister() async {
    String email = _emailCont.text.trim();
    String password = _passwordCont.text;

    // Email format validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format.')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password.')),
      );
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/users/register',
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      // guard against context not existing when async call is completed
      if(!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Logging you in...')),);

        // Trigger success callback (e.g. navigate to library or auto-login)
        widget.onRegistrationSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['reason'] ?? 'Registration failed.')),
        );
      }
    } on DioException catch (e) {
      String errorMsg = 'Could not create account.';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['reason'] ?? errorMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  void dispose() {
    _emailCont.dispose();
    _passwordCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Create Account",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 400,
            child: TextField(
              controller: _emailCont,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 400,
            child: TextField(
              controller: _passwordCont,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 165,
            child: FilledButton(
              onPressed: handleRegister,
              child: const Text("Register"),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: widget.onBackToLogin,
            child: const Text("Back to Login"),
          ),
        ],
      ),
    );
  }
}
