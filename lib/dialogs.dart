import 'package:flutter/material.dart';
import 'loading_screen.dart';
import 'ResultPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const url = 'http://127.0.0.1:8000/process-grading/';

Future<Map<String, dynamic>> sendGradingConfig(
    Map<String, dynamic> gradingConfig) async {
  var request = http.MultipartRequest('POST', Uri.parse(url));

  if (gradingConfig["fileBytes"] != null) {
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        gradingConfig["fileBytes"],
        filename: gradingConfig["fileName"] ?? 'file.csv',
      ),
    );
  }

  request.fields['type'] = gradingConfig["type"] ?? '';
  if (gradingConfig["distribution"] != null) {
    request.fields['distribution'] = json.encode(gradingConfig["distribution"]);
  }
  if (gradingConfig["thresholds"] != null) {
    request.fields['thresholds'] = json.encode(gradingConfig["thresholds"]);
  }

  try {
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return json.decode(responseBody);
    } else {
      throw Exception("Failed to send grading config: ${response.statusCode}");
    }
  } catch (e) {
    print('Error sending request: $e');
    throw e;
  }
}

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

void showRelativeGradingDialog(BuildContext context,
    Map<String, dynamic> gradingConfig, Function setState) {
  Map<String, double> gradeDistribution = {
    "A": 10.0,
    "B": 25.0,
    "C": 30.0,
    "D": 25.0,
    "F": 10.0,
  };

  bool isValidDistribution() {
    double total =
        gradeDistribution.values.fold(0, (sum, value) => sum + value);
    return total == 100.0;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Relative Grading"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...gradeDistribution.keys.map((key) {
                  return Row(
                    children: [
                      Text("$key:"),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "%",
                            errorText: gradeDistribution[key]! < 0
                                ? "Cannot be negative"
                                : null,
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              gradeDistribution[key] =
                                  double.tryParse(value)?.abs() ??
                                      gradeDistribution[key]!;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 16),
                Text(
                  "Total: ${gradeDistribution.values.fold(0.0, (sum, value) => sum + value)}%",
                  style: TextStyle(
                    color: isValidDistribution() ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isValidDistribution()
                    ? () {
                        setState(() {
                          gradingConfig["type"] = "relative";
                          gradingConfig["distribution"] = gradeDistribution;
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoadingScreen(
                              loadingTask: () async {
                                return await sendGradingConfig(gradingConfig);
                              },
                              nextPage: (data) => ResultPage(data: data),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text("Confirm"),
              ),
            ],
          );
        },
      );
    },
  );
}

void showAbsoluteGradingDialog(BuildContext context,
    Map<String, dynamic> gradingConfig, Function setState) {
  Map<String, double> gradeThresholds = {
    "A": 90.0,
    "B": 80.0,
    "C": 70.0,
    "D": 60.0,
    "F": 0.0,
  };

  bool isValidThresholds() {
    var values = gradeThresholds.values.toList();
    for (int i = 0; i < values.length - 1; i++) {
      if (values[i] <= values[i + 1]) return false;
    }
    return values.every((v) => v >= 0 && v <= 100);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Absolute Grading"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...gradeThresholds.keys.map((key) {
                  return Row(
                    children: [
                      Text("$key >="),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "%",
                            errorText: gradeThresholds[key]! < 0 ||
                                    gradeThresholds[key]! > 100
                                ? "Enter 0-100"
                                : null,
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              gradeThresholds[key] =
                                  double.tryParse(value)?.abs() ??
                                      gradeThresholds[key]!;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 16),
                Text(
                  isValidThresholds()
                      ? "Valid thresholds"
                      : "Thresholds must be in descending order (0-100)",
                  style: TextStyle(
                    color: isValidThresholds() ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isValidThresholds()
                    ? () {
                        setState(() {
                          gradingConfig["type"] = "absolute";
                          gradingConfig["thresholds"] = gradeThresholds;
                        });
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoadingScreen(
                              loadingTask: () async {
                                return await sendGradingConfig(gradingConfig);
                              },
                              nextPage: (data) => ResultPage(data: data),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text("Confirm"),
              ),
            ],
          );
        },
      );
    },
  );
}
