import 'package:flutter/material.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController emailCont;
  final TextEditingController passwordCont;

  const RegisterForm({
    super.key,
    required this.emailCont,
    required this.passwordCont,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:[
        TextField(
          controller: emailCont,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: passwordCont,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        )
      ]
    );
  }
}
