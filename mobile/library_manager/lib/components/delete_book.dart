import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeleteBookDialog extends StatelessWidget {
  final String bookId;
  final VoidCallback onDeleteSuccess;

  const DeleteBookDialog({
    super.key,
    required this.bookId,
    required this.onDeleteSuccess,
  });

  Future<void> _deleteBook(BuildContext context) async {
    try {
      const secureStorage = FlutterSecureStorage();
      String? token = await secureStorage.read(key: 'token');
      final dio = Dio();

      final response = await dio.post(
        'https://library-manager-ashy.vercel.app/library/delete',
        data: {
          'token': token,
          'book_id': bookId,
        },
      );

      final data = response.data;

      if (response.statusCode == 200 && data['status'] == 'success') {
        if (context.mounted) {
          // Close the confirmation dialog
          Navigator.of(context).pop();
          // Trigger success callback to refresh and return to library
          onDeleteSuccess();
        }
      } else {
        throw Exception(data['reason'] ?? 'Failed to delete book.');
      }
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data['reason'] ?? 'Unable to connect to server.',
              style: GoogleFonts.kurale(),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred: $e',
              style: GoogleFonts.kurale(),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Are you sure?',
        style: GoogleFonts.kurale(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to do this? This action cannot be undone.',
        style: GoogleFonts.kurale(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.kurale(color: Colors.grey[700]),
          ),
        ),
        TextButton(
          onPressed: () => _deleteBook(context),
          child: Text(
            'Delete',
            style: GoogleFonts.kurale(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}