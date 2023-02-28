import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/app_drawer.dart';
import 'package:shop/components/order_widget.dart';
import 'package:shop/models/order_list.dart';

class OrdersPage extends StatelessWidget {
  // Usando Stateless com FutureBuilder
  @override
  Widget build(BuildContext context) {
    final order = Provider.of<OrderList>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Meus Pedidos"),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future: order.loadOrders(),
          builder: ((ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Consumer<OrderList>(
                builder: ((context, orders, child) => ListView.builder(
                      itemCount: orders.itemsCount(),
                      itemBuilder: (ctx, index) => OrderWidget(
                        order: orders.items[index],
                      ),
                    )),
              );
            }
          }),
        ));
  }
}

  // Usando Statefull com Future

//   @override
//   State<OrdersPage> createState() => _OrdersPageState();
// }

// class _OrdersPageState extends State<OrdersPage> {
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     Provider.of<OrderList>(context, listen: false)
//         .loadOrders()
//         .then((value) => setState(
//               () {
//                 _isLoading = false;
//               },
//             ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     final OrderList orders = Provider.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Meus Pedidos"),
//       ),
//       drawer: const AppDrawer(),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: orders.itemsCount(),
//               itemBuilder: (ctx, index) => OrderWidget(
//                 order: orders.items[index],
//               ),
//             ),
//     );
//   }
//}
