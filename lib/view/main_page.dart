import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/provider/firestore_collection_provider.dart';
import 'package:flashcard_app/provider/firestore_user_provider.dart';
import 'package:flashcard_app/view/collection_grid_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flashcard_app/model/user.dart';
import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/view/create_collection_page.dart';
import 'package:flashcard_app/view/login_dialog.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final User _user = User.empty();
  List<Collection> _collections = [];

  Future<User?>? _userFuture;
  Future<List<Collection>>? _collectionsFuture;

  int _selectedIndex = 0;
  String get name => _user.name;

  final List<Widget> _pages = [
    Center(
      child: Text("Início", style: TextStyle(color: Colors.white)),
    ),
    Center(
      child: Text("Histórico", style: TextStyle(color: Colors.white)),
    ),
    Center(
      child: Text("Perfil", style: TextStyle(color: Colors.white)),
    ),
  ];

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => LoginDialog(user: _user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _userFuture = FirestoreUserProvider.helper.findUserByEmail(
            state.username,
          );

          _collectionsFuture = FirestoreCollectionProvider.helper
              .getAllCollections(state.username);
        } else {
          _userFuture = null;
        }

        if (mounted) setState(() {});
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                "Aplicativo",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              FutureBuilder<User?>(
                future: _userFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

                  final user = snapshot.data;
                  if (user != null) {
                    return Text(
                      'Olá, ${user.name}!',
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    );
                  }

                  return const SizedBox.shrink();
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
        body: FutureBuilder<List<Collection>>(
          future: _collectionsFuture,
          builder: (context, snapshot) {
            final collections = snapshot.data;

            if (collections == null || collections.isEmpty) {
              return Stack(
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
              );
            }
            return CollectionGridView(collections: collections);
          },
        ),
        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final signedIn = state is Authenticated;
            return FloatingActionButton(
              onPressed: () async {
                if (signedIn) {
                  final created = await Navigator.push<Collection?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateCollectionPage(user: _user),
                    ),
                  );

                  if (created != null) {
                    setState(() {
                      _collections.add(created);
                    });
                  }
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
        ),
        backgroundColor: Colors.black87,
      ),
    );
  }
}
