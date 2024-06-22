import 'package:flutter/material.dart';
// import 'package:pfa/nodejs/rest_api.dart';

class FormFieldController<T> {
  T? value;

  FormFieldController(this.value);

  void updateValue(T newValue) {
    value = newValue;
  }
}

class FormStudentModel {
  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  FocusNode? nomFocusNode;
  TextEditingController? nomController;
  String? Function(String?)? nomControllerValidator;

  FocusNode? emailFocusNode;
  TextEditingController? emailController;
  String? Function(String?)? emailControllerValidator;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordController;
  String? Function(String?)? passwordControllerValidator;

  FocusNode? prenomFocusNode;
  TextEditingController? prenomController;
  String? Function(String?)? prenomControllerValidator;

  List<String> niveaux = [];
  String? selectedNiveau;

  void initState() {
    nomControllerValidator = _nomControllerValidator;
    emailControllerValidator = _emailControllerValidator;
    prenomControllerValidator = _prenomControllerValidator;
    // loadNiveaux();
  }

  void dispose() {
    unfocusNode.dispose();
    nomFocusNode?.dispose();
    nomController?.dispose();

    emailFocusNode?.dispose();
    emailController?.dispose();

    passwordFocusNode?.dispose();
    passwordController?.dispose();

    prenomFocusNode?.dispose();
    prenomController?.dispose();
  }

  String? _nomControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'SVP entrez le nom.';
    }
    return null;
  }

  String? _emailControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return "SVP entrez l'email.";
    }
    return null;
  }

  String? _passwordControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'SVP entrez le mot de passe.';
    }
    return null;
  }

  String? _prenomControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'SVP entrer le prénom.';
    }
    return null;
  }

//   Future<void> loadNiveaux() async {
//     try {
//       final niveauxFromDB = await getAllNiveaux();
// // niveaux = niveauxFromDB.map<String>((niveau) => niveau['nom'] ).toList();
//     } catch (e) {
//       print('Erreur lors du chargement des niveaux : $e');
//     }
//   }
}
