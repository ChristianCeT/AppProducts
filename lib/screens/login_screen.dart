import 'package:flutter/material.dart';
import 'package:productos_app/providers/login_form_provider.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/ui/input_decoration.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AuthBackground(
        //permite hacer scroll si sus hijos pasan el tamaño del dispositivos
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.height * 0.24,
              ),
              CardContainer(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Login",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(
                      height: 30,
                    ),

                    //Changenotifie provider es solo cuando hay un provider
                    //Solo va a estar renderizado o vive en el loginform el provider
                    ChangeNotifierProvider(
                      create: (_) => LoginFormProvider(),
                      child: const _LoginForm(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, 'register');
                },
                child: const Text(
                  'Crear una nueva cuenta',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
                style: ButtonStyle(
                  overlayColor:
                      MaterialStateProperty.all(Colors.indigo.withOpacity(0.1)),
                  shape: MaterialStateProperty.all(
                    const StadiumBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //acceso a toda la clase provider
    final loginForm = Provider.of<LoginFormProvider>(context);

    return Container(
      child: Form(
          //key asociado al provider
          key: loginForm.formKey,
          child: Column(
            children: [
              TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecorations.authInputDecoration(
                    hintText: 'jhon.doe@hotmail.com',
                    labelText: 'Correo electrónico',
                    prefixIcon: Icons.alternate_email_rounded),
                //validator sirve para validar el formulario
                validator: (value) {
                  String pattern =
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regExp = RegExp(pattern);
                  //validar un nulo o un string
                  return regExp.hasMatch(value ?? '')
                      ? null
                      : 'El valor ingresado no luce como un correo';
                },
                //Como no necesito redibujar algo en otro widget, puedo setear el valor asi
                onChanged: (value) => loginForm.email = value,

                //autovalidatemode sirve para validar segun la interaccion del usuario
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 30),
              TextFormField(
                autocorrect: false,
                obscureText: true,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecorations.authInputDecoration(
                    hintText: '******',
                    labelText: 'Contraseña',
                    prefixIcon: Icons.lock_outline),
                validator: (value) {
                  //validar contraseña
                  return (value != null && value.length >= 6)
                      ? null
                      : 'La contraseña debe ser de 6 caracteres';
                }, //Como no necesito redibujar algo en otro widget, puedo setear el valor asi
                onChanged: (value) => loginForm.password = value,

                //autovalidatemode sirve para validar segun la interaccion del usuario
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 30),
              MaterialButton(
                onPressed: loginForm.isLoading
                    ? null
                    : () async {
                        //quitar teclado
                        FocusScope.of(context).unfocus();

                        //No se puede escuchar dentro de un metodo, solo se puede escuchar dentro del build
                        final authService =
                            Provider.of<AuthService>(context, listen: false);

                        //validar si esto es falso
                        if (!loginForm.isValidForm()) return;

                        //seteo el valor para que el boton cambie
                        loginForm.isLoading = true;

                        final String? errorMessage = await authService
                            .login(loginForm.email, loginForm.password);

                        if (errorMessage == null) {
                          //pushreplacementNamed destruye todas las pantallas y va a la siguiente
                          Navigator.pushReplacementNamed(context, 'home');
                        } else {
                          //MOSTRAR ERROR DE PANTALLA
                          NotificationsService.showSnackBar(errorMessage);
                          loginForm.isLoading = false;
                        }
                      },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                disabledColor: Colors.grey,
                elevation: 0,
                color: Colors.deepPurple,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  child: Text(
                    loginForm.isLoading ? 'Espere' : 'Ingresar',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
