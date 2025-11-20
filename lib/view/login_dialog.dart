import 'package:flutter/material.dart';
import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/view/create_account_page.dart';
import 'package:flashcard_app/model/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class LoginDialog extends StatefulWidget {
  final User user;

  const LoginDialog({super.key, required this.user});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  StreamSubscription? _authSubscription;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _authSubscription?.cancel();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authBloc = BlocProvider.of<AuthBloc>(context);
      bool loginSuccess = false;

      final completer = Completer<bool>();

      _authSubscription = authBloc.stream.listen((authState) {
        if (authState is AuthError) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        } else if (authState is Authenticated) {
          loginSuccess = true;
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        }
      });

      authBloc.add(
        LoginUser(
          username: emailController.text.trim(),
          password: passwordController.text.trim(),
        ),
      );

      final result = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      await _authSubscription?.cancel();
      _authSubscription = null;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (!result) {
          setState(() {
            _errorMessage =
                'Credenciais inválidas. Verifique seu email e senha.';
          });
          return;
        }

        if (loginSuccess) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: const Text(
        "Login Necessário",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              "Para criar uma coleção, você precisa fazer o login.",
              style: TextStyle(fontSize: 12),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 15),
            SizedBox(
              height: 30,
              child: TextFormField(
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 11),
                controller: emailController,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: 11),
                  floatingLabelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  errorStyle: TextStyle(fontSize: 0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return " ";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 30,
              child: TextFormField(
                cursorColor: Colors.black,
                style: TextStyle(fontSize: 11),
                controller: passwordController,
                onChanged: (_) {
                  if (_errorMessage != null) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(fontSize: 11),
                  floatingLabelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  errorStyle: TextStyle(fontSize: 0),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return " ";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text(
                    "CANCELAR",
                    style: TextStyle(color: Colors.black, fontSize: 10),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateAccountPage(user: widget.user),
                      ),
                    );

                    setState(() {});

                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Criar conta",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                        ),
                      )
                    : const Text(
                        "ENTRAR",
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                onPressed: _isLoading ? null : _handleLogin,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
