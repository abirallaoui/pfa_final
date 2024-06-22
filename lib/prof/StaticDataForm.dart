import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pfa/nodejs/utils.dart';

class StaticDataForm extends StatefulWidget {
  final Function(String, String, String, String, String, String) onStaticDataChanged;
  final Map<String, dynamic>? user;

  StaticDataForm({required this.onStaticDataChanged, this.user});

  @override
  _StaticDataFormState createState() => _StaticDataFormState();
}

class _StaticDataFormState extends State<StaticDataForm> {
  String _staticData1 = '';
  String _staticData2 = '';
  String _staticData3 = '';
  late DateTime selectedDateTime;
  late String _staticData4 = "Selected Date & Time: ${DateTime.now().toString()}";
  String niveauName = '';
  String moduleName = '';
  List<Map<String, dynamic>> niveaux = [];
  List<Map<String, dynamic>> modules = [];

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now();
    fetchNiveaux();
  }

  Future<void> fetchNiveaux() async {
    try {
      final email = widget.user?['email'];
      if (email == null || email.isEmpty) {
        throw Exception('Email du professeur est requis');
      }

      final response = await http.get(
        Uri.parse('${Utils.baseUrl}/profQR/niveaux?email=$email'),
        headers: {
          'Authorization': 'Bearer ${widget.user!['token']}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          niveaux = data.map((niveau) => {
            'id': niveau['id'],
            'nom': niveau['nom']
          }).toList();
        });
      } else {
        print('Failed to load niveaux. Status code: ${response.statusCode}');
        throw Exception('Failed to load niveaux');
      }
    } catch (e) {
      print('Error fetching niveaux: $e');
    }
  }

  Future<void> fetchModules(int niveauId) async {
    try {
      final email = widget.user?['email'];
      if (email == null || email.isEmpty) {
        throw Exception('Email du professeur est requis');
      }

      final response = await http.get(
        Uri.parse('${Utils.baseUrl}/profQR/modules?email=$email&niveauId=$niveauId'),
        headers: {
          'Authorization': 'Bearer ${widget.user!['token']}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          modules = data.map((module) => {
            'id': module['id'],
            'nom': module['nom']
          }).toList();
        });
      } else {
        throw Exception('Failed to load modules. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching modules: $e');
    }
  }

  Future<void> fetchModuleSalle(int moduleId) async {
    try {
      final response = await http.get(
        Uri.parse('${Utils.baseUrl}/profQR/module/$moduleId/salle'),
        headers: {
          'Authorization': 'Bearer ${widget.user!['token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _staticData3 = data['salle'].toString();
          widget.onStaticDataChanged(
            _staticData1, _staticData2, _staticData3, _staticData4, niveauName, moduleName
          );
        });
      } else {
        throw Exception('Failed to load module salle. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching module salle: $e');
    }
  }

  void _showDatePicker() async {
    DateTime? userSelectedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (userSelectedDate != null) {
      setState(() {
        selectedDateTime = DateTime(
          userSelectedDate.year,
          userSelectedDate.month,
          userSelectedDate.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
        _updateStaticData4();
      });
    }
  }

  void _showTimePicker() async {
    TimeOfDay? userSelectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );

    if (userSelectedTime != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          userSelectedTime.hour,
          userSelectedTime.minute,
        );
        _updateStaticData4();
      });
    }
  }

  void _updateStaticData4() {
    setState(() {
      _staticData4 =
      "Selected Date & Time: ${selectedDateTime.year}/${selectedDateTime.month}/${selectedDateTime.day} ${selectedDateTime.hour}:${selectedDateTime.minute}";
    });
    widget.onStaticDataChanged(
        _staticData1, _staticData2, _staticData3, _staticData4, niveauName, moduleName);
  }

  Future<void> insertQRCode() async {
    try {
      final response = await http.post(
        Uri.parse('${Utils.baseUrl}/profQR/insertQR'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.user!['token']}',
        },
        body: jsonEncode({
          'id_prof': widget.user!['id'],
          'id_module': _staticData1,
          'date': selectedDateTime.toIso8601String(),
          'id_niveau': _staticData2,
          'salle': _staticData3,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Code QR inséré avec succès",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        throw Exception('Failed to insert QR code. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error inserting QR code: $e');
      Fluttertoast.showToast(
        msg: "Erreur lors de l'insertion du code QR",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButtonFormField<int>(
                  value: _staticData2.isEmpty ? null : int.parse(_staticData2),
                  onChanged: (value) {
                    setState(() {
                      _staticData2 = value.toString();
                      niveauName = niveaux.firstWhere((niveau) => niveau['id'] == value)['nom'];
                      fetchModules(value!);
                      _staticData1 = '';
                      _staticData3 = '';
                      widget.onStaticDataChanged(
                          _staticData1, _staticData2, _staticData3, _staticData4, niveauName, moduleName);
                    });
                  },
                  items: niveaux.map((niveau) {
                    return DropdownMenuItem<int>(
                      value: niveau['id'],
                      child: Text(niveau['nom']),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    hintText: 'Niveau',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (modules.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: _staticData1.isEmpty ? null : int.parse(_staticData1),
                    onChanged: (value) {
                      setState(() {
                        _staticData1 = value.toString();
                        moduleName = modules.firstWhere((module) => module['id'] == value)['nom'];
                        fetchModuleSalle(value!);
                      });
                    },
                    items: modules.map((module) {
                      return DropdownMenuItem<int>(
                        value: module['id'],
                        child: Text(module['nom']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                      hintText: 'Module',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                TextField(
                  controller: TextEditingController(text: _staticData3),
                  onChanged: (value) {
                    setState(() {
                      _staticData3 = value;
                      widget.onStaticDataChanged(
                          _staticData1, _staticData2, _staticData3, _staticData4, niveauName, moduleName);
                    });
                  },
                  enabled: false, // Désactiver la saisie de texte
                  decoration: InputDecoration(
                    hintText: 'Salle',
                    contentPadding: EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                Text(
                  _staticData4,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _showDatePicker,
                      child: Text('Select Date'),
                    ),
                    ElevatedButton(
                      onPressed: _showTimePicker,
                      child: Text('Select Time'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_staticData1.isNotEmpty && _staticData2.isNotEmpty && _staticData3.isNotEmpty && _staticData4.isNotEmpty) {
                      // Vérifier si la date et l'heure sont sélectionnées
                      if (selectedDateTime != null) {
                        // Enregistrer le code QR dans la base de données
                        insertQRCode().then((_) {
                          // Changer l'onglet actif à l'onglet du code QR dynamique
                          DefaultTabController.of(context)?.animateTo(1);
                        });
                      } else {
                        // Afficher un toast si la date et l'heure ne sont pas sélectionnées
                        Fluttertoast.showToast(
                          msg: "Veuillez sélectionner une date et une heure",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    } else {
                      // Afficher un toast si un champ est vide
                      Fluttertoast.showToast(
                        msg: "Veuillez remplir tous les champs",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: Text('Générer le code QR'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

