import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../pages/library.dart';

class AddBook extends StatefulWidget {
  const AddBook({super.key});

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  final TextEditingController _titleCont = TextEditingController();
  final TextEditingController _authorCont = TextEditingController();
  final TextEditingController _genreCont = TextEditingController();
  final TextEditingController _yearCont = TextEditingController();
  final TextEditingController _descriptionCont = TextEditingController();
  final TextEditingController _coverImageCont = TextEditingController();

  final _secureStorage = const FlutterSecureStorage();
  bool _isSubmitting = false;

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success', style: GoogleFonts.kurale()),
          content: Text('Book added successfully!', style: GoogleFonts.kurale()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss popup
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Library()),
                );
              },
              child: Text('OK', style: GoogleFonts.kurale()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    String title = _titleCont.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give the book a title.')),
      );
      return;
    }

    String author = _authorCont.text.trim();
    String genre = _genreCont.text.trim();
    String yearStr = _yearCont.text.trim();
    int? publicationYear = yearStr.isNotEmpty ? int.tryParse(yearStr) : null;

    if (yearStr.isNotEmpty && publicationYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid publication year.')),
      );
      return;
    }

    String description = _descriptionCont.text.trim();
    String coverImageUrl = _coverImageCont.text.trim();

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Retrieve the saved user token from secure storage
      String? token = await _secureStorage.read(key: 'token');

      final dio = Dio();
      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/library/add',
        data: {
          'title': title,
          'author': author.isEmpty ? null : author,
          'genre': genre.isEmpty ? null : genre,
          'publication_year': publicationYear,
          'description': description.isEmpty ? null : description,
          'cover_image': coverImageUrl.isEmpty ? '' : coverImageUrl,
          'token': token,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSuccessDialog();
      } else {
        throw Exception(data['reason'] ?? 'The book could not be added.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Unable to add the book.';
      if (e.response?.data != null && e.response?.data['reason'] != null) {
        errorMessage = e.response?.data['reason'];
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleCont.dispose();
    _authorCont.dispose();
    _genreCont.dispose();
    _yearCont.dispose();
    _descriptionCont.dispose();
    _coverImageCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Add Book', style: GoogleFonts.kurale(fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Field
                  TextField(
                    controller: _titleCont,
                    decoration: InputDecoration(
                      labelText: 'Title *',
                      labelStyle: GoogleFonts.kurale(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Author Field
                  TextField(
                    controller: _authorCont,
                    decoration: InputDecoration(
                      labelText: 'Author',
                      labelStyle: GoogleFonts.kurale(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Genre Field
                  TextField(
                    controller: _genreCont,
                    decoration: InputDecoration(
                      labelText: 'Genre',
                      labelStyle: GoogleFonts.kurale(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Publication Year Field
                  TextField(
                    controller: _yearCont,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Publication Year',
                      labelStyle: GoogleFonts.kurale(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Optional Description Field
                  TextField(
                    controller: _descriptionCont,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      labelStyle: GoogleFonts.kurale(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Optional Cover Image URL Field
                  TextField(
                    controller: _coverImageCont,
                    decoration: InputDecoration(
                      labelText: 'Cover Image URL (Optional)',
                      labelStyle: GoogleFonts.kurale(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(130, 44),
                        ),
                        child: Text('Cancel', style: GoogleFonts.kurale(fontSize: 16)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8F4670),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(130, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isSubmitting ? 'Adding...' : 'Submit',
                          style: GoogleFonts.kurale(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}