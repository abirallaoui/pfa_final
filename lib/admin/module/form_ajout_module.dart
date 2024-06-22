import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../nodejs/utils.dart';
import '../DashboardAdmin.dart';
import 'form_ajout_module_model.dart';
export 'form_ajout_module_model.dart';

class FormModuleWidget extends StatefulWidget {
  late int id;
  late String nom;
  List<String>? _professorsEmails;
  late bool hideModuleScreen = true;

  List<String>? get professorsEmails => _professorsEmails;

  set professorsEmails(List<String>? value) {
    _professorsEmails = value;
  }

  FormModuleWidget({Key? key, required this.id, required this.nom}) : super(key: key);

  @override
  State<FormModuleWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormModuleWidget> {
  late FormModuleModel _model;

  Future<void> insertModule(String nomModule, String emailProf, String salle, String description, int niveauId) async {
    try {
      final response = await http.post(
        Uri.parse('${Utils.baseUrl}/crud/ajoutModule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'nomModule': nomModule,
          'salle': salle,
          'description': description,
          'emailProf': emailProf,
          'niveauId': niveauId
        }),
      );

      if (response.statusCode == 200) {
        // Si l'insertion est réussie, affichez un SnackBar de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Module ajouté avec succès'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // Si l'insertion échoue, affichez un message d'erreur dans le SnackBar
        print("echoue d insertion de module");
      }
    } catch (error) {
      // En cas d'erreur lors de la requête, affichez un message d'erreur dans le SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout du module: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _loadProfessorsEmails() async {
    try {
      final response = await http.get(
        Uri.parse('${Utils.baseUrl}/crud/professors'), // Remplacez par l'URL de votre API pour récupérer les adresses e-mail des professeurs
      );
      if (response.statusCode == 200) {
        final List<dynamic> professorsData = json.decode(response.body);
        setState(() {
          _model.professorsEmails = professorsData.map<String>((professor) => professor['email']).toList();
        });
      } else {
        throw Exception('Failed to load professors emails');
      }
    } catch (error) {
      print('Error loading professors emails: $error');
    }
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  FormModuleModel createModel(BuildContext context, FormModuleModel Function() builder) {
    // Implémentez la logique de création de votre modèle ici
    return builder();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormModuleModel(id: widget.id, nom: widget.nom));

    _model.fullNameController ??= TextEditingController();
    _model.fullNameFocusNode ??= FocusNode();
    _model.fullNameFocusNode!.addListener(() => setState(() {}));
    _model.salleController ??= TextEditingController();
    _model.salleFocusNode ??= FocusNode();
    _model.salleFocusNode!.addListener(() => setState(() {}));

    _model.descriptionController ??= TextEditingController();
    _model.descriptionFocusNode ??= FocusNode();
    _model.descriptionFocusNode!.addListener(() => setState(() {}));

    _loadProfessorsEmails();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  String? validateProfessor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez choisir un professeur';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus ? FocusScope.of(context).requestFocus(_model.unfocusNode) : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter un module Au Niveau ${widget.nom}',
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
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: Color(0xFF606A85),
                  fontSize: 14,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 12, 8),
              child: Ink(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Route route = MaterialPageRoute(builder: (_) => DashboardAdmin());
                    Navigator.pushReplacement(context, route);
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF15161E),
                    size: 24,
                  ),
                  iconSize: 40,
                  color: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 40, height: 40),
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
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled, // Désactiver la validation automatique
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
                          alignment: AlignmentDirectional(0, -1),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: 770,
                            ),
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(16, 36, 16, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextFormField(
                                    controller: _model.fullNameController,
                                    focusNode: _model.fullNameFocusNode,
                                    autofocus: true,
                                    textCapitalization: TextCapitalization.words,
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText: 'nom du module*',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF606A85),
                                        fontSize: 16,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintStyle: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF606A85),
                                        fontSize: 14,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      errorStyle: TextStyle(
                                        fontFamily: 'Figtree',
                                        color: Color(0xFFFF5963),
                                        fontSize: 12,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color.fromARGB(255, 59, 59, 206),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: (_model.fullNameFocusNode?.hasFocus ?? false)
                                          ? Color(0x4D9489F5)
                                          : Colors.white,
                                      contentPadding: EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF15161E),
                                      fontSize: 16,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    cursorColor: Color.fromARGB(255, 155, 172, 168),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Veuillez entrer le nom du module';
                                      }
                                      return null;
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0, 8, 40, 28),
                                  ),
                                  Text(
                                    'Compte Professeur*',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      color: Color(0xFF606A85),
                                      fontSize: 14,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  DropdownButtonFormField<String>(
                                    value: _model.dropDownValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _model.dropDownValue = newValue;
                                      });
                                    },
                                    items: _model.professorsEmails?.map<DropdownMenuItem<String>>((String email) {
                                      return DropdownMenuItem<String>(
                                        value: email,
                                        child: Text(email),
                                      );
                                    }).toList() ?? [],
                                    decoration: InputDecoration(
                                      hintText: 'Veuillez choisir ...',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Outfit',
                                        color: Color(0xFF606A85),
                                        fontSize: 14,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      errorStyle: TextStyle(
                                        fontFamily: 'Figtree',
                                        color: Color(0xFFFF5963),
                                        fontSize: 12,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Color(0xFF6F61EF),
                                          width: 2,
                                        ),
                                      ),
                                      suffixIcon: Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF606A85),
                                        size: 24,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      color: Color(0xFF15161E),
                                      fontSize: 16,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    elevation: 2,
                                    iconEnabledColor: Color(0xFF606A85),
                                    validator: validateProfessor,
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0, 53, 0, 16),
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                          controller: _model.salleController,
                                          focusNode: _model.salleFocusNode,
                                          autofocus: true,
                                          textCapitalization: TextCapitalization.words,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Salle*',
                                            labelStyle: TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Color(0xFF606A85),
                                              fontSize: 16,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            hintStyle: TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Color(0xFF606A85),
                                              fontSize: 14,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            errorStyle: TextStyle(
                                              fontFamily: 'Figtree',
                                              color: Color(0xFFFF5963),
                                              fontSize: 12,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFF6F61EF),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFFFF5963),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFFFF5963),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: (_model.salleFocusNode?.hasFocus ?? false)
                                                ? Color(0x4D9489F5)
                                                : Colors.white,
                                            contentPadding: EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Figtree',
                                            color: Color(0xFF15161E),
                                            fontSize: 16,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          cursorColor: Color(0xFF6F61EF),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Veuillez entrer le nom de la salle';
                                            }
                                            return null;
                                          }),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0, 35, 0, 16),
                                    child: Container(
                                      width: double.infinity,
                                      child: TextFormField(
                                          controller: _model.descriptionController,
                                          focusNode: _model.descriptionFocusNode,
                                          autofocus: true,
                                          textCapitalization: TextCapitalization.words,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Description...',
                                            labelStyle: TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Color(0xFF606A85),
                                              fontSize: 16,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            hintStyle: TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Color(0xFF606A85),
                                              fontSize: 14,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Color(0xFF6F61EF),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding: EdgeInsetsDirectional.fromSTEB(16, 20, 16, 20),
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Figtree',
                                            color: Color(0xFF15161E),
                                            fontSize: 16,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          cursorColor: Color(0xFF6F61EF)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(0, 35, 0, 16),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_formKey.currentState!.validate()) {
                                              insertModule(
                                                _model.fullNameController!.text.trim(),
                                                _model.dropDownValue!,
                                                _model.salleController!.text.trim(),
                                                _model.descriptionController!.text.trim(),
                                                widget.id,
                                              ).then((_) {
                                                // Vider tous les champs après l'ajout réussi du module
                                                _model.fullNameController!.clear();
                                                _model.salleController!.clear();
                                                _model.descriptionController!.clear();
                                                setState(() {
                                                  _model.dropDownValue = null;
                                                });

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Module ajouté avec succès'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              }).catchError((error) {
                                                print("Erreur lors de l'ajout d'un module: $error");
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) => DashboardAdmin()
                                                    ));
                                              });
                                            }
                                          },
                                          child: Text(
                                            'Ajouter Module ',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Colors.white,
                                              fontSize: 16,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF6F61EF)),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                side: BorderSide(color: Color(0xFF6F61EF)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
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
    );
  }
}