import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_core/firebase_core.dart' show Firebase;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(Unauthenticated()) {
    fb_auth.FirebaseAuth? auth;
    try {
      // Only access FirebaseAuth if a Firebase app exists and plugins are
      // available. Accessing FirebaseAuth.instance can throw if Firebase
      // hasn't been properly initialized on this platform.
      if (Firebase.apps.isNotEmpty) {
        auth = fb_auth.FirebaseAuth.instance;
        auth.authStateChanges().listen((fb_auth.User? user) {
          if (user == null) {
            add(AuthServerEvent(username: null));
          } else {
            add(AuthServerEvent(username: user.email));
          }
        });
      }
    } catch (e) {
      // If Firebase isn't available, the bloc will still operate but auth
      // related operations will return errors when attempted.
      print('AuthBloc: FirebaseAuth not available: $e');
      auth = null;
    }
    ;

    on<RegisterUser>((event, emit) async {
      if (auth == null) {
        emit(AuthError(message: 'FirebaseAuth not initialized'));
        return;
      }
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
      if (auth == null) {
        emit(AuthError(message: 'FirebaseAuth not initialized'));
        return;
      }
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
      auth?.signOut();
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
