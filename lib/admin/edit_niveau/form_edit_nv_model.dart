import 'package:flutter/material.dart';
import 'form_edit_nv.dart';


class FormFieldController<T> {
  T? value;

  FormFieldController(this.value);

  void updateValue(T newValue) {
    value = newValue;
  }
}


class FormModelEdit extends FormEditNiveauWidget {




  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  // State field(s) for fullName widget.
  FocusNode? fullNameFocusNode;
  late TextEditingController fullNameController;
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
    fullNameController.dispose();



    ListeetudiantsFocusNode?.dispose();
    ListeetudiantsController.dispose();


  }
}