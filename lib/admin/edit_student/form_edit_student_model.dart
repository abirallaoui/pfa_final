// import 'package:flutter/material.dart';
// import 'form_edit_student.dart';


// class FormFieldController<T> {
//   T? value;

//   FormFieldController(this.value);

//   void updateValue(T newValue) {
//     value = newValue;
//   }
// }


// class FormModelEdit extends FormEditStudentWidget {




//   ///  State fields for stateful widgets in this page.

//   final unfocusNode = FocusNode();
//   final formKey = GlobalKey<FormState>();
//   // State field(s) for fullName widget.
//   FocusNode? nomFocusNode;
//   TextEditingController? nomController;
//   String? Function(String?)? nomControllerValidator;

//   FocusNode? emailFocusNode;
//   TextEditingController? emailController;
//   String? Function(String?)? emailControllerValidator;

//   FormModelEdit({
    
//     String? nom,
//     String? prenom,
//     String? email, required super.id,
//   }) : super() {
//     nomController = TextEditingController(text: nom);
//     prenomController = TextEditingController(text: prenom);
//     emailController = TextEditingController(text: email);
//   }
//   String? _emailControllerValidator(String? val) {
//     if (val == null || val.isEmpty) {
//       return "SVP entrez l'email.";
//     }

//     return null;
//   }

//   FocusNode? passwordFocusNode;
//   TextEditingController? passwordController;
//   String? Function(String?)? passwordControllerValidator;

//    String? _passwordControllerValidator(String? val) {
//     if (val == null || val.isEmpty) {
//       return 'SVP entrez le mot de passe.';
//     }

//     return null;
//   }

//    FocusNode? prenomFocusNode;
//   TextEditingController? prenomController;


//   String? Function(String?)? prenomControllerValidator;
//   String? _prenomControllerValidator(String? val) {
//     if (val == null || val.isEmpty) {
//       return 'SVP entrer le prénom.';
//     }

//     return null;
//   }


//   @override
//   void initState(BuildContext context) {

//   }

//   @override
//   void dispose() {
//     unfocusNode.dispose();
//     unfocusNode.dispose();
//     nomFocusNode?.dispose();
//     nomController?.dispose();

//     emailFocusNode?.dispose();
//     emailController?.dispose();

//     passwordFocusNode?.dispose();
//     passwordController?.dispose();

//     prenomFocusNode?.dispose();
//     prenomController?.dispose();


//   }
// }