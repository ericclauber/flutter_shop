import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';
import 'package:shop/provider/counter.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    final Product product =
        ModalRoute.of(context)?.settings.arguments as Product;
    return Scaffold(
      appBar: AppBar(title: Text("Exemplo Contador")),
      body: Column(
        children: [
          Text(CounterProvider.of(context)?.state.value.toString() ?? "0"),
          IconButton(
              onPressed: () {
                setState(() {
                  CounterProvider.of(context)?.state.inc();
                });
                print(
                    CounterProvider.of(context)?.state.value.toString() ?? "0");
              },
              icon: Icon(Icons.add)),
          IconButton(
              onPressed: () {
                setState(() {
                  CounterProvider.of(context)?.state.dec();
                });
                print(
                    CounterProvider.of(context)?.state.value.toString() ?? "0");
              },
              icon: Icon(Icons.remove)),
        ],
      ),
    );
  }
}
