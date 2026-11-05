import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:library_manager/components/login_form.dart' as login_form;
import 'package:library_manager/components/forgot_password_form.dart'
    as forgot_password_form;
import 'package:library_manager/components/register_form.dart' as register_form;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailCont = TextEditingController();
  final TextEditingController _passwordCont = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();
  late Widget currentField;
  bool isLoginView = true;

  @override
  void initState(){
    super.initState();
    currentField = login_form.LoginForm(
      usernameCont: _emailCont,
      passwordCont: _passwordCont,
    );
  }
  Future<void> handleSubmit() async {
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

      if (response.statusCode == 200 && data['status'] == 'success' && data['token'] is String) {
        await _secureStorage.write(key: 'token', value: data['token']);
        //Navigator.pushReplacementNamed(context, '/home');
        _showDebugPopup('Login Successful! ', data['token']);
      }
    } on DioException catch (e) {
      // 2. If login fails (e.g. 401 Invalid credentials / account doesn't exist)
      // Prompt the user if they want to create an account instead
      _showRegisterPrompt(email, password);
    }
  }

  void _showRegisterPrompt(String email, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Not Found'),
          content: Text('It seems like $email does not have an account. Would you like to create one?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog (N -> back to login)
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                _executeRegistration(email, password); // Y -> register user
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _executeRegistration(String email, String password) async {
    try {
      final dio = Dio();

      // Call your backend register endpoint
      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/users/register',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully! Logging you in...')),
        );

        // Automatically attempt login right after successful registration,
        // or redirect them depending on your verification flow requirements
        handleSubmit();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    } on DioException catch (e) {
      String errorMsg = 'Could not create account.';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['reason'] ?? errorMsg;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  void changeToForgotPassword() {
    setState(() {
      currentField = forgot_password_form.ForgotPasswordForm();
    });
  }
  /*
  Future<void> handleLogin() async {
    String email = _usernameCont.text.trim();
    String password = _passwordCont.text;

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format.')),
      );
      return;
    }

    if(email.isEmpty || password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email or Password is Empty')),
      );
      return;
    }
    try {
      final dio = Dio();

      // Dio automatically encodes maps in 'data' to JSON
      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/users/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // response.data is already decoded from JSON!
      final data = response.data;

      if (response.statusCode == 200 && data['status'] == 'success') {
        String token = data['token'];
        await _secureStorage.write(key: 'token', value: token);
        print('Login successful! Token: $token');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['reason'] ?? 'Login failed.')),
        );
      }
    } on DioException catch (e) {
      // Dio gives you robust error handling out of the box
      print('Network error: ${e.message}');

      // If the backend sent a 401/403 response with a body, we can still read it:
      String errorMsg = 'Could not connect to the server.';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['reason'] ?? errorMsg;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }
*/
  @override
  void dispose(){
    _emailCont.dispose();
    _passwordCont.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(vertical: 70, horizontal: 20),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lit\nLog",
            style: GoogleFonts.kurale(fontSize: 150, height: 0.72),
          ),
          SizedBox(height: 65),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                currentField,
                FilledButton(
                  onPressed: handleSubmit,
                  child: Text("Login"),
                ),
                FilledButton(
                  onPressed: changeToForgotPassword,
                  child: Text("Forgot Password?"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
