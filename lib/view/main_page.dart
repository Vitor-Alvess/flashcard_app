import 'package:flashcard_app/model/user.dart';
import 'package:flashcard_app/view/create_account_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final User _user = User.empty();

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
                        // Closes the dialog
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
      body: Stack(
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLoginDialog(context);
        },
        shape: const CircleBorder(),

        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset("assets/images/addButton.png"),
        ),
      ),
      backgroundColor: Colors.black87,
    );
  }
}
