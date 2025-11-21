import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/bloc/user_bloc.dart';
import 'package:flashcard_app/model/user.dart';
import 'package:flashcard_app/provider/firestore_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class CreateAccountPage extends StatefulWidget {
  final User user;

  const CreateAccountPage({super.key, required this.user});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final Color primaryColor = Colors.black;
  final Color secondaryColor = Colors.white;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String? _selectedImagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      widget.user.name = _nameController.text.trim();
      widget.user.email = _emailController.text.trim();
      widget.user.age = int.tryParse(_ageController.text) ?? 0;
      widget.user.profilePicturePath = _selectedImagePath;

      try {
        final authBloc = BlocProvider.of<AuthBloc>(context);
        bool registrationSuccess = false;
        String? errorMessage;

        // Guarda o estado inicial para ignorar estados antigos
        final initialState = authBloc.state;
        bool registrationStarted = false;

        StreamSubscription? subscription;
        final completer = Completer<bool>();

        subscription = authBloc.stream.listen((authState) {
          if (!registrationStarted) {
            if (authState == initialState) {
              return;
            }
            return;
          }

          if (authState is AuthError) {
            final errorMsg = authState.message.toLowerCase();

            if (errorMsg.contains('email-already-in-use') ||
                errorMsg.contains('email já está em uso')) {
              errorMessage = 'Este email já está em uso';
            } else if (errorMsg.contains('invalid-email') ||
                errorMsg.contains('invalid_email') ||
                errorMsg.contains('email inválido') ||
                errorMsg.contains('invalid email')) {
              errorMessage = 'Email inválido';
            } else if (errorMsg.contains('weak-password') ||
                errorMsg.contains('senha muito fraca')) {
              errorMessage = 'Senha muito fraca';
            } else if (errorMsg.contains('network') ||
                errorMsg.contains('rede')) {
              errorMessage = 'Erro de conexão. Verifique sua internet.';
            } else {
              errorMessage = 'Erro ao criar conta. Tente novamente.';
            }

            if (!completer.isCompleted) {
              completer.complete(false);
            }
          } else if (authState is Authenticated) {
            if (authState.username == widget.user.email) {
              registrationSuccess = true;
              if (!completer.isCompleted) {
                completer.complete(true);
              }
            }
          }
        });

        registrationStarted = true;

        authBloc.add(
          RegisterUser(
            username: widget.user.email,
            password: _passwordController.text.trim(),
          ),
        );

        final result = await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            final currentState = authBloc.state;
            if (currentState is Authenticated &&
                currentState.username == widget.user.email) {
              registrationSuccess = true;
              return true;
            }
            return false;
          },
        );

        await subscription.cancel();

        if (!result || errorMessage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  errorMessage ?? 'Erro ao criar conta. Tente novamente.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (!registrationSuccess) {
          final currentState = authBloc.state;
          if (currentState is Authenticated &&
              currentState.username == widget.user.email) {
            registrationSuccess = true;
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erro ao criar conta. Tente novamente.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            return;
          }
        }

        await FirestoreUserProvider.helper.insertUser(widget.user);

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          final authState = authBloc.state;
          if (authState is Authenticated) {
            context.read<UserBloc>().add(LoadUser(email: authState.username));
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          String errorMsg = 'Erro ao criar conta';
          final errorString = e.toString().toLowerCase();

          if (errorString.contains('invalid-email') ||
              errorString.contains('invalid_email') ||
              errorString.contains('invalid email')) {
            errorMsg = 'Email inválido';
          } else if (errorString.contains('email-already-in-use')) {
            errorMsg = 'Este email já está em uso';
          } else if (errorString.contains('weak-password')) {
            errorMsg = 'Senha muito fraca';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija os erros no formulário.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Nova Conta'),
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Foto de Perfil
                const SizedBox(height: 16.0),
                Center(
                  child: GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, width: 3),
                          ),
                          child: _selectedImagePath != null
                              ? ClipOval(
                                  child: kIsWeb
                                      ? Image.network(
                                          _selectedImagePath!,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.grey[600],
                                                );
                                              },
                                        )
                                      : Image.file(
                                          File(_selectedImagePath!),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.grey[600],
                                                );
                                              },
                                        ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey[600],
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: secondaryColor,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _selectedImagePath != null
                                  ? Icons.edit
                                  : Icons.camera_alt,
                              color: secondaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),
                Center(
                  child: Text(
                    _selectedImagePath != null
                        ? 'Toque para alterar a foto'
                        : 'Toque para adicionar foto de perfil',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  cursorColor: primaryColor,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    floatingLabelStyle: TextStyle(color: primaryColor),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  cursorColor: primaryColor,
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    floatingLabelStyle: TextStyle(color: primaryColor),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Por favor, insira um email válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  cursorColor: primaryColor,
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Idade',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    floatingLabelStyle: TextStyle(color: primaryColor),
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua idade.';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) {
                      return 'Por favor, insira uma idade válida.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  cursorColor: primaryColor,
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    floatingLabelStyle: TextStyle(color: primaryColor),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: primaryColor,
                    foregroundColor: secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Criar Conta',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
