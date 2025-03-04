import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

Future<void> downloadPdfFile(BuildContext context, String fileUrl) async {
  try {
    Dio dio = Dio();
    Uri uri = Uri.parse(fileUrl);
    String fileName = uri.pathSegments.last;

    final directory = await getDownloadsDirectory();
    final filePath = '${directory!.path}/$fileName';

    Response response = await dio.get(
      fileUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.data);
      _showDownloadDialog(context, filePath);
    } else {
      throw Exception("Error while download PDF-a: ${response.statusCode}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

void showPdfDialog(BuildContext context, String pdfUrl) async {
  File? pdfFile;

  try {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/temp.pdf';
    await Dio().download(pdfUrl, filePath);
    pdfFile = File(filePath);
  } catch (e) {
    print("Download error PDF-a: $e");
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
                icon: const Icon(Icons.download, color: Colors.red),
                onPressed: () async {
                  await downloadPdfFile(context, pdfUrl);
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

void _showDownloadDialog(BuildContext context, String filePath) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Download success"),
      content: Text("File saved: $filePath"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
