import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xff8f4670),
        surface:Color(0xffe6ddc5)
      ),
    ),
    home: Scaffold(
      body: Login()
    )
  ));
}

class Login extends StatefulWidget {
  const Login ({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Container currentField = Container(
    child: Text("Put Login Component here")
  );

  void changeToRegister() {
    setState(() {
      currentField = Container(
        child: Text("Put Register Component here")
      );
    });
  }

  void changeToForgotPassword() {
    setState(() {
      currentField = Container(
        child: Text("Put Forgot Password Component here")
      );
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