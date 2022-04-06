import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';

class ProductFormProvider extends ChangeNotifier {
  //Validación para el formulario de productos
  //Referencia de la key del formulario
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Product product;

  //Debe ser una copia y cuando se crea la instancia, esto pide un producto por defecto.
  ProductFormProvider(this.product);

  //Metodo
  updateAvailableAbility(bool value) {
    //Cambiar el valor de la disponibilidad
    product.available = value;
    notifyListeners();
  }

  bool isValidForm() {
    print(product.name);
    print(product.price);
    print(product.available);
    print(product.picture);

    //true si es valido el formulario y false si es falso
    return formKey.currentState?.validate() ?? false;
  }
}
