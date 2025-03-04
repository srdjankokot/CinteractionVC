import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void showPdfDialog(BuildContext context, String pdfUrl) async {
  File? pdfFile;

  try {
    final response = await http.get(Uri.parse(pdfUrl));
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      pdfFile = File('${dir.path}/temp.pdf');
      await pdfFile.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception("Download failed PDF-a");
    }
  } catch (e) {
    print("Error downloading PDF: $e");
  }

  if (pdfFile != null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              child: SfPdfViewer.file(pdfFile!),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.download, color: Colors.black),
                onPressed: () async {
                  await saveFile(pdfFile!);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

Future<void> saveFile(File file) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final newPath = '${dir.path}/downloaded.pdf';
    await file.copy(newPath);
    print("PDF saved: $newPath");
  } catch (e) {
    print("Error while saving PDF-a: $e");
  }
}
