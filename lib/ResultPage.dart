import 'package:flutter/material.dart';
import 'dart:convert';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    print('Received data structure: $data');

    if (data['status'] != 'success') {
      return Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text(data['message'] ?? 'An error occurred')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Grading Results"),
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            "Grading Analysis Results",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "File: ${data['filename']} | Type: ${(data['grading_type'] ?? '').toString().toUpperCase()}",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Statistics and Histogram
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Statistics",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 16),
                                _buildStatisticRow(
                                    "Mean", data['statistics']['mean']),
                                _buildStatisticRow(
                                    "Median", data['statistics']['median']),
                                _buildStatisticRow(
                                    "Std Dev", data['statistics']['std_dev']),
                                _buildStatisticRow(
                                    "Mode", data['statistics']['mode']),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Grade Distribution",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                SizedBox(height: 16),
                                Image.memory(
                                  base64Decode(
                                      data['visualizations']['histogram']),
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Grades Table
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Student Grades",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text('Registration No')),
                                DataColumn(label: Text('Marks')),
                                DataColumn(label: Text('Grade')),
                              ],
                              rows: List<DataRow>.generate(
                                data['grades']['Marks'].length,
                                (index) => DataRow(
                                  cells: [
                                    DataCell(Text(data['grades']['RegNo']
                                        [index.toString()])),
                                    DataCell(Text(data['grades']['Marks']
                                            [index.toString()]
                                        .toString())),
                                    DataCell(Text(data['grades']['Grade']
                                        [index.toString()])),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value.toStringAsFixed(2)),
        ],
      ),
    );
  }
}
