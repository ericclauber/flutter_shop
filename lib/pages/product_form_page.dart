import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/product.dart';
import 'package:shop/models/product_list.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProductFormPageState();
  }
}

class _ProductFormPageState extends State<ProductFormPage> {
  final priceNode = FocusNode();
  final descriptionFocus = FocusNode();
  final urlImageFocus = FocusNode();
  final imageUrlControler = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    urlImageFocus.addListener(updateImage);
  }

  @override
  void dispose() {
    super.dispose();
    priceNode.dispose();
    descriptionFocus.dispose();
    urlImageFocus.dispose();
    urlImageFocus.removeListener(updateImage);
  }

  void updateImage() {
    setState(() {});
  }

  bool isValidImageUrl(String url) {
    bool isValidUrl = Uri.tryParse(url)?.hasAbsolutePath ?? false;

    bool endsWithFile = url.toLowerCase().endsWith(".pnd") ||
        url.toLowerCase().endsWith(".jpg") ||
        url.toLowerCase().endsWith(".jped");

    return isValidUrl && endsWithFile;
  }

  void submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();

    // final newProduct = Product(
    //     id: Random().nextDouble().toString(),
    //     name: _formData["name"] as String,
    //     description: _formData["description"] as String,
    //     price: _formData["price"] as double,
    //     imageUrl: _formData["urlImage"] as String);

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<ProductList>(
        context,
        listen: false,
      ).saveProduct(_formData);

      Navigator.of(context).pop();
    } catch (error) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Ocorreu um erro."),
          content: const Text("Ocorreu um erro ao salvar o produto"),
          actions: [
            TextButton(
                onPressed: (() {
                  //setState(() => _isLoading = false);
                  Navigator.of(context).pop();
                }),
                child: const Text("Ok"))
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Assíncrono sem async / await
  // void submitForm() {
  //   final isValid = _formKey.currentState?.validate() ?? false;
  //   if (!isValid) {
  //     return;
  //   }
  //   _formKey.currentState?.save();

  //   // final newProduct = Product(
  //   //     id: Random().nextDouble().toString(),
  //   //     name: _formData["name"] as String,
  //   //     description: _formData["description"] as String,
  //   //     price: _formData["price"] as double,
  //   //     imageUrl: _formData["urlImage"] as String);

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   Provider.of<ProductList>(
  //     context,
  //     listen: false,
  //   ).saveProduct(_formData).catchError((error) {
  //     return showDialog<void>(
  //       context: context,
  //       builder: (ctx) => AlertDialog(
  //         title: const Text("Ocorreu um erro."),
  //         content: const Text("Ocorreu um erro ao salvar o produto"),
  //         actions: [
  //           TextButton(
  //               onPressed: (() {
  //                 //setState(() => _isLoading = false);
  //                 Navigator.of(context).pop();
  //               }),
  //               child: const Text("Ok"))
  //         ],
  //       ),
  //     );
  //   }).then((value) {
  //     setState(() => _isLoading = false);
  //     Navigator.of(context).pop();
  //   });
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args != null) {
        final product = args as Product;
        _formData["id"] = product.id;
        _formData["name"] = product.name;
        _formData["price"] = product.price;
        _formData["description"] = product.description;
        _formData["urlImage"] = product.imageUrl;

        imageUrlControler.text = product.imageUrl;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formulário do Produto"),
        actions: [
          IconButton(onPressed: (() => submitForm()), icon: Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _formData["name"].toString(),
                        decoration: const InputDecoration(labelText: "Nome"),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(priceNode);
                        },
                        onSaved: (name) => _formData["name"] = name ?? "",
                        validator: (_name) {
                          final name = _name ?? "";

                          if (name.isEmpty) {
                            return "Nome é obrigatório";
                          }
                          if (name.trim().length < 3) {
                            return "Nome precisa no mínimo de 3 letras";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                          initialValue: _formData["price"]?.toString(),
                          decoration: const InputDecoration(labelText: "Preço"),
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(descriptionFocus);
                          },
                          focusNode: priceNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onSaved: (price) =>
                              _formData["price"] = double.parse(price ?? "0"),
                          validator: (_price) {
                            final priceString = _price ?? "";
                            final price = double.tryParse(priceString) ?? -1;

                            if (price <= 0) {
                              return "Informe um preço válido";
                            }

                            return null;
                          }),
                      TextFormField(
                          initialValue: _formData["description"]?.toString(),
                          decoration:
                              const InputDecoration(labelText: "Descrição"),
                          focusNode: descriptionFocus,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          onSaved: (description) =>
                              _formData["description"] = description ?? "",
                          validator: (_description) {
                            final description = _description ?? "";

                            if (description.isEmpty) {
                              return "Decrição é obrigatória";
                            }
                            if (description.trim().length < 10) {
                              return "Decrição precisa no mínimo de 10 letras";
                            }
                            return null;
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  labelText: "Url da Imagem"),
                              focusNode: urlImageFocus,
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: imageUrlControler,
                              onFieldSubmitted: (value) => submitForm(),
                              onSaved: (urlImage) =>
                                  _formData["urlImage"] = urlImage ?? "",
                              validator: (_urlImage) {
                                final urlImage = _urlImage ?? "";
                                if (!isValidImageUrl(urlImage)) {
                                  return "Informe uma Url Válida";
                                }
                              },
                            ),
                          ),
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 10, left: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 1)),
                            alignment: Alignment.center,
                            child: imageUrlControler.text.isEmpty
                                ? const Text("Informe a url")
                                : FittedBox(
                                    fit: BoxFit.cover,
                                    child:
                                        Image.network(imageUrlControler.text),
                                  ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
