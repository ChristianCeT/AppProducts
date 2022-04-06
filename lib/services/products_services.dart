import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:productos_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl = "flutter-productfh-default-rtdb.firebaseio.com";

  //final para no cambiar la estructura del objeto pero si se puede cambiar los valores internos
  final List<Product> products = [];

  //al final eventualmente se tendrá un producto
  late Product selectedProduct;

  final storage = const FlutterSecureStorage();

  File? newPictureFile;

  bool isLoading = true;
  bool isSaving = false;

  //instancia de productservice
  ProductsService() {
    //cuando se crea la primer instancia llamar al loadproducts
    loadProduct();
  }

  //metodo para llamar los productos <List<Product>
  Future<List<Product>> loadProduct() async {
    //cargando data
    isLoading = true;
    notifyListeners();

    //url y luego el path
    final url = Uri.https(_baseUrl, 'products.json', {
      //parametros
      'auth': await storage.read(key: 'token') ?? ''
    });

    //dispara la petición y la respuesta viene como string
    final resp = await http.get(url);

    //convirtiendo el string a un mapa de products
    //se llama a json.decode para decodificar el json
    final Map<String, dynamic> productsMap = json.decode(resp.body);

    //la key es el primer objeto y los valores es el objeto siguiente
    productsMap.forEach((key, value) {
      //es para poder convertir de un mapa a un listado de productos
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;

      //añadir los productos al listado
      products.add(tempProduct);
    });

    //cambiar la propiedad por que ya se obtuvo la data
    isLoading = false;
    notifyListeners();
    //retornar la lista de productos
    return products;
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();

    if (product.id == null) {
      //Es necesario crear un producto
      await createProduct(product);
    } else {
      //Actualizar
      //Llamar al metodo actualizar
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    //url y luego el path
    final url = Uri.https(_baseUrl, 'products/${product.id}.json',
        {'auth': await storage.read(key: 'token') ?? ''});

    //se retorna el producto en forma de json string
    final resp = await http.put(url, body: product.toJson());

    /* final decodedData = resp.body; */

    //regresa el cuyo id sea igual al del producto que recibo
    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;

    //retornar un string y retorna el product.id por que el id del producto siempre se obtiene
    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    //url y luego el path
    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'token') ?? ''});

    //se retorna el producto en forma de json string
    final resp = await http.post(url, body: product.toJson());

    //convertir con json decode a un mapa
    final decodedData = json.decode(resp.body);

    product.id = decodedData['name'];

    //grabo el producto al array de productos
    products.add(product);

    //retornar un string y retorna el product.id por que el id del producto siempre se obtiene
    return product.id!;
  }

  //el método es grabar la imagen en la portada
  void updateSelectedProductImage(String path) {
    //se asigna el path temporal solo guardado en el celular
    selectedProduct.picture = path;
    //Es para obtener el path del archivo sin subirlo a la base de datos
    newPictureFile = File.fromUri(Uri(path: path));

    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;

    //Estoy guardando
    isSaving = true;
    notifyListeners();

    //Se hace la peticion
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/student-tian/image/upload?upload_preset=upload_image_fh');
    final imageUploadRequest = http.MultipartRequest(
      //primer argumento es el metodo de envio
      'POST',
      //segundo argumento url
      url,
    );

    //Se agrega el archivo
    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);

    //Subir el path o archivo
    imageUploadRequest.files.add(file);

    //respuesta de la petición
    final streamResponse = await imageUploadRequest.send();

    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      return null;
    }

    //limpiar la propiedad
    newPictureFile = null;
    final decodeData = json.decode(response.body);

    //retornar el url
    return decodeData['secure_url'];
  }
}
