//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../components/add_book.dart';
import '../components/edit_book.dart';

import 'login.dart';

class _Library extends StatelessWidget {
  const _Library();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const Scaffold(body: Library()),
    );
  }
}

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF8F4670),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.topLeft,
        child: Text(
          book['title'] ?? '',
          textAlign: TextAlign.left,
          style: GoogleFonts.kurale(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final TextEditingController _searchCont = TextEditingController();

  // Example list of books the user owns
  final List<Map<String, dynamic>> userBooks = [
  {
    'title': 'Clean Code',
    'author': 'Robert C. Martin',
    'genre': 'Programming',
    'publication_year': 2008,
    'description': 'A handbook of agile software craftsmanship.',
    'cover_image': '',
    },
  ];
  void _showBookOptions(Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(book['title'], style: GoogleFonts.kurale()),
          content: Text(
            'Would you like to edit or delete this book?',
            style: GoogleFonts.kurale(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBook(book: book),
                  ),
                );
              },
              child: Text(
                'Edit',
                style: GoogleFonts.kurale(color: const Color(0xFF8F4670)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Delete',
                style: GoogleFonts.kurale(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  void _handleSearch() {
    final String query = _searchCont.text.trim();
    print('Saved search query: $query');
  }

  @override
  void dispose() {
    _searchCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // App Bar / Header section
              Center(
                child: Text(
                  'LitLog',
                  style: GoogleFonts.kurale(
                    color: Colors.black,
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 2, color: Colors.black),
              const SizedBox(height: 12),

              // Interactive Search Bar with Magnifying Glass Icon
              TextField(
                controller: _searchCont,
                //style: GoogleFonts.kurale(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search ...',
                  hintStyle: GoogleFonts.kurale(
                    color: Colors.black38,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black),
                    onPressed: _handleSearch, // Triggers when magnifying glass is clicked
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onSubmitted: (_) => _handleSearch(),
              ),
              const SizedBox(height: 20),

              // Dynamic Grid of Books
              Expanded(
                child: userBooks.isEmpty
                    ? const Center(child: Text('No books found'))
                    : GridView.builder(
                        itemCount: userBooks.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          return BookCard(
                            book: userBooks[index],
                            onTap: () => _showBookOptions(userBooks[index]),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),

              // Sign Out Button
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddBook()),
                        );
                      },
                      child: Container(
                        width: 166,
                        height: 44,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF8F4670),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Add Book',
                          style: GoogleFonts.kurale(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),


                    GestureDetector(
                      onTap: () async {
                        const secureStorage = FlutterSecureStorage();
                        await secureStorage.delete(key: 'token');

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                          (route) => false,
                        );
                      },
                      child: Container(
                        width: 166,
                        height: 44,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: ShapeDecoration(
                          color: const Color(0xFF8F4670),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.kurale(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
