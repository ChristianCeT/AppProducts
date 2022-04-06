import 'dart:convert';

class Product {
  Product({
    required this.available,
    required this.name,
    this.picture,
    required this.price,
    this.id,
  });

  bool available;
  String name;
  String? picture;
  double price;
  //opcional pero cuando sea crea no se tiene un id o puede ser que si, por eso es opcional
  String? id;

  //recibimos un string y generamos una instancia del producto
  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  //sirve para mandar al servidor
  //El http necesita un jsonstring
  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        available: json["available"],
        name: json["name"],
        picture: json["picture"],
        price: json["price"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "available": available,
        "name": name,
        "picture": picture,
        "price": price,
      };

  //Un metodo para copiar los elementos del producto
  Product copy() =>
      Product(available: available, name: name, price: price, id: id, picture: picture);
}
