import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:library_manager/components/login_form.dart' as login_form;
import 'package:library_manager/components/forgot_password_form.dart'
    as forgot_password_form;
import 'package:library_manager/components/register_form.dart' as register_form;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //final TextEditingController _forgotEmailCont = TextEditingController();
  late Widget currentField;
  bool isLoginView = true;

  @override
  void initState() {
    super.initState();
    _loadLoginForm();
  }

  void _loadLoginForm() {
    currentField = login_form.LoginForm(
      onLoginFailed: (email, password) {
        _showRegisterPrompt(email, password);
      },
    );
  }

  // 2. Prompt user when account isn't found
  void _showRegisterPrompt(String email, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Not Found'),
          content: Text(
            'It seems like $email does not have an account. Would you like to create one?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss dialog (N -> back to login)
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
                // Switch view to the RegisterForm, pre-filling their credentials
                setState(() {
                  currentField = register_form.RegisterForm(
                    initialEmail: email,
                    initialPassword: password,
                    onRegistrationSuccess: () {
                      // After successful registration, navigate to library or reload login
                      Navigator.pushReplacementNamed(context, '/library');
                    },
                    onBackToLogin: _loadLoginForm,
                  );
                });
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> handlePasswordReset() async {}
  void changeToForgotPassword() {
    setState(() {
      currentField = forgot_password_form.ForgotPasswordForm(
        onResetRequested: handlePasswordReset,
      );
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.symmetric(vertical: 70, horizontal: 20),
      alignment: Alignment.topLeft,
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
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
