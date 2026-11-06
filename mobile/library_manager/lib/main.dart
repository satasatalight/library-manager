import 'package:flutter/material.dart';

import 'pages/login.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xff8f4670),
          surface: Color(0xffe6ddc5),
        ),
      ),
      home: Scaffold(body: Login()),
    ),
  );
}
