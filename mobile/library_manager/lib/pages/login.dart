import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:library_manager/components/login_form.dart' as login_form;
import 'package:library_manager/components/forgot_password_form.dart' as forgot_password_form;
import 'package:library_manager/components/register_form.dart' as register_form;

class Login extends StatefulWidget {
  const Login ({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Container currentField = login_form.LoginForm();

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container (
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(vertical: 70, horizontal: 20),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lit\nLog",
            style: GoogleFonts.kurale(
              fontSize: 150,
              height: 0.72
            )
          ),
          SizedBox(height:65),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  currentField,
                  FilledButton(
                    onPressed: changeToRegister,
                    child: Text("New User? Create an Account"),
                  ),
                  FilledButton(
                    onPressed: changeToForgotPassword,
                    child: Text("Forgot Password?"),
                  )
              ]
            ),
          )
        ],
      )
    );
  }
}