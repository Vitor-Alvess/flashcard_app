import 'package:firebase_core/firebase_core.dart';
import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/bloc/manager_bloc.dart';
import 'package:flashcard_app/bloc/study_bloc.dart';
import 'package:flashcard_app/bloc/user_bloc.dart';
import 'package:flashcard_app/view/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyB3U5SHnp1XG1JSauySoowEZ9KwrccXrcM",
      authDomain: "flashcard-app-cf8e0.firebaseapp.com",
      projectId: "flashcard-app-cf8e0",
      storageBucket: "flashcard-app-cf8e0.firebasestorage.app",
      messagingSenderId: "900588583829",
      appId: "1:900588583829:web:764e1944f3b2b11e24d49c",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => ManagerBloc()),
        BlocProvider(create: (context) => StudyBloc()),
        BlocProvider(create: (context) => UserBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MainPage(),
      ),
    );
  }
}
