import 'package:flutter/material.dart';

class NotificationsService {
  //Sirve para mantener la referencia de un widget de el materialapp
  static GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static showSnackBar(String message) {
    final snackBar = SnackBar(
        content: Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
    ));

    //llamar al snackbar
    messengerKey.currentState!.showSnackBar(snackBar);
  }
}
