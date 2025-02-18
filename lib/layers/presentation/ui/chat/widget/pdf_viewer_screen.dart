import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  const PdfViewerScreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Future<void> _downloadPdf() async {
    try {
      Uri uri = Uri.parse(widget.pdfUrl);
      String fileName = uri.pathSegments.last;
      final directory = await getDownloadsDirectory();
      final filePath = '${directory!.path}/$fileName';
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            "File downloaded at: $filePath",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          )),
        );
      } else {
        throw Exception("Neuspelo preuzimanje PDF-a");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Uri uri = Uri.parse(widget.pdfUrl);
    String fileName = uri.pathSegments.last;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          fileName,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: SfPdfViewer.network(widget.pdfUrl),
    );
  }
}
