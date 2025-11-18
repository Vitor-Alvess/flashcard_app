import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(Unauthenticated()) {
    FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        add(AuthServerEvent(username: null));
      } else {
        add(AuthServerEvent(username: user.email));
      }
    });

    on<RegisterUser>((event, emit) async {
      try {
        await auth.createUserWithEmailAndPassword(
          email: event.username,
          password: event.password,
        );
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<LoginUser>((event, emit) async {
      try {
        await auth.signInWithEmailAndPassword(
          email: event.username,
          password: event.password,
        );
      } catch (e) {
        emit(AuthError(message: e.toString()));
      }
    });

    on<Logout>((event, emit) {
      auth.signOut();
    });

    on<AuthServerEvent>((event, emit) {
      if (event.username == null) {
        emit(Unauthenticated());
      } else {
        emit(Authenticated(username: event.username!));
      }
    });
  }
}

abstract class AuthEvent {}

class RegisterUser extends AuthEvent {
  String username;
  String password;

  RegisterUser({required this.username, required this.password});
}

class LoginUser extends AuthEvent {
  String username;
  String password;

  LoginUser({required this.username, required this.password});
}

class Logout extends AuthEvent {}

class AuthServerEvent extends AuthEvent {
  String? username;
  AuthServerEvent({required this.username});
}

abstract class AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  String username;
  Authenticated({required this.username});
}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
