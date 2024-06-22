import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pfa/nodejs/rest_api_prof.dart';
import 'package:pfa/admin/models/professor.dart';

class EditProfForm extends StatefulWidget {
  final int professorId;

  const EditProfForm({Key? key, required this.professorId}) : super(key: key);

  @override
  _EditProfFormState createState() => _EditProfFormState();
}

class _EditProfFormState extends State<EditProfForm> {
  final _formKey = GlobalKey<FormState>();
  late Future<Professor> _professorFuture;
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late FocusNode _nomFocusNode;
  late FocusNode _prenomFocusNode;
  late FocusNode _emailFocusNode;

  @override
  void initState() {
    super.initState();
    _professorFuture = RestApi.fetchProfessor(widget.professorId);
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _nomFocusNode = FocusNode();
    _prenomFocusNode = FocusNode();
    _emailFocusNode = FocusNode();

  }
  @override
  void dispose() {
    _nomFocusNode.dispose();
    _prenomFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Modifier un professeur',
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
                  Navigator.of(context).pop();
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
        child: FutureBuilder(
          future: _professorFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur : ${snapshot.error}'));
            } else {
              Professor professor = snapshot.data as Professor;
              _nomController.text = professor.nom;
              _prenomController.text = professor.prenom;
              _emailController.text = professor.email;

              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
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
                                alignment: Alignment.topCenter,
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxWidth: 770,
                                  ),
                                  decoration: BoxDecoration(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 90, 16, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          controller: _nomController,
                                          focusNode: _nomFocusNode,
                                          autofocus: true,
                                          textCapitalization: TextCapitalization.words,
                                          decoration: InputDecoration(
                                            labelText: 'Nom du professeur',
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
                                            fillColor: _nomController.text.isEmpty && !_nomFocusNode.hasFocus ? Color(0x4D9489F5) : Colors.white,

                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 16,
                                            ),
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
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer un nom';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _prenomController,
                                          focusNode: _prenomFocusNode,
                                          textCapitalization: TextCapitalization.words,
                                          decoration: InputDecoration(
                                            labelText: 'Prénom du professeur',
                                            labelStyle: TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Color(0xFF606A85),
                                              fontSize: 16,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            alignLabelWithHint: true,
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
                                            fillColor: (_prenomFocusNode?.hasFocus ??
                                                false)
                                                ? const Color(0x4D9489F5)
                                                : Colors.white,

                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 16,
                                            ),
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
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer un prénom';
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 20),
                                        TextFormField(
                                          controller: _emailController,
                                          focusNode: _emailFocusNode,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: 'Email du professeur',
                                            labelStyle: TextStyle(
                                              fontFamily: 'Outfit',
                                              color: Color(0xFF606A85),
                                              fontSize: 16,
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            alignLabelWithHint: true,
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
                                            fillColor: (_emailFocusNode.hasFocus ??
                                                false)
                                                ? const Color(0x4D9489F5)
                                                : Colors.white,

                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 16,
                                            ),
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
                                            if (value == null || value.isEmpty) {
                                              return 'Veuillez entrer un email';
                                            }

                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: 770,
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 12, 16, 162),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                RestApi.updateProfessor(
                                  widget.professorId,
                                  _nomController.text,
                                  _prenomController.text,
                                  _emailController.text,
                                  professor.password,
                                ).then((_) {
                                  Fluttertoast.showToast(
                                    msg: "Le professeur a été modifié avec succès",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.green,
                                    textColor: Colors.white,
                                    fontSize: 16.0,
                                  );
                                  Navigator.pop(context);
                                });
                              }
                            },
                            child: Text(
                              'Modifier le professeur',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 48),
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              backgroundColor: Color.fromARGB(255, 78, 78, 228),
                              textStyle: TextStyle(
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
              );
            }
          },
        ),
      ),
    );
  }
}