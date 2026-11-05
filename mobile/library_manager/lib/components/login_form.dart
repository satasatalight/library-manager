import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameCont;
  final TextEditingController passwordCont;

  const LoginForm({
    super.key,
    required this.usernameCont,
    required this.passwordCont,
  });

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: usernameCont,
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
        ),
      ],
    );
  }
}
