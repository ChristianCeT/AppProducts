import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyDQLs23wiYw73AGwj2KahJB2JSduXo-4PY';

  final storage = const FlutterSecureStorage();

  //Si se retorna algo es un error, si no, todo bien
  Future<String?> createUser(String email, String password) async {
    //Se envia la peticion a un post como un mapa
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    final url = Uri.https(_baseUrl, '/v1/accounts:signUp', {
      //headers del https or params
      'key': _firebaseToken,
    });

    //encodificas la data en el post con json encode
    final resp = await http.post(url, body: json.encode(authData));

    final Map<String, dynamic> decodedRest = json.decode(resp.body);

    //si tiene el idtoken igual a la respuesta
    if (decodedRest.containsKey('idToken')) {
      //Token hay que guardarlo en el securestorage
      await storage.write(key: 'token', value: decodedRest['idToken']);
      return null;
    } else {
      //un mapa dentro de un mapa
      return decodedRest['error']['message'];
    }
  }

  Future<String?> login(String email, String password) async {
    //Se envia la peticion a un post como un mapa
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    final url = Uri.https(_baseUrl, '/v1/accounts:signInWithPassword', {
      //headers del https or params
      'key': _firebaseToken,
    });

    //encodificas la data en el post con json encode
    final resp = await http.post(url, body: json.encode(authData));

    final Map<String, dynamic> decodedRest = json.decode(resp.body);

    //si tiene el idtoken igual a la respuesta
    if (decodedRest.containsKey('idToken')) {
      //Token hay que guardarlo en el securestorage
      await storage.write(key: 'token', value: decodedRest['idToken']);
      
      print(storage.read(key: 'token'));
      
      return null;
    } else {
      //un mapa dentro de un mapa
      return decodedRest['error']['message'];
    }
  }

  Future logout() async {
    await storage.delete(key: 'token');
    return;
  }

  Future<String> readToken() async {
    //si el token no existe retorna un string vacio
    return await storage.read(key: 'token') ?? '';
  }
}
