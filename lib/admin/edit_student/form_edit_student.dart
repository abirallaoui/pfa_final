import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pfa/nodejs/rest_api.dart';
import 'package:pfa/nodejs/rest_api_student.dart';

class FormEditStudentWidget extends StatefulWidget {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String niveau;

  const FormEditStudentWidget({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.niveau, required String password,
  });

  @override
  _FormEditStudentWidgetState createState() => _FormEditStudentWidgetState();
}

class _FormEditStudentWidgetState extends State<FormEditStudentWidget> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late Color _nomFillColor;
  late Color _prenomFillColor;
  late Color _emailFillColor;
  List<String> _niveaux = [];
  String? _selectedNiveau;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.nom);
    _prenomController = TextEditingController(text: widget.prenom);
    _emailController = TextEditingController(text: widget.email);
    _nomFillColor = Colors.white;
    _prenomFillColor = Colors.white;
    _emailFillColor = Colors.white;
    _selectedNiveau = widget.niveau;
    _fetchNiveauxFromDatabase();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchNiveauxFromDatabase() async {
    try {
      List<String> niveauxFromDatabase = await fetchNiveauxFromDatabase();
      setState(() {
        _niveaux = niveauxFromDatabase;
      });
    } catch (e) {
      print('Erreur lors de la récupération des niveaux depuis la base de données : $e');
    }
  }

  void _updateFormStudent() async {
    final newNom = _nomController.text;
    final newPrenom = _prenomController.text;
    final newEmail = _emailController.text;
    final newNiveau = _selectedNiveau;

    if (newNom.isEmpty || newPrenom.isEmpty || newEmail.isEmpty || newNiveau == null) {
      Fluttertoast.showToast(
        msg: "Veuillez remplir tous les champs.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    try {
      await RestApi.UpdateStudent(widget.id, newNom, newPrenom, newEmail, newNiveau);

      Fluttertoast.showToast(
        msg: "Étudiant modifié avec succès.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      Navigator.pop(context);
    } catch (e) {
      print("Erreur lors de la modification de l'étudiant : $e");
      Fluttertoast.showToast(
        msg: "Erreur lors de la modification des données de l'étudiant.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modifier l\'étudiant ${widget.nom} ${widget.prenom}',
              style: const TextStyle(
                fontFamily: 'Outfit',
                color: Color(0xFF15161E),
                fontSize: 24,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding:const EdgeInsetsDirectional.fromSTEB(0, 8, 12, 8),
            child: Ink(
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon:const  Icon(
                  Icons.close_rounded,
                  color: Color(0xFF15161E),
                  size: 24,
                ),
                iconSize: 40,
                color: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                padding: EdgeInsets.zero,
                constraints:const  BoxConstraints.tightFor(width: 40, height: 40),
              ),
            ),
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      
      body: Center(
      
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          padding:const  EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              TextField(
                controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  color: Color(0xFF606A85),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:const  BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _nomFillColor == Colors.white ? const Color(0xFF6F61EF) : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: _nomFillColor,
                contentPadding:const  EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              style:const  TextStyle(
                fontFamily: 'Figtree',
                color: Color(0xFF15161E),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: const Color(0xFF6F61EF),
              onTap: () {
                setState(() {
                  _nomFillColor = const Color(0x4D9489F5);
                  _prenomFillColor = Colors.white;
                  _emailFillColor = Colors.white;
                });
              },
            ),
              const SizedBox(height: 12),
              TextField(
                controller: _prenomController,
                decoration: InputDecoration(
                labelText: 'Prénom',
                labelStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  color: Color(0xFF606A85),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _prenomFillColor == Colors.white ? const Color(0xFF6F61EF) : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: _prenomFillColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              style:const TextStyle(
                fontFamily: 'Figtree',
                color: Color(0xFF15161E),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: const Color(0xFF6F61EF),
              onTap: () {
                setState(() {
                  _nomFillColor = Colors.white;
                  _prenomFillColor = const Color(0x4D9489F5);
                  _emailFillColor = Colors.white;
                });
              },
            ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: const TextStyle(
                  fontFamily: 'Outfit',
                  color: Color(0xFF606A85),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _emailFillColor == Colors.white ? const Color(0xFF6F61EF) : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: _emailFillColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              ),
              style: const TextStyle(
                fontFamily: 'Figtree',
                color: Color(0xFF15161E),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: const Color(0xFF6F61EF),
              onTap: () {
                setState(() {
                  _nomFillColor = Colors.white;
                  _prenomFillColor = Colors.white;
                  _emailFillColor = const Color(0x4D9489F5);
                });
              },
            ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedNiveau,
                onChanged: (value) {
                  setState(() {
                    _nomFillColor = Colors.white;
                  _prenomFillColor = Colors.white;
                    _selectedNiveau = value;
                    _emailFillColor = Colors.white;

                  });
                },
                items: _niveaux.map((niveau) {
                  return DropdownMenuItem<String>(
                    value: niveau,
                    child: Text(niveau),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Niveau',
                  labelStyle: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Color(0xFF606A85),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner le niveau de l\'étudiant';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _updateFormStudent,
                
                style: ElevatedButton.styleFrom(
                  minimumSize:const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  backgroundColor: const Color.fromARGB(255, 78, 78, 228),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:const  Text(
                  "Sauvegarder les modifications",
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    letterSpacing: 0,
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
