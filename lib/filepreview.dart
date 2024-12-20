import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

void previewFile(String filePath, BuildContext context) async {
  String fileExtension = filePath.split('.').last;
  List<List<dynamic>> previewData = [];

  if (fileExtension == 'csv') {
    final input = File(filePath).openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(CsvToListConverter())
        .toList();
    previewData = fields.take(5).toList(); // Limit to first 5 rows
  } else if (fileExtension == 'xlsx') {
    var bytes = File(filePath).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table]!;
      previewData = sheet.rows.take(5).toList(); // Limit to first 5 rows
      break; // Use the first sheet
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unsupported file format")),
    );
    return;
  }

  // Show the preview
  showPreviewDialog(context, previewData);
}

void showPreviewDialog(BuildContext context, List<List<dynamic>> previewData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("File Preview"),
        content: SingleChildScrollView(
          child: Table(
            border: TableBorder.all(),
            children: previewData.map((row) {
              return TableRow(
                children: row.map((cell) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(cell.toString()),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}

void previewFileFromBytes(
    Uint8List bytes, String fileName, BuildContext context) async {
  String fileExtension = fileName.split('.').last;
  List<List<dynamic>> previewData = [];

  if (fileExtension == 'csv') {
    final content = utf8.decode(bytes);
    final fields = CsvToListConverter().convert(content);
    previewData = fields.take(5).toList();
  } else if (fileExtension == 'xlsx') {
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table]!;
      previewData = sheet.rows.take(5).toList();
      break; // Use the first sheet
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unsupported file format")),
    );
    return;
  }

  // Show the preview
  showPreviewDialog(context, previewData);
}
