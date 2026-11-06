import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ForgotPasswordForm extends Container {
  final VoidCallback onResetRequested;

  ForgotPasswordForm({super.key, required this.onResetRequested});
}
