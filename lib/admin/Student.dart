// import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pfa/admin/edit_student/form_edit_student.dart';
import 'package:pfa/admin/models/student.dart';
import 'package:pfa/nodejs/rest_api_student.dart';
import 'package:pfa/admin/add_student/form_ajout_student.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Student> students = []; // Liste des étudiants
  List<Student> filteredStudents = []; // Liste filtrée des étudiants
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStudents(); // Charger les étudiants depuis la source de données
    // Peut-être utile d'appeler setState() ici si les données sont récupérées de manière asynchrone
  }

  Future<void> fetchStudents() async {
    final List<Student> fetchedstudents = await RestApi.fetchStudentsFromAPI();
    setState(() {
      students = fetchedstudents;
      filteredStudents = List.from(students);
    });
  }

  void filterStudents() {
    // Filtrer les étudiants en fonction de la requête
    setState(() {
      filteredStudents = students.where((student) {
        final name = '${student.nom} ${student.prenom}'.toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Padding(
              padding:const EdgeInsets.all(16.0),
              child: Text(
                "Liste des étudiants",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:const EdgeInsets.all(16.0),
            width: 400,
            height: 70,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                filterStudents();
              },
              decoration: InputDecoration(
                hintText: 'Rechercher un étudiant',
                prefixIcon:const Icon(Icons.search),
                contentPadding:const EdgeInsets.only(left: 8), // Adjust left padding to align with icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: SizedBox(
                  width: 700, // Réduire la largeur du DataTable
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    dataRowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                    columns:const [
                      DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Prénom', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Niveau', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filteredStudents
                        .map(
                          (student) => DataRow(
                        cells: [
                          DataCell(Text(student.nom)),
                          DataCell(Text(student.prenom)),
                          DataCell(Text(student.email)),
                          DataCell(Text(student.niveau)),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon:const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showEditForm(student);
                                  },
                                ),
                                IconButton(
                                  icon:const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showConfirmationDialog(student.id!, student.nom, student.prenom);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: 'Ajouter un étudiant depuis un fichier Excel',
            onPressed: _pickExcelFile,
            backgroundColor: Colors.green,
            child: const Icon(Icons.upload_file),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            tooltip: 'Ajouter un étudiant',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormStudentWidget()),
              ).then((_) {
                fetchStudents();
              });
            },
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showEditForm(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormEditStudentWidget(
          id: student.id!,
          nom: student.nom,
          prenom: student.prenom,
          email: student.email,
          password:student.password,
          niveau: student.niveau,
        ),
      ),
    ).then((_) {
      fetchStudents();
    });
  }

  void _showConfirmationDialog(int id, String name, String prenom) {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.rightSlide,
        width: 600,
        title: 'Supprimer $name $prenom ?',
        desc: "Êtes-vous sûr de vouloir supprimer l'étudiant $name $prenom ?",
        btnCancelText: 'Annuler',
        btnCancelOnPress: () {},
        btnOkText: 'Supprimer',
        btnOkOnPress: () {
          _deleteStudent(id);
        }
    ).show();
  }

  void _deleteStudent(int id) {
    Student studentToDelete = students.firstWhere((student) => student.id == id);

    RestApi.deleteStudent(id).then((_) {
      Fluttertoast.showToast(
        msg: 'student ${studentToDelete.nom} ${studentToDelete.prenom} supprimé avec succès',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      fetchStudents();
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de la suppression du student',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

Future<void> _pickExcelFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'],
  );

  if (result != null) {
    // Utilisez directement les bytes du fichier
    List<int> bytes = result.files.single.bytes!;

    // Appel à la méthode de lecture
    _readExcelFile(bytes);
  } else {
    // L'utilisateur n'a pas sélectionné de fichier
  }
}



Future<void> _readExcelFile(List<int> bytes) async {
  try {
    // Lire le contenu du fichier Excel
    var excel = Excel.decodeBytes(bytes);

    // Vérifier que les en-têtes de colonne sont corrects
    var headers = excel.tables[excel.tables.keys.first]?.rows.first.map((cell) => cell?.value.toString()).toList();
    if (!headers!.contains('nom') || !headers.contains('prenom') || !headers.contains('email') || !headers.contains('password') || !headers.contains('niveau')) {
      // Afficher un message d'erreur si les en-têtes de colonne sont incorrects
      Fluttertoast.showToast(
        msg: 'Le fichier Excel ne contient pas les colonnes requises',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le fichier Excel ne contient pas les colonnes requises')),
      );
      return;
    }

    // Lire les données des étudiants
    List<Student> newStudents = [];
    for (var row in excel.tables[excel.tables.keys.first]!.rows.skip(1)) {
      // Convertir les valeurs des cellules en chaînes de caractères pour éviter les erreurs de type
      newStudents.add(Student(
        // id: int.tryParse(row[headers.indexOf('id')]?.value.toString() ?? '') ?? 0,
        nom: row[headers.indexOf('nom')]?.value.toString() ?? '',
        prenom: row[headers.indexOf('prenom')]?.value.toString() ?? '',
        email: row[headers.indexOf('email')]?.value.toString() ?? '',
        password: row[headers.indexOf('password')]?.value.toString() ?? '',
        niveau: row[headers.indexOf('niveau')]?.value.toString() ?? '',
      ));
    }

    // Vérifier s'il y a des doublons avec les étudiants existants
    List<Student> uniqueNewStudents = [];
    for (var newStudent in newStudents) {
      bool isDuplicate = false;
      for (var existingStudent in students) {
        if (newStudent.id == existingStudent.id) {
          isDuplicate = true;
          break;
        }
      }
      if (!isDuplicate) {
        uniqueNewStudents.add(newStudent);
      }
    }

    // Ajouter les nouveaux étudiants à la liste existante
    setState(() {
      students.addAll(uniqueNewStudents);
      filteredStudents.addAll(uniqueNewStudents); // Mise à jour de la liste filtrée également
    });

    // Insérer les nouveaux étudiants dans la base de données
    RestApi.addStudentsToDatabase(uniqueNewStudents);
  } catch (error) {
    // Gérer les erreurs lors de la lecture du fichier Excel
    print('Erreur lors de la lecture du fichier Excel : $error');
    Fluttertoast.showToast(
      msg: 'Erreur lors de la lecture du fichier Excel',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}



}