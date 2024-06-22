import 'package:flutter/material.dart';
import 'package:pfa/nodejs/rest_api_prof.dart';
import 'package:pfa/admin/models/professor.dart';
import 'package:pfa/admin/add_prof/form_ajout_prof.dart';
import 'package:pfa/admin/edit_prof/form_edit_prof.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfesseurScreen extends StatefulWidget {
  const ProfesseurScreen({Key? key}) : super(key: key);

  @override
  State<ProfesseurScreen> createState() => _ProfesseurScreenState();
}

class _ProfesseurScreenState extends State<ProfesseurScreen> {
  late List<Professor> professors = [];
  late List<Professor> filteredProfessors = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfessors();
  }

  Future<void> fetchProfessors() async {
    final List<Professor> fetchedProfessors = await RestApi.fetchProfessors();
    setState(() {
      professors = fetchedProfessors;
      filteredProfessors = List.from(professors);
    });
  }

  void filterProfessors(String query) {
    List<Professor> searchResult = professors
        .where((professor) =>
    professor.nom.toLowerCase().contains(query.toLowerCase()) ||
        professor.prenom.toLowerCase().contains(query.toLowerCase()) ||
        professor.email.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredProfessors = searchResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Listes des professeurs",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            width: 400,
            height: 70,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                filterProfessors(value);
              },
              decoration: InputDecoration(
                hintText: 'Chercher un prof',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.only(left: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height:40),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Container(

                    margin: EdgeInsets.symmetric(horizontal: 25), // Ajout de la marge
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                      headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.transparent),
                      columns: [
                        DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Prénom', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: filteredProfessors
                          .map(
                            (professor) => DataRow(
                          cells: [
                            DataCell(Text(professor.nom)),
                            DataCell(Text(professor.prenom)),
                            DataCell(Text(professor.email)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _showEditForm(professor.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _showConfirmationDialog(professor.id, professor.nom);
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProfessorForm()),
          ).then((_) {
            fetchProfessors();
          });
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showEditForm(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfForm(professorId: id)),
    ).then((_) {
      fetchProfessors();
    });
  }

  void _showConfirmationDialog(int id, String nom) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer $nom ?'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce professeur ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _deleteProfessor(id);
                Navigator.of(context).pop();
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProfessor(int id) {
    Professor professorToDelete = professors.firstWhere((professor) => professor.id == id);

    RestApi.deleteProfessor(id).then((_) {
      Fluttertoast.showToast(
        msg: 'Professeur ${professorToDelete.nom} ${professorToDelete.prenom} supprimé avec succès',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      fetchProfessors();
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Erreur lors de la suppression du professeur',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }
}