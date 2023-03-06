import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/auth.dart';
import 'package:shop/pages/orders_page.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/utils/custom_route.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text("Bem vindo usuário"),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shop),
            title: const Text("Loja"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.authOrHome);
            },
          ),
          ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Pedidos"),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.orders);
                // Navigator.of(context).pushReplacement(CustomRoute(
                //   builder: (ctx) => OrdersPage(),
                // ));
              }),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Produtos"),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.products);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text("Sair"),
            onTap: () {
              final auth = Provider.of<Auth>(context, listen: false);
              auth.logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.authOrHome);
            },
          )
        ],
      ),
    );
  }
}
