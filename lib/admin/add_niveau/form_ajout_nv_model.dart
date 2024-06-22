import 'package:pfa/admin/add_niveau/form_ajout_nv.dart' show FormNiveauWidget;
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';


class FormFieldController<T> {
  T? value;

  FormFieldController(this.value);

  void updateValue(T newValue) {
    value = newValue;
  }
}


class FormModel extends FormNiveauWidget {




  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  // State field(s) for fullName widget.
  FocusNode? fullNameFocusNode;
  TextEditingController? fullNameController;
  // String? Function(String?)? fullNameControllerValidator;

  /*String? _fullNameControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'SVP entrez le nom du niveau.';
    }
    return null;
  }*/



  // State field(s) for phoneNumber widget.
  FocusNode? ListeetudiantsFocusNode;
  late TextEditingController ListeetudiantsController;
  //late String? Function(String?)? ListeetudiantsControllerValidator;

  /* String? _ListeetudiantsControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter the list of the students.';
    }

    return null;
  }*/





  @override
  void initState(BuildContext context) {
    //fullNameControllerValidator = _fullNameControllerValidator;

  }

  @override
  void dispose() {
    unfocusNode.dispose();
    fullNameFocusNode?.dispose();
    fullNameController?.dispose();



    ListeetudiantsFocusNode?.dispose();
    ListeetudiantsController?.dispose();


  }
}