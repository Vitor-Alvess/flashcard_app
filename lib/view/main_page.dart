import 'package:flashcard_app/model/user.dart';
import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/view/create_account_page.dart';
import 'package:flashcard_app/view/collection_details_page.dart';
import 'package:flashcard_app/view/history_page.dart';
import 'package:flashcard_app/view/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  User _user = User.empty();
  List<Collection> _collections = [];

  int _selectedIndex = 0;
  String get name => _user.name;

  void _addCollection(String name, Color color, {String? imagePath}) {
    final newCollection = Collection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      imagePath: imagePath,
    );

    setState(() {
      _collections.add(newCollection);
    });
  }

  void _showCreateCollectionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    bool isColorMode = true;
    String? selectedImagePath;
    bool isImageMode = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Área de imagem/cor (só aparece quando não está escolhendo cor)
                    if (isColorMode && !isImageMode)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Botão de foto no canto inferior esquerdo
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: GestureDetector(
                                onTap: () async {
                                  final ImagePicker picker = ImagePicker();
                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 800,
                                    maxHeight: 800,
                                    imageQuality: 85,
                                  );
                                  if (image != null) {
                                    setState(() {
                                      selectedImagePath = image.path;
                                      isImageMode = true;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.photo,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            // Botão de roda de cores no canto inferior direito
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isColorMode = false;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.palette,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Área de imagem quando foto foi selecionada
                    if (isImageMode)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: kIsWeb
                                  ? Image.network(
                                      selectedImagePath!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(selectedImagePath!),
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            // Botão para remover foto e voltar para cor
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImagePath = null;
                                    isImageMode = false;
                                  });
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            // Botão de roda de cores no canto inferior direito
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isColorMode = false;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.palette,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Seletor de cores (aparece quando clica no botão de paleta)
                    if (!isColorMode)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Header com botão de voltar
                            Container(
                              padding: EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isColorMode = true;
                                      });
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.grey[600],
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Escolha uma cor:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Grid de cores
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                              child: Column(
                                children: [
                                  SizedBox(height: 15),
                                  // Primeira linha - cores básicas
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children:
                                        [
                                          Colors.red,
                                          Colors.orange,
                                          Colors.yellow,
                                          Colors.green,
                                          Colors.blue,
                                          Colors.purple,
                                        ].map((color) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                              });
                                            },
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: selectedColor == color
                                                      ? Colors.black
                                                      : Colors.grey[300]!,
                                                  width: selectedColor == color
                                                      ? 3
                                                      : 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 2,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                  SizedBox(height: 10),
                                  // Segunda linha - cores adicionais
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children:
                                        [
                                          Colors.pink,
                                          Colors.teal,
                                          Colors.indigo,
                                          Colors.amber,
                                          Colors.cyan,
                                          Colors.deepOrange,
                                        ].map((color) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                              });
                                            },
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: selectedColor == color
                                                      ? Colors.black
                                                      : Colors.grey[300]!,
                                                  width: selectedColor == color
                                                      ? 3
                                                      : 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 2,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                  SizedBox(height: 10),
                                  // Terceira linha - tons de cinza
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children:
                                        [
                                          Colors.grey[300]!,
                                          Colors.grey[500]!,
                                          Colors.grey[700]!,
                                          Colors.brown,
                                          Colors.lime,
                                          Colors.deepPurple,
                                        ].map((color) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                              });
                                            },
                                            child: Container(
                                              width: 35,
                                              height: 35,
                                              decoration: BoxDecoration(
                                                color: color,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: selectedColor == color
                                                      ? Colors.black
                                                      : Colors.grey[300]!,
                                                  width: selectedColor == color
                                                      ? 3
                                                      : 1,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 2,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Campo de nome
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nome",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              cursorColor: Colors.black,
                              style: TextStyle(fontSize: 14),
                              controller: nameController,
                              decoration: InputDecoration(
                                hintText: 'Nome do seu Grupo',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Nome é obrigatório";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botão criar
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Criar novo Grupo",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              _addCollection(
                                nameController.text,
                                selectedColor,
                                imagePath: selectedImagePath,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLoginDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
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
                const SizedBox(height: 5),
                SizedBox(
                  height: 30,
                  child: TextFormField(
                    cursorColor: Colors.black,
                    style: TextStyle(fontSize: 11),
                    controller: nameController,
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
                const SizedBox(height: 5),
                SizedBox(
                  height: 30,
                  child: TextFormField(
                    cursorColor: Colors.black,
                    style: TextStyle(fontSize: 11),
                    controller: passwordController,
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
                      child: const Text(
                        "ENTRAR",
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: ContinuousRectangleBorder(),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAccountPage(user: _user),
                        ),
                      );

                      setState(() {});

                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Criar conta",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "Aplicativo",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            _user.name.isNotEmpty
                ? Text(
                    'Olá, $name!',
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(221, 90, 90, 90),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Início"),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context); // closes drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.history_edu),
              title: Text("Histórico"),
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Perfil"),
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Página Início (índice 0)
          _collections.isEmpty
              ? Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/sleepingCat.png',
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: MediaQuery.of(context).size.height * 0.3,
                              fit: BoxFit.contain,
                            ),
                            Text(
                              'Não há nada aqui, ainda...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 65,
                      right: 65,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Crie sua primeira coleção!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 25,
                      right: 75,
                      child: Image.asset(
                        'assets/images/arrowRight.png',
                        height: 40,
                        width: 40,
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 16.0,
                        ),
                        child: Text(
                          'Suas Coleções',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.2,
                              ),
                          itemCount: _collections.length,
                          itemBuilder: (context, index) {
                            final collection = _collections[index];
                            return GestureDetector(
                              onTap: () async {
                                final updatedCollection = await Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => CollectionDetailsPage(
                                          collection: collection,
                                        ),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;

                                          var tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                    transitionDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                  ),
                                );

                                if (updatedCollection != null &&
                                    updatedCollection is Collection) {
                                  setState(() {
                                    final index = _collections.indexWhere(
                                      (c) => c.id == updatedCollection.id,
                                    );
                                    if (index != -1) {
                                      _collections[index] = updatedCollection;
                                    }
                                  });
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: collection.color,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Imagem de fundo se houver
                                    if (collection.imagePath != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: kIsWeb
                                            ? Image.network(
                                                collection.imagePath!,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: collection.color,
                                                      );
                                                    },
                                              )
                                            : Image.file(
                                                File(collection.imagePath!),
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: collection.color,
                                                      );
                                                    },
                                              ),
                                      ),
                                    // Overlay escuro para melhorar legibilidade do texto
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Conteúdo
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            collection.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${collection.flashcardCount} flashcards',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          // Página Histórico (índice 1)
          const HistoryPage(),
          // Página Perfil (índice 2)
          ProfilePage(
            user: _user,
            onUserUpdate: (updatedUser) {
              setState(() {
                _user = updatedUser;
              });
            },
            onLogout: () {
              setState(() {
                _user = User.empty();
                _selectedIndex = 0; // Volta para o início após deslogar
              });
            },
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                if (_user.isLoggedIn) {
                  _showCreateCollectionDialog(context);
                } else {
                  _showLoginDialog(context);
                }
              },
              shape: const CircleBorder(),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset("assets/images/addButton.png"),
              ),
            )
          : null,
      backgroundColor: Colors.black87,
    );
  }
}
