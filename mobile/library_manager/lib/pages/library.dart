import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:library_manager/components/login_form.dart' as login_form;
import 'package:library_manager/components/forgot_password_form.dart'
as forgot_password_form;
import 'package:library_manager/components/register_form.dart' as register_form;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login.dart';

class _Library extends StatelessWidget {
  const _Library({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          Library(),
        ]),
      ),
    );
  }
}

class Library extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 402,
          height: 874,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: const Color(0xFFF2DCB1)),
          child: Stack(
            children: [
              Positioned(
                left: 118,
                top: 753,

                child: GestureDetector(
                  onTap: () async {
                    // 1. Clear the stored token
                    const secureStorage = FlutterSecureStorage();
                    await secureStorage.delete(key: 'token');

                    // 2. Navigate back to Login and clear the stack safely
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                          (route) => false,
                    );
                  },
                  child: Container(
                    width: 166,
                    height: 44,
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 56,
                      right: 49,
                      bottom: 12,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF8F4670),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'IM FELL English',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 145,
                top: 62,
                child: SizedBox(
                  width: 112,
                  height: 39,
                  child: Text(
                    'LitLog',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Kurale',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 112,
                child: Container(
                  width: 402,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 11,
                top: 122,
                child: Container(
                  width: 377,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [

                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              'Search ...',
                              style: TextStyle(
                                color: const Color(0xFF9A9A9A),
                                fontSize: 16,
                                fontFamily: 'Kurale',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 33,
                top: 194,
                child: Container(
                  width: 146,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 240,
                        decoration: BoxDecoration(color: const Color(0xFF8F4670)),
                      ),
                      SizedBox(
                        width: 146,
                        height: 18,
                        child: Text(
                          'Book Title',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Kurale',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 19,
                        top: 13,
                        child: SizedBox(
                          width: 81,
                          height: 108,
                          child: Text(
                            'BookTitle',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Kurale',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
