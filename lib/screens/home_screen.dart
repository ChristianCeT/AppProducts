import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';
import 'package:productos_app/screens/screens.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final productD = productService.products;

    //cargar data
    if (productService.isLoading) return const LoadingScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos"),
        leading: IconButton(
          onPressed: () {
            authService.logout();
            Navigator.pushReplacementNamed(context, 'login');
          },
          icon: const Icon(Icons.login_outlined),
        ),
      ),
      //Listview builder es perezoso y se genera solo cuando el widget es necesario
      body: ListView.builder(
        itemCount: productD.length,
        itemBuilder: (BuildContext context, index) => GestureDetector(
            onTap: () {
              //se crea una copia del producto y se rompe la referencia
              //sirve para setear un producto y que no afecte a la variable inicial
              productService.selectedProduct = productD[index].copy();
              Navigator.pushNamed(context, 'product');
            },
            child: ProductCard(product: productD[index])),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          //Inicialización de producto para crear
          productService.selectedProduct = Product(
            available: false,
            name: '',
            price: 0,
          );
          Navigator.pushNamed(context, 'product');
        },
      ),
    );
  }
}
