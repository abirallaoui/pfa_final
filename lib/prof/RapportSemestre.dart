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
        title: Text('Rapport Semestriel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 86, 148, 220),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 86, 148, 220)!, Colors.blue[200]!],
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Niveau',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Module',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
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
                          SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.blue[800],
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              if (selectedNiveau != null && selectedModule != null) {
                                fetchReport(selectedNiveau!, selectedModule!);
                              }
                            },
                            child: Text('Générer le Rapport', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: report.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(Colors.blue[100]),
                                columns: const [
                                  DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Prénom', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Présence (%)', style: TextStyle(fontWeight: FontWeight.bold))),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}