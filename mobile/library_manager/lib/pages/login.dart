import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:library_manager/components/login_form.dart' as login_form;
import 'package:library_manager/components/forgot_password_form.dart'
    as forgot_password_form;
import 'package:library_manager/components/register_form.dart' as register_form;
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameCont = TextEditingController();
  final TextEditingController _passwordCont = TextEditingController();
  late Widget currentField;

  @override
  void initState(){
    super.initState();
    currentField = login_form.LoginForm(
      usernameCont: _usernameCont,
      passwordCont: _passwordCont,
    );
  }

  Future<void> handleLogin() async {
    String email = _usernameCont.text.trim();
    String password = _passwordCont.text;

    if(email.isEmpty || password.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email or Password is Empty')),
      );
      return;
    }
    try {
      final url = Uri.parse("http://localhost:3000/api/login");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        String token = data['token'];
        print('Login successful! Token: $token');
          // Navigate to your homepage
          Navigator.pushReplacementNamed(context, '/home');
      }
      else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['reason'] ?? 'Login failed.')),
          );
        }
      } catch (e) {
        print('Network error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not connect to the server.')),
        );
      }
    }

  void changeToRegister() {
    setState(() {
      currentField = register_form.RegisterForm();
    });
  }

  void changeToForgotPassword() {
    setState(() {
      currentField = forgot_password_form.ForgotPasswordForm();
    });
  }

  @override
  void dispose(){
    _usernameCont.dispose();
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
                  onPressed: handleLogin,
                  child: Text("Login"),
                ),
                FilledButton(
                  onPressed: changeToForgotPassword,
                  child: Text("Forgot Password?"),
                ),
                FilledButton(
                  onPressed: changeToRegister,
                  child: Text("Register"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
