import 'form_ajout_module.dart' show FormModuleWidget;
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


class FormModuleModel extends FormModuleWidget {




  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  // State field(s) for fullName widget.
  FocusNode? fullNameFocusNode;
  TextEditingController? fullNameController;
  String? Function(String?)? fullNameControllerValidator;

  FormModuleModel({required super.id , required super.nom}) ;

  String? _fullNameControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'SVP entrez le nom du module.';
    }
    return null;
  }

  // State field(s) for age widget.
  FocusNode? salleFocusNode;
  TextEditingController? salleController;
  String? Function(String?)? salleControllerValidator;
  String? _salleControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter an age for the patient.';
    }

    return null;
  }



  String? _ListeetudiantsControllerValidator(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter the date of birth of the patient.';
    }

    return null;
  }



  // State field(s) for DropDown widget.
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  // State field(s) for description widget.
  FocusNode? descriptionFocusNode;
  TextEditingController? descriptionController;
  String? Function(String?)? descriptionControllerValidator;

  @override
  void initState(BuildContext context) {
    fullNameControllerValidator = _fullNameControllerValidator;
    salleControllerValidator = _salleControllerValidator;
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    fullNameFocusNode?.dispose();
    fullNameController?.dispose();

    salleFocusNode?.dispose();
    salleController?.dispose();



    descriptionFocusNode?.dispose();
    descriptionController?.dispose();
  }
}