import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../nodejs/utils.dart';
import '../nodejs/rest_api.dart';

class RapportSemestre extends StatefulWidget {
  final Map<String, dynamic>? user;

  RapportSemestre({Key? key, this.user}) : super(key: key);

  @override
  _RapportSemestreState createState() => _RapportSemestreState();
}

class _RapportSemestreState extends State<RapportSemestre> {
  String apiUrl = '${Utils.baseUrl}/crud/report/';
  List<dynamic> report = [];
  List<String> niveaux = [];
  List<String> modules = [];
  String? selectedNiveau;
  String? selectedModule;

  @override
  void initState() {
    super.initState();
    fetchNiveaux();
    fetchModules();
  }

  fetchNiveaux() async {
    try {
      List<String> niveauxFromAPI = await fetchNiveauxFromAPI(widget.user?['email']);
      setState(() {
        niveaux = niveauxFromAPI;
      });
    } catch (e) {
      print('Error fetching niveaux: $e');
    }
  }

  fetchModules() async {
    try {
      List<String> modulesFromAPI = await fetchModulesForProf(widget.user?['email']);
      setState(() {
        modules = modulesFromAPI;
      });
    } catch (e) {
      print('Error fetching modules: $e');
    }
  }

  fetchReport(String niveauName, String moduleName) async {
    try {
      var result = await http.get(Uri.parse('$apiUrl$niveauName/$moduleName'));
      if (result.statusCode == 200) {
        setState(() {
          report = json.decode(result.body)['report'];
        });
      } else {
        print('Failed to load report');
      }
    } catch (e) {
      print('Error fetching report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Report'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<String>(
                  hint: Text('Select Niveau'),
                  value: selectedNiveau,
                  onChanged: (value) {
                    setState(() {
                      selectedNiveau = value;
                      fetchModules();
                    });
                  },
                  items: niveaux.map((niveau) {
                    return DropdownMenuItem<String>(
                      value: niveau,
                      child: Text(niveau),
                    );
                  }).toList(),
                ),
                SizedBox(width: 16.0),
                DropdownButton<String>(
                  hint: Text('Select Module'),
                  value: selectedModule,
                  onChanged: (value) {
                    setState(() {
                      selectedModule = value;
                    });
                  },
                  items: modules.map((module) {
                    return DropdownMenuItem<String>(
                      value: module,
                      child: Text(module),
                    );
                  }).toList(),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (selectedNiveau != null && selectedModule != null) {
                      fetchReport(selectedNiveau!, selectedModule!);
                    }
                  },
                  child: Text('Generate Report'),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            Expanded(
              child: report.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Prénom')),
                    DataColumn(label: Text('Présence (%)')),
                  ],
                  rows: report.map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row['student_nom'])),
                      DataCell(Text(row['student_prenom'])),
                      DataCell(Text(row['presence_percentage'].toStringAsFixed(2))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}