import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:library_manager/pages/library.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password)
  onLoginFailed; // Triggers the register prompt in parent

  const LoginForm({super.key, required this.onLoginFailed});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailCont = TextEditingController();
  final TextEditingController _passwordCont = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

  Future<void> handleSubmit() async {
    String email = _emailCont.text.trim();
    String password = _passwordCont.text;

    // Email format validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid email format.')));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your password.')),
      );
      return;
    }

    void _showDebugPopup(String title, String token) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Received JWT Token:'),
                const SizedBox(height: 8),
                SelectableText(
                  token,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss debug popup
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    final dio = Dio();

    try {
      // 1. First, attempt to log in
      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/users/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      if (response.statusCode == 200 &&
          data['status'] == 'success' &&
          data['token'] is String) {
        await _secureStorage.write(key: 'token', value: data['token']);
        //_showDebugPopup('Login Successful! ', data['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Library()), // Replace 'Library' with the exact class name inside your library.dart
        );
      }
    } on DioException catch (e) {
      // 2. If login fails (e.g. 401 Invalid credentials / account doesn't exist)
      // Prompt the user if they want to create an account instead
      widget.onLoginFailed(email, password);
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
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                onPressed: handleSubmit,
                child: const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
