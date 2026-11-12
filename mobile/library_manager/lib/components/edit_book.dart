import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../pages/library.dart';

class EditBook extends StatefulWidget {
  final Map<String, dynamic> book;

  const EditBook({super.key, required this.book});

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  late final TextEditingController _titleCont;
  late final TextEditingController _authorCont;
  late final TextEditingController _genreCont;
  late final TextEditingController _yearCont;
  late final TextEditingController _descriptionCont;
  late final TextEditingController _coverImageCont;

  final _secureStorage = const FlutterSecureStorage();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate controllers with the current book values
    _titleCont = TextEditingController(text: widget.book['title'] ?? '');
    _authorCont = TextEditingController(text: widget.book['author'] ?? '');
    _genreCont = TextEditingController(text: widget.book['genre'] ?? '');
    _yearCont = TextEditingController(
      text: widget.book['publication_year'] != null &&
          widget.book['publication_year'] != 0
          ? widget.book['publication_year'].toString()
          : '',
    );
    _descriptionCont =
        TextEditingController(text: widget.book['description'] ?? '');
    _coverImageCont =
        TextEditingController(text: widget.book['cover_image'] ?? '');
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success', style: GoogleFonts.kurale()),
          content: Text(
            'Book edited successfully!',
            style: GoogleFonts.kurale(),
          ),
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
    // If a field is left empty by the user, fallback to the existing book value
    String title = _titleCont.text.trim().isNotEmpty
        ? _titleCont.text.trim()
        : (widget.book['title'] ?? '');

    String author = _authorCont.text.trim().isNotEmpty
        ? _authorCont.text.trim()
        : (widget.book['author'] ?? '');

    String genre = _genreCont.text.trim().isNotEmpty
        ? _genreCont.text.trim()
        : (widget.book['genre'] ?? '');

    String yearStr = _yearCont.text.trim();
    int? publicationYear;
    if (yearStr.isNotEmpty) {
      publicationYear = int.tryParse(yearStr);
      if (publicationYear == null || publicationYear < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid publication year.')),
        );
        return;
      }
    } else {
      publicationYear = widget.book['publication_year'] ?? 0;
    }

    String description = _descriptionCont.text.trim().isNotEmpty
        ? _descriptionCont.text.trim()
        : (widget.book['description'] ?? '');

    String coverImageUrl = _coverImageCont.text.trim().isNotEmpty
        ? _coverImageCont.text.trim()
        : (widget.book['cover_image'] ?? '');

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please give the book a title.')),
      );
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? token = await _secureStorage.read(key: 'token');

      final dio = Dio();
      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/library/edit',
        data: {
          'book_id': widget.book['id'],
          'title': title,
          'author': author.isEmpty ? null : author,
          'genre': genre.isEmpty ? null : genre,
          'publication_year': publicationYear,
          'description': description.isEmpty ? null : description,
          'cover_image': coverImageUrl.isEmpty ? null : coverImageUrl,
          'token': token,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 && data['status'] == 'success') {
        _showSuccessDialog();
      } else {
        throw Exception(data['reason'] ?? 'The book could not be edited.');
      }
    } on DioException catch (e) {
      String errorMessage = 'Unable to edit the book.';
      if (e.response?.data != null && e.response?.data['reason'] != null) {
        errorMessage = e.response?.data['reason'];
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
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
        title: Text('Edit Book', style: GoogleFonts.kurale(fontSize: 24)),
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
                      labelText: 'Year of Release',
                      labelStyle: GoogleFonts.kurale(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextField(
                    controller: _descriptionCont,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: GoogleFonts.kurale(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cover Image URL Field
                  TextField(
                    controller: _coverImageCont,
                    decoration: InputDecoration(
                      labelText: 'Cover Image URL',
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
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(130, 44),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.kurale(fontSize: 16),
                        ),
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
                          _isSubmitting ? 'Saving...' : 'Confirm',
                          style: GoogleFonts.kurale(
                            fontSize: 16,
                            color: Colors.white,
                          ),
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