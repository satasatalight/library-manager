import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => Homepage();
}

class Homepage extends State<Home> {

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
                top: 766,
                child: Container(
                  width: 166,
                  height: 44,
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 56,
                    right: 56,
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
                    spacing: 1,
                    children: [
                      Text(
                        'Library',
                        style: GoogleFonts.kurale(
                          color: Colors.white,
                          fontSize: 16,
                          height: 0.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 145,
                top: 59,
                child: SizedBox(
                  width: 112,
                  height: 39,
                  child: Text(
                    'LitLog',
                    style: GoogleFonts.kurale(
                      color: Colors.black,
                      fontSize: 32,
                      height: 0.75,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 109,
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
                left: 28,
                top: 200,
                child: SizedBox(
                  width: 132,
                  height: 18,
                  child: Text(
                    'Currently reading: ',
                    style: GoogleFonts.kurale(
                      color: Colors.black,
                      fontSize: 16,
                      height: 0.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 87,
                top: 123,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Text(
                        'Daily Reminder to Read!',
                        style: GoogleFonts.kurale(
                          color: Colors.black,
                          fontSize: 20,
                          height: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 28,
                top: 228,
                child: Container(
                  width: 167,
                  height: 264,
                  decoration: BoxDecoration(color: const Color(0xFF8F4670)),
                ),
              ),
              Positioned(
                left: 47,
                top: 241,
                child: SizedBox(
                  width: 81,
                  height: 108,
                  child: Text(
                    'Cool ass book cover Image',
                    style: GoogleFonts.kurale(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 217,
                top: 234,
                child: Container(
                  width: 156,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: 156,
                        height: 27,
                        child: Text(
                          'Title: ',
                          style: GoogleFonts.kurale(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 156,
                        height: 27,
                        child: Text(
                          'Author:',
                          style: GoogleFonts.kurale(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 156,
                        height: 27,
                        child: Text(
                          'Last Page: ',
                          style: GoogleFonts.kurale(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 156,
                        height: 27,
                        child: Text(
                          'Pages Left: ',
                          style: GoogleFonts.kurale(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 156,
                        height: 118,
                        child: Text(
                          'Notes:',
                          style: GoogleFonts.kurale(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 82,
                top: 520,
                child: Container(
                  width: 237,
                  height: 150,
                  padding: const EdgeInsets.only(
                    top: 21,
                    left: 14,
                    right: 14,
                    bottom: 11,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8F4670),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      SizedBox(
                        width: 144,
                        height: 25,
                        child: Text(
                          'Update Page Count',
                          style: GoogleFonts.kurale(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: 209,
                        height: 49,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                                  side: BorderSide(width: 1, color: Colors.white),
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
                                    'Enter Page Number',
                                    style: GoogleFonts.kurale(
                                      color: const Color(0xFF9A9A9A),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 130,
                        height: 33,
                        padding: const EdgeInsets.only(top: 4, left: 14, right: 17, bottom: 6),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFDB68AA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 10,
                          children: [
                            Text(
                              'Update!',
                              style: GoogleFonts.kurale(
                                color: Colors.white,
                                fontSize: 16,
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
                left: 70,
                top: 698,
                child: Container(
                  width: 261,
                  padding: const EdgeInsets.only(top: 6, left: 50, right: 50),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8F4670),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 161,
                        height: 18,
                        child: Text(
                          'Im done with this book!',
                          style: GoogleFonts.kurale(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 97,
                        height: 14,
                        child: Text(
                          '(clear current read)',
                          style: GoogleFonts.kurale(
                            color: const Color(0xFFDF70B0),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
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