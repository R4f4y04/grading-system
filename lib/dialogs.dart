import 'package:flutter/material.dart';
import 'loading_screen.dart';
import 'ResultPage.dart'; // Replace with the actual file for the next page
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Function to send grading configuration to the backend
Future<void> sendGradingConfig(Map<String, dynamic> gradingConfig) async {
  const url = 'http://127.0.0.1:8000/process-grading/';

  // Debug print to check file data
  print('File Name: ${gradingConfig["fileName"]}');
  print('File Bytes Length: ${gradingConfig["fileBytes"]?.length}');
  print('Grade Config: $gradingConfig');

  // Create multipart request
  var request = http.MultipartRequest('POST', Uri.parse(url));

  // Add file if present
  if (gradingConfig["fileBytes"] != null) {
    request.files.add(http.MultipartFile.fromBytes(
        'file', gradingConfig["fileBytes"],
        filename: gradingConfig["fileName"] ?? 'file.csv'));
  }

  // Add other grading parameters
  request.fields['type'] = gradingConfig["type"] ?? '';
  if (gradingConfig["distribution"] != null) {
    request.fields['distribution'] = json.encode(gradingConfig["distribution"]);
  }
  if (gradingConfig["thresholds"] != null) {
    request.fields['thresholds'] = json.encode(gradingConfig["thresholds"]);
  }

  try {
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception("Failed to send grading config: ${response.statusCode}");
    }
  } catch (e) {
    print('Error sending request: $e');
    throw e;
  }
}

/// Dialog for selecting grading options
void showGradingOptionsDialog(BuildContext context,
    Map<String, dynamic> gradingConfig, Function setState) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select Grading Type"),
        content: Text("Choose the grading method you want to apply."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showRelativeGradingDialog(context, gradingConfig, setState);
            },
            child: Text("Relative Grading"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showAbsoluteGradingDialog(context, gradingConfig, setState);
            },
            child: Text("Absolute Grading"),
          ),
        ],
      );
    },
  );
}

/// Dialog for configuring relative grading
void showRelativeGradingDialog(BuildContext context,
    Map<String, dynamic> gradingConfig, Function setState) {
  Map<String, double> gradeDistribution = {
    "A": 10.0,
    "B": 25.0,
    "C": 30.0,
    "D": 25.0,
    "F": 10.0,
  };

  // Debug print to verify incoming data
  print('Incoming file data:');
  print('File name: ${gradingConfig["fileName"]}');
  print('File bytes length: ${gradingConfig["fileBytes"]?.length}');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Relative Grading"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: gradeDistribution.keys.map((key) {
            return Row(
              children: [
                Text("$key:"),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "%"),
                    onChanged: (value) {
                      gradeDistribution[key] =
                          double.tryParse(value) ?? gradeDistribution[key]!;
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                // Preserve file data while updating grading config
                final fileBytes = gradingConfig["fileBytes"];
                final fileName = gradingConfig["fileName"];

                gradingConfig["type"] = "relative";
                gradingConfig["distribution"] = gradeDistribution;

                // Restore file data
                gradingConfig["fileBytes"] = fileBytes;
                gradingConfig["fileName"] = fileName;
              });

              // Debug print after update
              print('Updated config:');
              print('File name: ${gradingConfig["fileName"]}');
              print('File bytes length: ${gradingConfig["fileBytes"]?.length}');

              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoadingScreen(
                    loadingTask: () async {
                      await sendGradingConfig(gradingConfig);
                    },
                    nextPage: ResultPage(),
                  ),
                ),
              );
            },
            child: Text("Confirm"),
          ),
        ],
      );
    },
  );
}

/// Dialog for configuring absolute grading
void showAbsoluteGradingDialog(BuildContext context,
    Map<String, dynamic> gradingConfig, Function setState) {
  Map<String, double> gradeThresholds = {
    "A": 90.0,
    "B": 80.0,
    "C": 70.0,
    "D": 60.0,
    "F": 0.0,
  };

  // Debug print to verify incoming data
  print('Incoming file data:');
  print('File name: ${gradingConfig["fileName"]}');
  print('File bytes length: ${gradingConfig["fileBytes"]?.length}');

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Absolute Grading"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: gradeThresholds.keys.map((key) {
            return Row(
              children: [
                Text("$key >="),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "%"),
                    onChanged: (value) {
                      gradeThresholds[key] =
                          double.tryParse(value) ?? gradeThresholds[key]!;
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                // Preserve file data while updating grading config
                final fileBytes = gradingConfig["fileBytes"];
                final fileName = gradingConfig["fileName"];

                gradingConfig["type"] = "absolute";
                gradingConfig["thresholds"] = gradeThresholds;

                // Restore file data
                gradingConfig["fileBytes"] = fileBytes;
                gradingConfig["fileName"] = fileName;
              });

              // Debug print after update
              print('Updated config:');
              print('File name: ${gradingConfig["fileName"]}');
              print('File bytes length: ${gradingConfig["fileBytes"]?.length}');

              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoadingScreen(
                    loadingTask: () async {
                      await sendGradingConfig(gradingConfig);
                    },
                    nextPage: ResultPage(),
                  ),
                ),
              );
            },
            child: Text("Confirm"),
          ),
        ],
      );
    },
  );
}
