import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // University Logo Placeholder
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: CircleAvatar(
                  child: Image(
                    image: AssetImage("assets/giki-logo.png"),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                "HEC Regulated Grading System",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                "Upload a CSV or Excel file to get started",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // File Picker Button
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['csv', 'xlsx'],
                  );

                  if (result != null) {
                    final file = result.files.single;
                    // Process the selected file
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Selected file: ${file.name}")),
                    );
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Select Grading Type"),
                          content: Text(
                              "Choose the grading method you want to apply."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Relative grading selected")),
                                );
                              },
                              child: Text("Relative Grading"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Absolute grading selected")),
                                );
                              },
                              child: Text("Absolute Grading"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // User canceled the picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No file selected")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.indigo[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  "Choose File",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
