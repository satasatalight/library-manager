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
  late Widget currentField;
  bool isLoginView = true;

  @override
  void initState() {
    super.initState();
    _loadLoginForm();
  }

  void _loadLoginForm() {
    setState(() {
      currentField = login_form.LoginForm(
        onLoginFailed: (email, password) {
          _showRegisterPrompt(email, password);
        },
      );
    });
  }

  void _showRegisterPrompt(String email, String password) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Account Not Found',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'It seems like $email does not have an account. Would you like to create one?',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8F4670),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentField = register_form.RegisterForm(
                    initialEmail: email,
                    initialPassword: password,
                    onRegistrationSuccess: () {
                      Navigator.pushReplacementNamed(context, '/library');
                    },
                    onBackToLogin: _loadLoginForm,
                  );
                });
              },
              child: Text(
                'Yes',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              const Color(0xFF8F4670).withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kept Kurale for the iconic LitLog brand title
                    Center(
                      child: Text(
                        "LitLog",
                        style: GoogleFonts.kurale(
                          fontSize: 72,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8F4670),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        "Your Personal Digital Library",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Form Container Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          currentField,
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: changeToForgotPassword,
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF8F4670),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}