import 'package:flutter/material.dart';
import 'package:productos_app/screens/screens.dart';
import 'package:productos_app/services/services.dart';
import 'package:provider/provider.dart';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //No se necesita redibujar el widget
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: authService.readToken(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            if (snapshot.data == '') {
              Future.microtask(() {
                //Forma de entrar a otra pantalla rapidaemnte sin que se vea la pantalla intermedia
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: ((_, __, ___) => const LoginScreen()),
                    transitionDuration: const Duration(seconds: 0),
                  ),
                );
              });
            } else {
              Future.microtask(() {
                //Forma de entrar a otra pantalla rapidaemnte sin que se vea la pantalla intermedia
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: ((_, __, ___) => const HomeScreen()),
                    transitionDuration: const Duration(seconds: 0),
                  ),
                );
              });
            }

            return Container();
          },
        ),
      ),
    );
  }
}
