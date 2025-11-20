import 'package:flashcard_app/model/user.dart';
import 'package:flashcard_app/provider/firestore_user_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UserEvent {}

class LoadUser extends UserEvent {
  final String email;

  LoadUser({required this.email});
}

class UpdateUserName extends UserEvent {
  final String name;

  UpdateUserName({required this.name});
}

class UpdateUserEmail extends UserEvent {
  final String email;

  UpdateUserEmail({required this.email});
}

class UpdateUserAge extends UserEvent {
  final int age;

  UpdateUserAge({required this.age});
}

class UpdateUserProfilePicture extends UserEvent {
  final String? imagePath;

  UpdateUserProfilePicture({required this.imagePath});
}

class SaveUser extends UserEvent {
  final User user;

  SaveUser({required this.user});
}

class ClearUser extends UserEvent {}

abstract class UserState {}

class UserInitial extends UserState {
  final User user;

  UserInitial({required this.user});
}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  UserLoaded({required this.user});
}

class UserUpdated extends UserState {
  final User user;

  UserUpdated({required this.user});
}

class UserError extends UserState {
  final String message;

  UserError({required this.message});
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial(user: User.empty())) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUserName>(_onUpdateUserName);
    on<UpdateUserEmail>(_onUpdateUserEmail);
    on<UpdateUserAge>(_onUpdateUserAge);
    on<UpdateUserProfilePicture>(_onUpdateUserProfilePicture);
    on<SaveUser>(_onSaveUser);
    on<ClearUser>(_onClearUser);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final user = await FirestoreUserProvider.helper.findUserByEmail(event.email);
      if (user != null) {
        emit(UserLoaded(user: user));
      } else {
        emit(UserError(message: 'Usuário não encontrado'));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  void _onUpdateUserName(UpdateUserName event, Emitter<UserState> emit) {
    final currentUser = _getCurrentUser();
    final updatedUser = User(
      name: event.name,
      email: currentUser.email,
      age: currentUser.age,
    );
    updatedUser.profilePicturePath = currentUser.profilePicturePath;
    emit(UserUpdated(user: updatedUser));
  }

  void _onUpdateUserEmail(UpdateUserEmail event, Emitter<UserState> emit) {
    final currentUser = _getCurrentUser();
    final updatedUser = User(
      name: currentUser.name,
      email: event.email,
      age: currentUser.age,
    );
    updatedUser.profilePicturePath = currentUser.profilePicturePath;
    emit(UserUpdated(user: updatedUser));
  }

  void _onUpdateUserAge(UpdateUserAge event, Emitter<UserState> emit) {
    final currentUser = _getCurrentUser();
    final updatedUser = User(
      name: currentUser.name,
      email: currentUser.email,
      age: event.age,
    );
    updatedUser.profilePicturePath = currentUser.profilePicturePath;
    emit(UserUpdated(user: updatedUser));
  }

  void _onUpdateUserProfilePicture(UpdateUserProfilePicture event, Emitter<UserState> emit) {
    final currentUser = _getCurrentUser();
    final updatedUser = User(
      name: currentUser.name,
      email: currentUser.email,
      age: currentUser.age,
    );
    updatedUser.profilePicturePath = event.imagePath;
    emit(UserUpdated(user: updatedUser));
  }

  Future<void> _onSaveUser(SaveUser event, Emitter<UserState> emit) async {
    try {
      await FirestoreUserProvider.helper.insertUser(event.user);
      emit(UserUpdated(user: event.user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  void _onClearUser(ClearUser event, Emitter<UserState> emit) {
    emit(UserInitial(user: User.empty()));
  }

  User _getCurrentUser() {
    if (state is UserInitial) {
      return (state as UserInitial).user;
    } else if (state is UserLoaded) {
      return (state as UserLoaded).user;
    } else if (state is UserUpdated) {
      return (state as UserUpdated).user;
    }
    return User.empty();
  }
}

