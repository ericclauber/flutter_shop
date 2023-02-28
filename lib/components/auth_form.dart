import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exception/auth_exception.dart';
import 'package:shop/models/auth.dart';

enum AuthMode { Sigup, Login }

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<StatefulWidget> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {"email": "", "password": ""};

  AnimationController? _controller;
  Animation<Size>? _heightAnimation;

  bool _isLogin() => _authMode == AuthMode.Login;
  bool _isSigup() => _authMode == AuthMode.Sigup;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = Tween(
            begin: Size(double.infinity, 350), end: Size(double.infinity, 400))
        .animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.linear,
      ),
    );
    _heightAnimation?.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller?.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _controller?.forward();
        _authMode = AuthMode.Sigup;
      } else {
        _authMode = AuthMode.Login;
        _controller?.reverse();
      }
    });
  }

  void _showErroDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ocorreu um erro"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fechar"))
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValidForm = _formKey.currentState?.validate() ?? false;

    if (!isValidForm) return;
    setState(() => _isLoading = true);

    _formKey.currentState?.save();

    Auth auth = Provider.of<Auth>(context, listen: false);

    try {
      if (_isLogin()) {
        await auth.login(_authData["email"]!, _authData["password"]!);
      } else {
        await auth.signUp(_authData["email"]!, _authData["password"]!);
      }
    } on AuthException catch (error) {
      _showErroDialog(error.toString());
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
          padding: const EdgeInsets.all(16),
          height: _heightAnimation?.value.height ?? (_isLogin() ? 350 : 400),
          width: deviceSize.width * 0.75,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "E-mail",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (email) => _authData["email"] = email ?? "",
                  validator: (_email) {
                    final email = _email ?? "";
                    if (email.trim().isEmpty || !email.contains("@")) {
                      return "Informe um e-mail válido.";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Senha",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  onSaved: (password) => _authData["password"] = password ?? "",
                  validator: (_password) {
                    final password = _password ?? "";
                    if (password.isEmpty || password.length < 5) {
                      return "Informe uma senha válida";
                    }
                    return null;
                  },
                ),
                if (_isSigup())
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Confirmar Senha",
                    ),
                    controller: _passwordController,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: true,
                    validator: _isLogin()
                        ? null
                        : (_password) {
                            final password = _password ?? "";
                            if (password != _passwordController.text) {
                              return "Senhas informadas não conferem.";
                            }
                            return null;
                          },
                  ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 8)),
                    child: Text(
                        _authMode == AuthMode.Login ? "ENTRAR" : "REGISTRAR"),
                  ),
                Spacer(),
                TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      _isLogin() ? "DESEJA REGISTRAR?" : "JÁ POSSUI CONTA?",
                    ))
              ],
            ),
          )),
    );
  }
}
