import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

void openTextFile(BuildContext context, String fileUrl) async {
  try {
    Dio dio = Dio();
    print('FileUrl: $fileUrl');

    Response response = await dio.get(fileUrl);
    Uri uri = Uri.parse(fileUrl);
    String fileName = uri.pathSegments.last;

    if (response.statusCode == 200) {
      String fileContent = response.data.toString();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fileName,
                style: TextStyle(color: Colors.red),
              ),
              IconButton(
                icon: const Icon(Icons.download),
                color: Colors.red,
                onPressed: () => downloadTextFile(context, fileUrl),
              ),
            ],
          ),
          content: SingleChildScrollView(child: Text(fileContent)),
          actions: [
            TextButton(
              child: const Text("Close"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      print("Error while opening file: ${response.statusCode}");
    }
  } catch (e) {
    print("Error opening file: $e");
  }
}

void _showDownloadDialog(BuildContext context, String fileName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Download success"),
      content: Text("File saved: $fileName"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}

Future<void> downloadTextFile(BuildContext context, String fileUrl) async {
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
      throw Exception("Greška pri preuzimanju fajla: ${response.statusCode}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Greška: $e")),
    );
  }
}
