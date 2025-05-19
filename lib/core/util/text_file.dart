import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

import '../../assets/colors/Colors.dart';
import '../extension/color.dart';

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
                style:   TextStyle(color: ColorUtil.getColorScheme(context).error),
              ),
              IconButton(
                icon: const Icon(Icons.download),
                color: ColorUtil.getColorScheme(context).error,
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

    Response response = await dio.get(
      fileUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      final blob = html.Blob([response.data]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = fileName
        ..click();

      html.Url.revokeObjectUrl(url);

      _showDownloadDialog(context, fileName);
    } else {
      throw Exception("Error while downloading: ${response.statusCode}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}
