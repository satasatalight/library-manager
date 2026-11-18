import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../components/add_book.dart';
import '../components/edit_book.dart';
import '../components/delete_book.dart';

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
  final VoidCallback? onLongPress;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    const bookRadius = BorderRadius.only(
      topLeft: Radius.circular(3),
      bottomLeft: Radius.circular(3),
      topRight: Radius.circular(10),
      bottomRight: Radius.circular(10),
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover with soft, natural elevation
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF8F4670),
                borderRadius: bookRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: bookRadius,
                child: Image.network(
                  book.coverImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 24,
                          ),
                          Text(
                            book.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Clean Book Title below the cover
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          if (book.author.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ],
        ],
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

  Future<List<Book>> _fetchLibraryBooks({String searchQuery = ''}) async {
    try {
      String? token = await _secureStorage.read(key: 'token');
      final dio = Dio();

      final bool isSearching = searchQuery.trim().isNotEmpty;
      final endpoint = isSearching
          ? 'https://library-manager-ashy.vercel.app/library/search'
          : 'https://library-manager-ashy.vercel.app/library/view';

      final payload = isSearching
          ? {'token': token, 'search_string': searchQuery.trim()}
          : {'token': token};

      final response = await dio.post(endpoint, data: payload);
      final data = response.data;

      if (response.statusCode == 200 && data['status'] == 'success') {
        final List booksJson = data['library'] ?? [];
        return booksJson.map((json) => Book.fromJson(json)).toList();
      } else {
        if (data['reason'] == 'No books found in user library.') {
          return [];
        }
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
      _booksFuture = _fetchLibraryBooks(searchQuery: _searchCont.text);
    });
  }

  void _showBookDetails(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              if (book.author.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'by ${book.author}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8F4670),
                  ),
                ),
              ],
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (book.genre.isNotEmpty || book.publicationYear > 0) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (book.genre.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8F4670)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              book.genre,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF8F4670),
                              ),
                            ),
                          ),
                        if (book.publicationYear > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${book.publicationYear}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Text(
                    'Description',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black45,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.description.trim().isNotEmpty
                        ? book.description
                        : 'No description available for this book.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      height: 1.5,
                      color: book.description.trim().isNotEmpty
                          ? Colors.black87
                          : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8F4670),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBookOptions(Book book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            book.title,
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Would you like to edit or delete this book?',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditBook(book: book)),
                );
              },
              child: Text(
                'Edit',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF8F4670),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteBookDialog(
                      bookId: book.bookId,
                      onDeleteSuccess: () {
                        _refreshLibrary();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Book deleted successfully.',
                              style: GoogleFonts.plusJakartaSans(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Kept Kurale for the main LitLog logo
              Center(
                child: Text(
                  'LitLog',
                  style: GoogleFonts.kurale(
                    color: COlors.black,
                    fontSize: 72,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Crisp Modern Search Bar
              TextField(
                controller: _searchCont,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {
                    _booksFuture = _fetchLibraryBooks(searchQuery: value);
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search your library...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: Colors.black38,
                    fontSize: 15,
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF8F4670)),
                    onPressed: () {
                      setState(() {
                        _booksFuture = _fetchLibraryBooks(
                          searchQuery: _searchCont.text,
                        );
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 2,
                      color: Color(0xFF8F4670),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _booksFuture = _fetchLibraryBooks(searchQuery: value);
                  });
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
                          style: GoogleFonts.plusJakartaSans(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final userBooks = snapshot.data ?? [];

                    if (userBooks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 64,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No books found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      itemCount: userBooks.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 18,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.62,
                          ),
                      itemBuilder: (context, index) {
                        return BookCard(
                          book: userBooks[index],
                          onLongPress: () => _showBookOptions(userBooks[index]),
                          onTap: () => _showBookDetails(userBooks[index]),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Action Buttons
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF8F4670),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddBook(),
                            ),
                          );
                          _refreshLibrary();
                        },
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Add Book',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8F4670),
                          side: const BorderSide(color: Color(0xFF8F4670)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                        icon: const Icon(Icons.logout),
                        label: Text(
                          'Sign Out',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
