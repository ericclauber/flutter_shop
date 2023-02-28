import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:shop/utils/constants.dart';

class OrderList with ChangeNotifier {
  String _token = "";
  String _userId = "";
  List<Order> _items = [];

  OrderList(this._userId, this._token, this._items);

  List<Order> get items {
    return [..._items];
  }

  int itemsCount() {
    return _items.length;
  }

  Future<void> loadOrders() async {
    final List<Order> items = [];

    final response = await http.get(
        Uri.parse("${Constants.ORDER_BASE_URL}/$_userId.json?auth=$_token"));
    if (response.body == "null") return;

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((orderId, orderData) {
      items.add(Order(
        id: orderId,
        total: orderData["total"],
        date: DateTime.parse(orderData["date"]),
        products: (orderData["products"] as List<dynamic>).map((item) {
          return CartItem(
              id: item["id"],
              productId: item["productId"],
              price: item["price"],
              name: item["name"],
              quantity: item["quantity"]);
        }).toList(),
      ));
    });
    /* notifyListeners with FutureBuilder stay loop on order_page, 
    then comment notifyListeners() to fix */
    // notifyListeners();
    _items = items.reversed.toList();
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await http.post(
      Uri.parse("${Constants.ORDER_BASE_URL}/$_userId.json?auth=$_token"),
      body: jsonEncode(
        {
          "total": cart.totalAmount,
          "date": date.toIso8601String(),
          "products": cart.items.values
              .map((cartItem) => {
                    "id": cartItem.id,
                    "productId": cartItem.productId,
                    "name": cartItem.name,
                    "price": cartItem.price,
                    "quantity": cartItem.quantity,
                  })
              .toList()
        },
      ),
    );

    final id = jsonDecode(response.body)["name"];
    _items.insert(
        0,
        Order(
            id: id,
            total: cart.totalAmount,
            products: cart.items.values.toList(),
            date: date));
    notifyListeners();
  }
}
