import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:grading_system/filepreview.dart';
import 'dialogs.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedFile;
  Map<String, dynamic> gradingConfig = {};
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
                    setState(() {
                      selectedFile = result.files.single.name;
                    });

                    // Show selected file name
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Selected file: $selectedFile")),
                    );

                    // Preview file content
                    if (result.files.single.bytes != null) {
                      // Web Compatibility: Use in-memory bytes for preview
                      previewFileFromBytes(
                          result.files.single.bytes!, selectedFile!, context);
                    } else if (result.files.single.path != null) {
                      // Mobile/Desktop Compatibility: Use file path for preview
                      previewFile(result.files.single.path!, context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Unable to read the file")),
                      );
                    }

                    // Show grading options dialog
                    showGradingOptionsDialog(context, gradingConfig, setState);
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
