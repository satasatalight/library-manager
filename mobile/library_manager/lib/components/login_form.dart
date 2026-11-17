import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../pages/library.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password) onLoginFailed;

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

    final dio = Dio();

    try {
      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/users/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;

      if (response.statusCode == 200 &&
          data['status'] == 'success' &&
          data['token'] is String) {
        await _secureStorage.write(key: 'token', value: data['token']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Library()),
          );
        }
      }
    } on DioException {
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailCont,
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: GoogleFonts.plusJakartaSans(color: Colors.black54, fontSize: 14),
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8F4670)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8F4670), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordCont,
          obscureText: true,
          style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: GoogleFonts.plusJakartaSans(color: Colors.black54, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8F4670)),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8F4670), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8F4670),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: handleSubmit,
            child: Text(
              "Login / Register",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}