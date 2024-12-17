// dialogs.dart
import 'package:flutter/material.dart';

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
    "A": 0.0,
    "B": 0.0,
    "C": 0.0,
    "D": 0.0,
    "F": 0.0,
  };

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
                      gradeDistribution[key] = double.tryParse(value) ?? 0.0;
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
                gradingConfig.clear();
                gradingConfig["type"] = "relative";
                gradingConfig["distribution"] = gradeDistribution;
              });
              Navigator.of(context).pop();
            },
            child: Text("Confirm"),
          ),
        ],
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
                gradingConfig.clear();
                gradingConfig["type"] = "absolute";
                gradingConfig["thresholds"] = gradeThresholds;
              });
              Navigator.of(context).pop();
            },
            child: Text("Confirm"),
          ),
        ],
      );
    },
  );
}
