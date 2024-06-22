import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:pfa/admin/module/Module.dart';

import '../nodejs/rest_api.dart';
import 'Edit_niveau/form_edit_nv.dart';
import 'add_niveau/form_ajout_nv.dart';

class NiveauScreen extends StatefulWidget {
  const NiveauScreen({Key? key}) : super(key: key);

  @override
  State<NiveauScreen> createState() => _NiveauScreenState();
}

class _NiveauScreenState extends State<NiveauScreen> {
  List _niveauNames = [];
  List _filteredNiveauNames = [];
  String _searchQuery = '';
  bool _showModuleScreen = false;
  late int _selectedNiveauId;

  //fetch
  Future<void> _fetchNiveauNames() async {
    final cards = await NiveauCards();
    setState(() {
      _niveauNames = cards;
      _filteredNiveauNames = cards;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNiveauNames();
  }

  //delete
  void _deleteCardNiveau(int niveauId) async {
    final decodedData = await deleteNiveau(niveauId);
    if (decodedData['success']) {
      setState(() {
        _filteredNiveauNames =
            _filteredNiveauNames.where((niveau) => niveau['id'] != niveauId)
                .toList();
        _niveauNames =
            _niveauNames.where((niveau) => niveau['id'] != niveauId).toList();
      });

      Fluttertoast.showToast(msg: 'Card deleted successfully');
    }
  }

  //search
  void _filterNiveauNames() {
    setState(() {
      _filteredNiveauNames = _niveauNames.where((niveau) {
        return niveau['nom'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  // Method to handle card tap
  void _handleCardTap(int niveauId) {
    setState(() {
      _selectedNiveauId = niveauId;
      _showModuleScreen = true;
    });
  }

  // Function to hide ModuleScreen
  void _hideModuleScreen() {
    setState(() {
      _showModuleScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Visibility(
            visible: !_showModuleScreen,
            // Masquer lorsque _showModuleScreen est vrai
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Niveaux",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: !_showModuleScreen,
            // Masquer lorsque _showModuleScreen est vrai
            child: Container(
              padding: EdgeInsets.all(16.0),
              width: 400,
              height: 70,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  _filterNiveauNames();
                },
                decoration: InputDecoration(
                  hintText: 'Search Niveau',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.only(left: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: !_showModuleScreen,
            // Masquer lorsque _showModuleScreen est vrai
            child: Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                itemCount: _filteredNiveauNames.length,
                itemBuilder: (context, index) {
                  final niveau = _filteredNiveauNames[index];
                  return GestureDetector(
                    onTap: () => _handleCardTap(niveau['id']),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Card(
                        child: ListTile(
                          title: Text(niveau['nom']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit , color: Colors.blue,),
                                tooltip: 'modifier ce niveau',
                                onPressed: () {
                                  Route route = MaterialPageRoute(
                                    builder: (_) => FormEditNiveauWidget(
                                        id: niveau['id'],
                                        nom: niveau['nom'],
                                        listeStudent: niveau['listestudent']),
                                  );
                                  Navigator.pushReplacement(context, route);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete , color: Colors.red,),
                                tooltip: 'supprimer ce niveau',
                                onPressed: () =>
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  animType: AnimType.rightSlide,
                                  title: 'Supprimer un niveau',
                                  desc: 'Voulez-vous vraiment supprimer ce niveau ',
                                  width: 600,
                                  btnOkText: "Oui",
                                  btnCancelText: "Non",
                                  btnCancelOnPress: () {},
                                  btnOkOnPress: () {
                                    _deleteCardNiveau(niveau['id']);
                                  },
                                )
                                  ..show(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_showModuleScreen)
            ModuleScreen(
              id: _selectedNiveauId,
              nom: _filteredNiveauNames.firstWhere((element) =>
              element['id'] == _selectedNiveauId)['nom'],
              hideModuleScreen: _hideModuleScreen,
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Visibility(
        visible: !_showModuleScreen,
        // Masquer lorsque _showModuleScreen est vrai
        child: FloatingActionButton(
          tooltip: 'ajouter un niveau',
          onPressed: () {
            Route route = MaterialPageRoute(builder: (_) => FormNiveauWidget());
            Navigator.pushReplacement(context, route);
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.blue[700],
        ),
      ),
    );
  }

}