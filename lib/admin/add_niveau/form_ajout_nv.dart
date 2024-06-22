import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pfa/admin/DashboardAdmin.dart';
import '../../nodejs/rest_api.dart';
import 'form_ajout_nv_model.dart';
export 'form_ajout_nv_model.dart';



class FormNiveauWidget extends StatefulWidget {
  const FormNiveauWidget({super.key});

  @override
  State<FormNiveauWidget> createState() => _FormNiveauWidgetState();
}

class _FormNiveauWidgetState extends State<FormNiveauWidget> {

  void _AjoutNiveauForm() async {

    final nomNiveau = _model.fullNameController?.text;
    final listEtd =  _model.ListeetudiantsController.text;
    if (nomNiveau == null || nomNiveau.isEmpty || listEtd == null || listEtd.isEmpty) {
      Fluttertoast.showToast(
        msg: "Veuillez remplir tous les champs.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    try {
      final response = await addCardNiveau(nomNiveau!, listEtd);
      // Si tout se passe bien, afficher un toast
      Fluttertoast.showToast(
        msg: "Niveau ajouté avec succès.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );    } catch (e) {
      // En cas d'échec, afficher un message d'erreur
      print("Erreur lors de l'ajout de la carte : $e");
      // Vous pouvez également afficher un toast pour indiquer qu'il y a eu un problème
      Fluttertoast.showToast(
        msg: "msg: 'Erreur lors de l\'ajout du niveau'.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );    }
  }

  late FormModel _model;
  String? selectedOption;
  List<String> options = ['Female', 'Male'];


  final scaffoldKey = GlobalKey<ScaffoldState>();

  FormModel createModel(BuildContext context, FormModel Function() builder) {
    // Implémentez la logique de création de votre modèle ici
    return builder();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormModel());

    _model.fullNameController = TextEditingController();
    _model.fullNameFocusNode = FocusNode();
    _model.fullNameFocusNode!.addListener(() => setState(() {}));

    _model.ListeetudiantsController = TextEditingController();
    _model.ListeetudiantsFocusNode = FocusNode();
    _model.ListeetudiantsFocusNode!.addListener(() => setState(() {}));


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
                  'Ajouter un niveau',
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
              padding:const EdgeInsetsDirectional.fromSTEB(0, 8, 12, 8),
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
                    Route route = MaterialPageRoute(
                        builder: (_) => DashboardAdmin());
                    Navigator.pushReplacement(context, route);

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
                              const EdgeInsetsDirectional.fromSTEB(16, 90, 16, 0),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _model.fullNameController,
                                      focusNode: _model.fullNameFocusNode,
                                      autofocus: true,
                                      textCapitalization:
                                      TextCapitalization.words,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: 'nom du niveau',
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
                                        (_model.fullNameFocusNode?.hasFocus ??
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
                                      cursorColor: const Color.fromARGB(255, 155, 172, 168),
                                      //  validator: _model.fullNameControllerValidator,
                                    ),


                                    Padding(
                                      padding:const EdgeInsetsDirectional.fromSTEB(0, 57, 0, 16),
                                      child:   Container(
                                        width: double.infinity,
                                        child:TextFormField(
                                          controller: _model.ListeetudiantsController,
                                          focusNode: _model.ListeetudiantsFocusNode,
                                          autofocus: true,
                                          textCapitalization:
                                          TextCapitalization.words,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            labelText: 'Liste des étudiants',
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
                                            fillColor: (_model.ListeetudiantsFocusNode
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
                                          //       validator: _model.ListeetudiantsControllerValidator
                                        ),),
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
                    padding:const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 162),
                    child: ElevatedButton(
                      onPressed:
                      _AjoutNiveauForm,

                      // Ajoutez ici le code pour soumettre le formulaire

                      child:   Text('Ajouter le niveau',
                        style: TextStyle(
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