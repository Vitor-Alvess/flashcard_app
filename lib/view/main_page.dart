import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/bloc/history_bloc.dart';
import 'package:flashcard_app/bloc/manager_bloc.dart';
import 'package:flashcard_app/bloc/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcard_app/model/user.dart';
import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/view/collection_details_page.dart';
import 'package:flashcard_app/view/history_page.dart';
import 'package:flashcard_app/view/profile_page.dart';
import 'package:flashcard_app/view/login_dialog.dart';
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
  int _selectedIndex = 0;

  void _addCollection(
    BuildContext context,
    String name,
    Color color, {
    String? imagePath,
  }) {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    // Obter email do usuário logado
    String? userId;
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      userId = authState.username;
    }

    final newCollection = Collection(
      id: tempId,
      name: name,
      color: color,
      flashcards: [],
      imagePath: imagePath,
      createdAt: DateTime.now(),
      userId: userId,
    );

    context.read<ManagerBloc>().add(SubmitEvent(collection: newCollection));
  }

  void _showCollectionMenu(BuildContext context, Collection collection) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Editar"),
                onTap: () {
                  Navigator.pop(context);
                  _showEditCollectionDialog(context, collection);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Excluir", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteCollectionDialog(context, collection);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteCollectionDialog(
    BuildContext context,
    Collection collection,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            "Excluir Coleção",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Tem certeza que deseja excluir a coleção \"${collection.name}\"?\n\nTodas as perguntas serão perdidas.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ManagerBloc>().add(
                  DeleteEvent(collectionId: collection.id),
                );
              },
              child: const Text(
                "Excluir",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditCollectionDialog(BuildContext context, Collection collection) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(
      text: collection.name,
    );
    Color selectedColor = collection.color;
    bool isColorMode = true;
    String? selectedImagePath = collection.imagePath;
    bool isImageMode =
        collection.imagePath != null && collection.imagePath!.isNotEmpty;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
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
                                    dialogSetState(() {
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
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  dialogSetState(() {
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
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  dialogSetState(() {
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
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  dialogSetState(() {
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                              child: Column(
                                children: [
                                  SizedBox(height: 15),
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
                                              dialogSetState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                                selectedImagePath = null;
                                                isImageMode = false;
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
                                              dialogSetState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                                selectedImagePath = null;
                                                isImageMode = false;
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
                                              dialogSetState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                                // Limpar foto quando escolher cor
                                                selectedImagePath = null;
                                                isImageMode = false;
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
                            "Salvar alterações",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.of(context).pop();

                              // Obter email do usuário logado
                              String? userId;
                              final authState = context.read<AuthBloc>().state;
                              if (authState is Authenticated) {
                                userId = authState.username;
                              }

                              final updatedCollection = Collection(
                                id: collection.id,
                                name: nameController.text,
                                color: selectedColor,
                                flashcards: collection.flashcards,
                                imagePath: selectedImagePath,
                                createdAt: collection.createdAt,
                                userId: userId ?? collection.userId,
                              );
                              context.read<ManagerBloc>().add(
                                SubmitEvent(collection: updatedCollection),
                              );
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
          builder: (context, setDialogState) {
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
                                    setDialogState(() {
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
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
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
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
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
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  setDialogState(() {
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                              child: Column(
                                children: [
                                  SizedBox(height: 15),
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
                                              setDialogState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                                selectedImagePath = null;
                                                isImageMode = false;
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
                                              setDialogState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                                selectedImagePath = null;
                                                isImageMode = false;
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
                                              setDialogState(() {
                                                selectedColor = color;
                                                isColorMode = true;
                                                selectedImagePath = null;
                                                isImageMode = false;
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
                              final colorToSave = selectedColor;
                              final imagePathToSave = selectedImagePath;
                              Navigator.of(context).pop();
                              _addCollection(
                                context,
                                nameController.text,
                                colorToSave,
                                imagePath: imagePathToSave,
                              );
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
    final userState = context.read<UserBloc>().state;
    final user = userState is UserInitial
        ? userState.user
        : userState is UserLoaded
        ? userState.user
        : userState is UserUpdated
        ? userState.user
        : User.empty();
    showDialog(
      context: context,
      builder: (_) => LoginDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              context.read<UserBloc>().add(LoadUser(email: state.username));
              context.read<ManagerBloc>().add(
                SetUserIdEvent(userId: state.username),
              );
            } else {
              context.read<UserBloc>().add(ClearUser());
              context.read<ManagerBloc>().add(SetUserIdEvent(userId: null));
              context.read<HistoryBloc>().add(ResetHistory());
            }
          },
        ),
        BlocListener<ManagerBloc, ManagerState>(
          listener: (context, state) {
            if (state is InsertState && state.collectionList.isEmpty) {
              // Pode mostrar mensagem se necessário
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                "Aplicativo",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is! Authenticated) {
                    return const SizedBox.shrink();
                  }
                  return BlocBuilder<UserBloc, UserState>(
                    builder: (context, userState) {
                      final user = userState is UserInitial
                          ? userState.user
                          : userState is UserLoaded
                          ? userState.user
                          : userState is UserUpdated
                          ? userState.user
                          : User.empty();
                      if (user.isLoggedIn && user.name.isNotEmpty) {
                        return Text(
                          'Olá, ${user.name}!',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
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
                  Navigator.pop(context);
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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                final isAuthenticated = authState is Authenticated;
                if (!isAuthenticated) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Faça login para acessar suas coleções",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _showLoginDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            "Fazer Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return BlocBuilder<ManagerBloc, ManagerState>(
                  builder: (context, managerState) {
                    final collections = managerState.collectionList;
                    return collections.isEmpty
                        ? Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(60.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/sleepingCat.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.5,
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.3,
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
                                    itemCount: collections.length,
                                    itemBuilder: (context, index) {
                                      final collection = collections[index];
                                      return GestureDetector(
                                        onTap: () async {
                                          // Verificar autenticação antes de abrir detalhes
                                          final authState = context
                                              .read<AuthBloc>()
                                              .state;
                                          if (authState is! Authenticated) {
                                            _showLoginDialog(context);
                                            return;
                                          }
                                          final userState = context
                                              .read<UserBloc>()
                                              .state;
                                          final user = userState is UserInitial
                                              ? userState.user
                                              : userState is UserLoaded
                                              ? userState.user
                                              : userState is UserUpdated
                                              ? userState.user
                                              : User.empty();
                                          await Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) => CollectionDetailsPage(
                                                    collection: collection,
                                                    user: user,
                                                  ),
                                              transitionsBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) {
                                                    const begin = Offset(
                                                      1.0,
                                                      0.0,
                                                    );
                                                    const end = Offset.zero;
                                                    const curve =
                                                        Curves.easeInOut;

                                                    var tween =
                                                        Tween(
                                                          begin: begin,
                                                          end: end,
                                                        ).chain(
                                                          CurveTween(
                                                            curve: curve,
                                                          ),
                                                        );

                                                    return SlideTransition(
                                                      position: animation.drive(
                                                        tween,
                                                      ),
                                                      child: child,
                                                    );
                                                  },
                                              transitionDuration:
                                                  const Duration(
                                                    milliseconds: 300,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: collection.color,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.2,
                                                ),
                                                blurRadius: 8,
                                                offset: Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              // Imagem de fundo se houver
                                              if (collection.imagePath !=
                                                      null &&
                                                  collection
                                                      .imagePath!
                                                      .isNotEmpty)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: kIsWeb
                                                      ? Image.network(
                                                          collection.imagePath!,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Container(
                                                                  color:
                                                                      collection
                                                                          .color,
                                                                );
                                                              },
                                                        )
                                                      : Image.file(
                                                          File(
                                                            collection
                                                                .imagePath!,
                                                          ),
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (
                                                                context,
                                                                error,
                                                                stackTrace,
                                                              ) {
                                                                return Container(
                                                                  color:
                                                                      collection
                                                                          .color,
                                                                );
                                                              },
                                                        ),
                                                ),
                                              // Overlay escuro para melhorar legibilidade do texto
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black.withOpacity(
                                                        0.7,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Botão de menu (três pontinhos)
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showCollectionMenu(
                                                      context,
                                                      collection,
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.more_vert,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Conteúdo
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      collection.name,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${collection.flashcardCount} flashcards',
                                                          style: TextStyle(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color: Colors.white
                                                              .withOpacity(0.9),
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
                          );
                  },
                );
              },
            ),
            // Página Histórico (índice 1)
            BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                final user = userState is UserInitial
                    ? userState.user
                    : userState is UserLoaded
                    ? userState.user
                    : userState is UserUpdated
                    ? userState.user
                    : User.empty();
                return HistoryPage(user: user);
              },
            ),
            // Página Perfil (índice 2)
            BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                final user = userState is UserInitial
                    ? userState.user
                    : userState is UserLoaded
                    ? userState.user
                    : userState is UserUpdated
                    ? userState.user
                    : User.empty();
                return ProfilePage(
                  user: user,
                  onLogout: () {
                    context.read<AuthBloc>().add(Logout());
                    context.read<UserBloc>().add(ClearUser());
                    setState(() {
                      _selectedIndex = 0; // Volta para o início após deslogar
                    });
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isAuthenticated = state is Authenticated;
                  return FloatingActionButton(
                    heroTag: "add_collection_fab",
                    onPressed: () {
                      if (isAuthenticated) {
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
                  );
                },
              )
            : null,
        backgroundColor: Colors.black87,
      ),
    );
  }
}
