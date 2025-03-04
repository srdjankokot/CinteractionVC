import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

Future<void> downloadPdfFile(BuildContext context, String fileUrl) async {
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
      _showDownloadDialog(context, url, fileName);
    } else {
      throw Exception("Erorr while download PDF-a: ${response.statusCode}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

void showPdfDialog(BuildContext context, String pdfUrl) async {
  try {
    Response response = await Dio()
        .get(pdfUrl, options: Options(responseType: ResponseType.bytes));
    if (response.statusCode == 200) {
      final blob = html.Blob([response.data]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.IFrameElement iframe = html.IFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: const SizedBox(
            width: double.infinity,
            height: 400,
            child: HtmlElementView(
              viewType: 'pdf-viewer',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                html.Url.revokeObjectUrl(url);
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        ),
      );

      html.document.getElementById('pdf-viewer')?.append(iframe);
    }
  } catch (e) {
    print("Erorr download PDF: $e");
  }
}

void _showDownloadDialog(
    BuildContext context, String fileUrl, String fileName) {
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
