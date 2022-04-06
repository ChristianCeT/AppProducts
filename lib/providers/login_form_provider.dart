import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  //Se obtiene la referencia del key del widget
  //Se necesita un state
  //Para formularios FormState, para scafold ScafoldState
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';

  bool _isLoading = false;

  //getter que retorna isloading
  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    //una vez que el valor cambie avisara al widget loginform
    //con el notifylistener se redibujará haciendo los cambios
    _isLoading = value;
    notifyListeners();
  }

  //validacion del formulario
  bool isValidForm() {
    print(formKey.currentState?.validate());

    //regresa true si  no, false
    print('$email - $password');
    return formKey.currentState?.validate() ?? false;
  }
}
