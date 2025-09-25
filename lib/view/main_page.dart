import 'package:flutter/material.dart';

class main_page extends StatefulWidget {
  const main_page({super.key});

  @override
  State<main_page> createState() => _main_pageState();
}

class _main_pageState extends State<main_page> {
  int _selectedIndex = 0;
  String _name = "";

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
    final TextEditingController nameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: const Text("Login Necessário"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text("Para criar uma coleção, você precisa fazer o login."),
              const SizedBox(height: 16),
              TextField(
                cursorColor: Colors.black,
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextField(
                cursorColor: Colors.black,
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  floatingLabelStyle: TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                obscureText: true, // Hides the password
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "CANCELAR",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                // Closes the dialog
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                "ENTRAR",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                setState(() {
                  _name = nameController.text.trim();

                  Navigator.of(context).pop();
                });
              },
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
            _name.isNotEmpty
                ? Text(
                    'Olá, $_name!',
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
