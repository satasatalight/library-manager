import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'login_form.dart';
import '../pages/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  late final TextEditingController _fnameCont;
  late final TextEditingController _lnameCont;
  final _secureStorage = const FlutterSecureStorage();


  @override
  void initState() {
    super.initState();
    // Pre-fill fields with the credentials the user originally typed
    _emailCont = TextEditingController(text: widget.initialEmail);
    _passwordCont = TextEditingController(text: widget.initialPassword);
    _fnameCont = TextEditingController(text: "");
    _lnameCont = TextEditingController(text: "");
  }

  Future<void> handleRegister() async {
    String email = _emailCont.text.trim();
    String password = _passwordCont.text;
    String fname = _fnameCont.text.trim();
    String lname = _lnameCont.text.trim();

    // Email format validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid email format.')));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a password.')));
      return;
    }
    void showDebugPopup(String title, String token) {
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

    void _promptForVerification(String email) {
      final TextEditingController codeController = TextEditingController();

      showDialog(
        context: context,
        barrierDismissible: true, // Allows tapping outside to dismiss if desired
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verify Your Email'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter the 6-digit code sent for $email.'),
                const SizedBox(height: 15),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: '6-Digit Code',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              // Cancel / Close button added here
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismisses the popup
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String codeText = codeController.text.trim();

                  int? codeNum = int.tryParse(codeText);
                  if (codeText.length != 6 || codeNum == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid 6-digit numeric code.')),
                    );
                    return;
                  }

                  try {
                    final dio = Dio();
                    final response = await dio.post(
                      'https://library-manager-ashy.vercel.app/users/registration/verify',
                      data: {
                        'email': email,
                        'code': codeNum,
                      },
                    );

                    if (!mounted) return;

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop(); // Dismiss verification dialog

                      String successMsg = 'Email verified successfully!';
                      if (response.data is Map && response.data['reason'] != null) {
                        successMsg = response.data['reason'];
                      } else if (response.data is String) {
                        successMsg = response.data;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(successMsg)),
                      );

                      widget.onBackToLogin();
                    }
                  } on DioException catch (e) {
                    if (!mounted) return;

                    String errorMsg = 'Verification failed.';
                    if (e.response?.data != null) {
                      if (e.response?.data is Map) {
                        errorMsg = e.response?.data['reason'] ?? errorMsg;
                      } else if (e.response?.data is String) {
                        errorMsg = e.response?.data;
                      }
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMsg)),
                    );
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          );
        },
      );
    }

    try {
      final dio = Dio();
      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/users/register',
        data: {
          'email': email,
          'password': password,
          'first_name': fname,
          'last_name': lname,
        },
      );

      final data = response.data;

      // guard against context not existing when async call is completed
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please enter your verification code.'),
          ),
        );

        // Open the 6-digit code entry dialog
        _promptForVerification(email);

        /*
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Logging you in...'),
          ),
        );

        // Trigger success callback (e.g. navigate to library or auto-login)
        try {
          final loginResponse = await dio.post(
            'https://library-manager-ashy.vercel.app/users/login',
            data: {'email': email, 'password': password},
          );

          final loginData = loginResponse.data;

          if (!mounted) return;

          if (loginResponse.statusCode == 200 &&
              loginData['status'] == 'success' &&
              loginData['token'] is String) {

            // Save token
            await _secureStorage.write(key: 'token', value: loginData['token']);

            // Show the token popup directly!
            showDebugPopup('Registration & Auto-Login Successful!', loginData['token']);

            // Trigger success callback
            widget.onRegistrationSuccess();
          }
        } on DioException catch (loginErr) {
          // If auto-login fails, fall back to returning to login screen
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registered! Please log in manually.'),
            ),
          );
          widget.onBackToLogin();
        }
         */
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  @override
  void dispose() {
    _emailCont.dispose();
    _passwordCont.dispose();
    _fnameCont.dispose();
    _lnameCont.dispose();
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
          const SizedBox(height: 15),
          SizedBox(
            width: 400,
            child: TextField(
              controller: _fnameCont,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: 400,
            child: TextField(
              controller: _lnameCont,
              decoration: const InputDecoration(
                labelText: 'Last Name',
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
            onPressed: (){
              //print("BACK TO LOGIN BUTTON CLICKED");
              widget.onBackToLogin();
            },

              /*
              onPressed:() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            */
              child: const Text("Back to Login"),
          ),
        ],
      ),
    );
  }
}
