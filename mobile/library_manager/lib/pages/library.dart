//import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../components/add_book.dart';
import '../components/edit_book.dart';

import 'login.dart';

class Book {
  String bookId = "";
  String title = "";
  String author = "";
  String genre = "";
  int publicationYear = 0;
  String description = "";
  String coverImageUrl = "";

  Book(
    this.bookId,
    this.title,
    this.author,
    this.genre,
    this.publicationYear,
    this.description,
    this.coverImageUrl,
  );
  factory Book.fromJson(Map<String, dynamic> json) {
    var rawYear = json['publicationYear'] ?? json['publication_year'];
    int parsedYear = 0;
    if (rawYear is int) {
      parsedYear = rawYear;
    } else if (rawYear is String) {
      parsedYear = int.tryParse(rawYear) ?? 0;
    }

    return Book(
      json['bookId']?.toString() ?? json['_id']?.toString() ?? '',
      json['title'] ?? '',
      json['author'] ?? '',
      json['genre'] ?? '',
      parsedYear,
      json['description'] ?? '',
      json['coverImageUrl'] ?? json['cover_image'] ?? '',
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
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
          book.title,
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
  final _secureStorage = const FlutterSecureStorage();

  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = _fetchLibraryBooks();
  }

  Future<List<Book>> _fetchLibraryBooks() async {
    try {
      String? token = await _secureStorage.read(key: 'token');
      final dio = Dio();

      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/library/view',
        data: {'token': token},
      );

      final data = response.data;

      if (response.statusCode == 200 && data['status'] == 'success') {
        final List booksJson = data['library'] ?? [];
        return booksJson.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception(data['reason'] ?? 'Failed to load books.');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['reason'] ?? 'Unable to connect to server.',
      );
    }
  }

  void _refreshLibrary() {
    setState(() {
      _booksFuture = _fetchLibraryBooks();
    });
  }

  bool _matchTerm(Book book, String term) {
    final lowerTerm = term.toLowerCase();

    // Check for advanced search syntax (field: value)
    if (term.contains(':')) {
      final colonIndex = term.indexOf(':');
      final field = term.substring(0, colonIndex).trim().toLowerCase();
      final value = term.substring(colonIndex + 1).trim().toLowerCase();

      if (value.isEmpty) return true;

      switch (field) {
        case 'title':
          return book.title.toLowerCase().contains(value);
        case 'author':
          return book.author.toLowerCase().contains(value);
        case 'genre':
          return book.genre.toLowerCase().contains(value);
        case 'description':
          return book.description.toLowerCase().contains(value);
        case 'year':
        case 'publicationyear':
        case 'publication_year':
          return book.publicationYear.toString().contains(value);
        default:
        // Fallback to basic match if field name isn't recognized
          return _basicMatch(book, lowerTerm);
      }
    } else {
      // Basic search across all text fields
      return _basicMatch(book, lowerTerm);
    }
  }

  bool _basicMatch(Book book, String lowerTerm) {
    return book.title.toLowerCase().contains(lowerTerm) ||
        book.author.toLowerCase().contains(lowerTerm) ||
        book.genre.toLowerCase().contains(lowerTerm) ||
        book.description.toLowerCase().contains(lowerTerm);
  }

  List<Book> _filterAndSortBooks(List<Book> books, String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      return books;
    }

    // Split by '||' for OR conditions
    final orClauses = query.split('||');
    List<Book> matchedBooks = [];

    for (var book in books) {
      bool matchesQuery = false;

      for (var orClause in orClauses) {
        // Split each OR clause by '&&' for AND conditions
        final andTerms = orClause.split('&&');
        bool andMatch = true;

        for (var term in andTerms) {
          final trimmedTerm = term.trim();
          if (trimmedTerm.isEmpty) continue;

          if (!_matchTerm(book, trimmedTerm)) {
            andMatch = false;
            break;
          }
        }

        if (andMatch) {
          matchesQuery = true;
          break; // Matched at least one OR clause
        }
      }

      if (matchesQuery) {
        matchedBooks.add(book);
      }
    }

    // Sort results by priority tier: Title (1) -> Author (2) -> Genre (3) -> Description (4)
    matchedBooks.sort((a, b) => _getBookTier(a, query).compareTo(_getBookTier(b, query)));

    return matchedBooks;
  }
  int _getBookTier(Book book, String rawQuery) {
    if (!rawQuery.contains(':')) {
      final q = rawQuery.toLowerCase();
      if (book.title.toLowerCase().contains(q)) return 1;
      if (book.author.toLowerCase().contains(q)) return 2;
      if (book.genre.toLowerCase().contains(q)) return 3;
      if (book.description.toLowerCase().contains(q)) return 4;
    }
    return 5;
  }

  void _showBookOptions(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(book.title, style: GoogleFonts.kurale()),
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
                  MaterialPageRoute(builder: (context) => EditBook(book: book)),
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
    // final String query = _searchCont.text.trim();
    // print('Saved search query: $query');
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

              // Interactive Search Bar with Live Filtering
              TextField(
                controller: _searchCont,
                onChanged: (value) {
                  setState(() {}); // Triggers live filtering as you type
                },
                decoration: InputDecoration(
                  hintText: 'Search ...',
                  hintStyle: GoogleFonts.kurale(
                    color: Colors.black38,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black),
                    onPressed: () {
                      setState(() {});
                    },
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
                onSubmitted: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),

              // Dynamic Grid of Books with Search Applied
              Expanded(
                child: FutureBuilder<List<Book>>(
                  future: _booksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8F4670),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: GoogleFonts.kurale(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final allBooks = snapshot.data ?? [];
                    final userBooks = _filterAndSortBooks(allBooks, _searchCont.text);

                    if (userBooks.isEmpty) {
                      return Center(
                        child: Text(
                          'No books found',
                          style: GoogleFonts.kurale(fontSize: 18),
                        ),
                      );
                    }

                    return GridView.builder(
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
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Action Buttons
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddBook(),
                          ),
                        );
                        _refreshLibrary();
                      },
                      child: Container(
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

                    FilledButton(
                      onPressed: () async {
                        const secureStorage = FlutterSecureStorage();
                        await secureStorage.delete(key: 'token');

                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                                (route) => false,
                          );
                        }
                      },
                      child: Container(
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
