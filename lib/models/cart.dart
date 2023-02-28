import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product.dart';

class Cart extends ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
          product.id,
          (existintProduct) => CartItem(
              id: existintProduct.id,
              productId: existintProduct.productId,
              name: existintProduct.name,
              quantity: existintProduct.quantity + 1,
              price: existintProduct.price));
    } else {
      _items.putIfAbsent(
          product.id,
          () => CartItem(
              id: Random().nextDouble().toString(),
              productId: product.id,
              name: product.name,
              quantity: 1,
              price: product.price));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]?.quantity == 1) {
      removeItem(productId);
    } else {
      _items.update(
          productId,
          (existintProduct) => CartItem(
              id: existintProduct.id,
              productId: existintProduct.productId,
              name: existintProduct.name,
              quantity: existintProduct.quantity - 1,
              price: existintProduct.price));
      ;
    }
    notifyListeners();
  }

  void clear() {
    //_items = {};
    _items.clear();
    notifyListeners();
  }
}
