import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exception/http_exception.dart';
import 'package:shop/models/product_list.dart';

import '../models/product.dart';
import '../utils/app_routes.dart';

class ProductsItem extends StatelessWidget {
  final Product product;
  const ProductsItem({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final msg = ScaffoldMessenger.of(context);
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(product.imageUrl)),
      title: Text(product.name),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(AppRoutes.productForm, arguments: product);
              },
              icon: const Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: () {
                showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: Text("Excluir produto"),
                          content: Text("Tem certeza?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text("Não"),
                            ),
                            TextButton(
                              onPressed: () =>
                                  // Provider.of<ProductList>(context, listen: false)
                                  //     .removeProduct(product);
                                  Navigator.of(ctx).pop(true),
                              child: Text("Sim"),
                            )
                          ],
                        )).then((value) async {
                  if (value ?? false) {
                    try {
                      await Provider.of<ProductList>(context, listen: false)
                          .removeProduct(product);
                    } on HttpException catch (error) {
                      msg.showSnackBar(SnackBar(content: Text(error.msg)));
                    }
                  }
                });
              },
              icon: const Icon(Icons.delete),
              color: Theme.of(context).colorScheme.error,
            )
          ],
        ),
      ),
    );
  }
}
