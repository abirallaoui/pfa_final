import 'package:flutter/widgets.dart';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pfa/nodejs/rest_api.dart';

import 'form_ajout_student_model.dart';
export 'form_ajout_student_model.dart';
import 'package:pfa/nodejs/rest_api_student.dart';




class FormStudentWidget extends StatefulWidget {
  const FormStudentWidget({super.key});

  @override
  State<FormStudentWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormStudentWidget> {
  late FormStudentModel _model;
  List<String> _niveaux = []; // Liste pour stocker les niveaux provenant de la base de données


Future<void> _fetchNiveauxFromDatabase() async {
    try {
      // Appel à votre méthode pour récupérer les niveaux depuis la base de données
      List<String> niveauxFromDatabase = await fetchNiveauxFromDatabase();

      setState(() {
        _niveaux = niveauxFromDatabase;
      });
    } catch (e) {
      print('Erreur lors de la récupération des niveaux depuis la base de données : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // _model = FormStudentModel(); // Initialisation du modèle
    _model = createModel(context, () => FormStudentModel());

    _model.nomController ??= TextEditingController();
    _model.nomFocusNode ??= FocusNode();
    _model.nomFocusNode!.addListener(() => setState(() {}));
    _model.emailController ??= TextEditingController();
    _model.emailFocusNode ??= FocusNode();
    _model.emailFocusNode!.addListener(() => setState(() {}));
    _model.passwordController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
    _model.passwordFocusNode!.addListener(() => setState(() {}));
    _model.prenomController ??= TextEditingController();
    _model.prenomFocusNode ??= FocusNode();
    _model.prenomFocusNode!.addListener(() => setState(() {}));

    // Appel à la méthode pour récupérer les niveaux depuis la base de données
    _fetchNiveauxFromDatabase();
  }

  

  void _addStudent() async {
  final nom = _model.nomController?.text;
  final prenom = _model.prenomController?.text;
  final email = _model.emailController?.text;
  final password = _model.passwordController?.text;
  final niveau = _model.selectedNiveau;

  // Vérifier que tous les champs sont remplis
  if (nom == null || nom.isEmpty ||prenom == null || prenom.isEmpty ||email == null ||email.isEmpty ||
  password == null   || password.isEmpty ||
  niveau == null ||  niveau.isEmpty
  ) {
    Fluttertoast.showToast(
      msg: "Veuillez remplir tous les champs.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
    return;
  }

  try {
    // Appel à une fonction d'ajout d'étudiant à la base de données
    final response = await RestApi.addStudent(nom, prenom, email, password,niveau);
    
    // Si tout se passe bien, afficher un toast
    Fluttertoast.showToast(
      msg: "Étudiant ajouté avec succès.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
      Navigator.pop(context);

  } catch (e) {
    // En cas d'échec, afficher un message d'erreur
    print("Erreur lors de l'ajout de l'étudiant : $e");
    // Afficher un toast pour indiquer qu'il y a eu un problème
    Fluttertoast.showToast(
      msg: "Erreur lors de l'ajout de l'étudiant : $e",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }
}


  final scaffoldKey = GlobalKey<ScaffoldState>();

  FormStudentModel createModel(BuildContext context, FormStudentModel Function() builder) {
    // Implémentez la logique de création de votre modèle ici
    return builder();
  }
  
  

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title:const  Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Ajouter un étudiant',
                style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Color(0xFF15161E),
                      fontSize: 24,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
               Text(
                'Veuillez remplir le formulaire ci-dessous pour continuer.',
                style:TextStyle(
                      fontFamily: 'Outfit',
                      color: Color(0xFF606A85),
                      fontSize: 14,
                      letterSpacing: 0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ]//.divide(SizedBox(height: 4)),
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 12, 8),
              child: Ink(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side:const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon:const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF15161E),
                      size: 24,
                    ),
                    iconSize: 40,
                    color: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    constraints:const BoxConstraints.tightFor(width: 40, height: 40),
                  ),
                ),

            ),
          ],
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: const AlignmentDirectional(0, -1),
                          child: Container(
                            constraints:const  BoxConstraints(
                              maxWidth: 770,
                            ),
                            decoration:const BoxDecoration(),
                            child: Padding(
                              padding:
                                  const EdgeInsetsDirectional.fromSTEB(16, 42, 16, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _model.nomController,
                                    focusNode: _model.nomFocusNode,
                                    autofocus: true,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'nom ',
                                      labelStyle: const TextStyle(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF606A85),
                                            fontSize: 16,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      hintStyle: const TextStyle(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF606A85),
                                            fontSize: 14,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      errorStyle: const TextStyle(
                                            fontFamily: 'Figtree',
                                            color: Color(0xFFFF5963),
                                            fontSize: 12,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color.fromARGB(255, 59, 59, 206),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor:
                                          (_model.nomFocusNode?.hasFocus ??
                                                  false)
                                              ? const Color(0x4D9489F5)
                                              : Colors.white,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
                                    ),
                                    style: const TextStyle(
                                          fontFamily: 'Outfit',
                                          color: Color(0xFF15161E),
                                          fontSize: 16,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                    minLines: null,
                                    cursorColor:const  Color.fromARGB(255, 155, 172, 168),
                                    validator: _model.nomControllerValidator,
                                  ),
                                                          Padding(
                              padding:const EdgeInsetsDirectional.fromSTEB(0, 45, 0, 16),
                              child:  Container(
                                width: double.infinity,
                                  child:
                                  TextFormField(
                                    controller: _model.prenomController,
                                    focusNode: _model.prenomFocusNode,
                                    autofocus: true,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'prénom*',
                                      labelStyle: const TextStyle(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF606A85),
                                            fontSize: 16,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      hintStyle:const TextStyle(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF606A85),
                                            fontSize: 14,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      errorStyle: const TextStyle(
                                            fontFamily: 'Figtree',
                                            color: Color(0xFFFF5963),
                                            fontSize: 12,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFF6F61EF),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: (_model.prenomFocusNode
                                                  ?.hasFocus ??
                                              false)
                                          ? const Color(0x4D9489F5)
                                          : Colors.white,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
                                    ),
                                    style:const TextStyle(
                                          fontFamily: 'Figtree',
                                          color: Color(0xFF15161E),
                                          fontSize: 16,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    minLines: null,
                                    cursorColor: const Color(0xFF6F61EF),
                                    validator: _model.prenomControllerValidator,
                                    //inputFormatters: [_model.prenomMask],
                                  ),
                                ),
                            ),
                          Padding(
                              padding:const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 16),
                                child: Container(
                                  width: double.infinity,
                                    child:
                                    TextFormField(
                                      controller: _model.emailController,
                                      focusNode: _model.emailFocusNode,
                                      autofocus: true,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: 'Email*',
                                        labelStyle: const TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Color(0xFF606A85),
                                              fontSize: 16,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        hintStyle: const TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Color(0xFF606A85),
                                              fontSize: 14,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        errorStyle: const TextStyle(
                                              fontFamily: 'Figtree',
                                              color: Color(0xFFFF5963),
                                              fontSize: 12,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide:const BorderSide(
                                            color: Color(0xFF6F61EF),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide:const BorderSide(
                                            color: Color(0xFFFF5963),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide:const BorderSide(
                                            color: Color(0xFFFF5963),
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        filled: true,
                                        fillColor:
                                            (_model.emailFocusNode?.hasFocus ??
                                                    false)
                                                ? const Color(0x4D9489F5)
                                                : Colors.white,
                                        contentPadding:
                                            const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
                                      ),
                                      style: const TextStyle(
                                            fontFamily: 'Figtree',
                                            color: Color(0xFF15161E),
                                            fontSize: 16,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      minLines: null,
                                      cursorColor:const  Color(0xFF6F61EF),
                                      validator: _model.emailControllerValidator
                                    ),
                                ),
                              ),
                            
                        Padding(
                              padding:const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 16),
                              child:   Container(
                                width: double.infinity,
                                  child:TextFormField(
                                    controller: _model.passwordController,
                                    focusNode: _model.passwordFocusNode,
                                    autofocus: true,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'Mot de passe*',
                                      labelStyle: const TextStyle(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF606A85),
                                            fontSize: 16,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      alignLabelWithHint: true,
                                      hintStyle: const TextStyle(
                                            fontFamily: 'Outfit',
                                            color: Color(0xFF606A85),
                                            fontSize: 14,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      errorStyle: const TextStyle(
                                            fontFamily: 'Figtree',
                                            color: Color(0xFFFF5963),
                                            fontSize: 12,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          color: Color(0xFF6F61EF),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide:const BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: (_model.passwordFocusNode
                                                  ?.hasFocus ??
                                              false)
                                          ? const Color(0x4D9489F5)
                                          : Colors.white,
                                      contentPadding:
                                          const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
                                    ),
                                    style: const TextStyle(
                                          fontFamily: 'Figtree',
                                          color: Color(0xFF15161E),
                                          fontSize: 16,
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    minLines: null,
                                    cursorColor:const  Color(0xFF6F61EF),
                                    validator: _model.passwordControllerValidator
                                  ),),
                            ),
                            DropdownButtonFormField<String>(
                              value: _model.selectedNiveau,
                              onChanged: (value) {
                                setState(() {
                                  _model.selectedNiveau = value!;
                                });
                              },
                              items: _niveaux.map((niveau) {
                                return DropdownMenuItem<String>(
                                  value: niveau,
                                  child: Text(niveau),
                                );
                              }).toList(),
                              decoration:  InputDecoration(
                                labelText: 'Niveau',
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
              

                                  
                                  const SizedBox(height: 12),
                                ]
                                    ..addAll([const SizedBox(height: 32)])
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 770,
                  ),
                  decoration:const BoxDecoration(),
                  child: 
                  Padding(
                    padding:const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 42),
                    child: ElevatedButton(
                      onPressed: () async {
                        _addStudent();
            
          },
                          child:     Text("Ajouter l'étudiant",
                          style:   TextStyle(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.white,
                                      letterSpacing: 0,
                                    ),), // Texte du bouton modifié
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        //height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 24), // Modification de la méthode de déclaration du padding
                        //iconPadding: EdgeInsets.zero, // Utilisation de EdgeInsets.zero pour un padding nul
                        backgroundColor: const Color.fromARGB(255, 78, 78, 228),
                        textStyle: const TextStyle(
                          fontFamily: 'Figtree',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  

}
