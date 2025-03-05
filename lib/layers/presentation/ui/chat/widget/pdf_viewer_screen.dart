import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

Future<void> downloadPdfFile(BuildContext context, String fileUrl) async {
  try {
    Dio dio = Dio();
    Uri uri = Uri.parse(fileUrl);

    Response response = await dio.get(
      fileUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    if (response.statusCode == 200) {
      final blob = html.Blob([response.data], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    } else {
      throw Exception("Error while downloading PDF: ${response.statusCode}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

void showPdfDialog(BuildContext context, String pdfUrl) async {
  try {
    Response response = await Dio().get(
      pdfUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.statusCode == 200) {
      final blob = html.Blob([response.data], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    }
  } catch (e) {
    print("Error downloading PDF: $e");
  }
}
