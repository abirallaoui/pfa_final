import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pfa/nodejs/utils.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class SemesterReportScreen extends StatefulWidget {
  final String emailProf;

  SemesterReportScreen({required this.emailProf});

  @override
  _SemesterReportScreenState createState() => _SemesterReportScreenState();
}

class _SemesterReportScreenState extends State<SemesterReportScreen> {
  late Future<Map<String, dynamic>> _reportFuture;

  @override
  void initState() {
    super.initState();
    DateTime startDate = DateTime(2023, 03, 15);
    DateTime endDate = DateTime(2023, 06, 03);
    _reportFuture = fetchSemesterReport(widget.emailProf, "2", "3", startDate, endDate);
    // Remplacez "2", "3" par les IDs de niveau et module appropriés
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapport Semestriel'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Aucune donnée de rapport disponible'));
          }

          Map<String, dynamic> reportData = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professeur: ${reportData['professor']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Niveau: ${reportData['niveau']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Module: ${reportData['module']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Période: ${reportData['start_date']} à ${reportData['end_date']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                DataTable(
                  columns: [
                    DataColumn(label: Text('Nom de l\'étudiant')),
                    DataColumn(label: Text('% Présence')),
                  ],
                  rows: List<DataRow>.generate(
                    reportData['attendance'].length,
                        (index) => DataRow(
                      cells: [
                        DataCell(Text(reportData['attendance'][index]['student_name'])),
                        DataCell(
                          Text(
                            '${reportData['attendance'][index]['attendance_percentage'].toStringAsFixed(2)}%',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fonction pour formater les dates
  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  // Fonction pour récupérer le rapport semestriel
  Future<Map<String, dynamic>> fetchSemesterReport(String emailProf, String idNiveau, String idModule, DateTime startDate, DateTime endDate) async {
    final String formattedStartDate = formatDate(startDate);
    final String formattedEndDate = formatDate(endDate);

    final Uri uri = Uri.parse(
      '${Utils.baseUrl}/rapports/semestriel?email_prof=$emailProf&id_niveau=$idNiveau&id_module=$idModule&start_date=$formattedStartDate&end_date=$formattedEndDate',
    );
    final response = await http.get(uri, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du téléchargement du rapport semestriel: ${response.statusCode}');
    }
  }
}