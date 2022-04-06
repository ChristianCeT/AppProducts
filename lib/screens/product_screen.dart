import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:productos_app/providers/product_form_provider.dart';
import 'package:productos_app/services/services.dart';
import 'package:productos_app/ui/input_decoration.dart';
import 'package:productos_app/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductsService>(context);

    return ChangeNotifierProvider(
      //instancia del productoformprovider
      create: (_) => ProductFormProvider(productService.selectedProduct),
      child: _ProductScreenBody(productService: productService),
    );
  }
}

class _ProductScreenBody extends StatelessWidget {
  const _ProductScreenBody({
    Key? key,
    required this.productService,
  }) : super(key: key);

  final ProductsService productService;

  @override
  Widget build(BuildContext context) {
    final productForm = Provider.of<ProductFormProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        //al hacer scroll se oculta el teclado
        //keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Stack(
              children: [
                ProductImage(
                  url: productService.selectedProduct.picture,
                ),
                Positioned(
                  top: 60,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    //Navigator sirve para salir de la pantalla sin la ruta
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                    //Navigator sirve para salir de la pantalla sin la ruta
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(
                        /* source: ImageSource.gallery si es iphone */
                        source: ImageSource.gallery,
                        imageQuality: 100,
                      );

                      if (pickedFile == null) {
                        // ignore: avoid_print
                        print("No seleccionó nada");
                        return;
                      }
                      //Se obtiene el path fisico dentro del dispositivo

                      // ignore: avoid_print
                      print("Tenemos imagen ${pickedFile.path}");
                      productService
                          .updateSelectedProductImage(pickedFile.path);
                    },
                  ),
                ),
              ],
            ),
            const _ProductForm(),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
          child: productService.isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Icon(Icons.save_outlined),
          //retorna true que no retorne nada y se deshabilite el boton
          onPressed: productService.isSaving
              ? null
              : () async {
                  //validar formulario
                  if (!productForm.isValidForm()) return;

                  //Carga de la imagen del producto
                  final String? imageUrl = await productService.uploadImage();

                  if (imageUrl != null) productForm.product.picture = imageUrl;

                  //llamar instancia con los datos del formulario
                  await productService.saveOrCreateProduct(productForm.product);
                }),
    );
  }
}

class _ProductForm extends StatelessWidget {
  const _ProductForm({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //información del producto que selecciona
    final productForm = Provider.of<ProductFormProvider>(context);

    final product = productForm.product;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        decoration: _buildBoxDecoration(),
        child: Form(
            key: productForm.formKey,
            //validar segun interaccion del usuario
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: product.name,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: 'Nombre del producto',
                    labelText: 'Nombre:',
                  ),
                  //cambiar el valor del value
                  onChanged: (value) => product.name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nombre obligatorio";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                TextFormField(
                  initialValue: '${product.price}',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^(\d+)?\.?\d{0,2}'))
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecorations.authInputDecoration(
                    hintText: 'S/150',
                    labelText: 'Precio:',
                  ),
                  //cambiar el valor del value
                  onChanged: (value) => {
                    //parsear el valor
                    if (double.tryParse(value) == null)
                      {product.price = 0}
                    else
                      {product.price = double.parse(value)}
                  },
                ),
                const SizedBox(height: 30),
                SwitchListTile.adaptive(
                    value: product.available,
                    title: const Text("Disponible"),
                    activeColor: Colors.indigo,
                    onChanged: (value) {
                      productForm.updateAvailableAbility(value);
                    }),
                const SizedBox(height: 30),
              ],
            )),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 5),
                blurRadius: 5)
          ]);
}
