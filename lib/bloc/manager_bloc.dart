import 'dart:async';

import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/provider/firestore_collection_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  StreamSubscription<List<Collection>>? _subscription;
  StreamSubscription<User?>? _authSub;

  ManagerBloc() : super(InsertState(const [])) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    _authSub = auth.authStateChanges().listen((user) {
      _subscription?.cancel();
      _subscription = null;

      if (user == null) {
        add(BackendEvent(collectionList: []));
        return;
      }

      final email = user.email;
      if (email != null && email.isNotEmpty) {
        try {
          _subscription = FirestoreCollectionProvider.helper
              .collectionsStreamForUser(email)
              .listen((list) => add(BackendEvent(collectionList: list)));
        } catch (e, st) {
          print(
            'ManagerBloc: failed to subscribe to collectionsStreamForUser: $e\n$st',
          );
          _subscription = null;
        }
      } else {
        add(BackendEvent(collectionList: []));
      }
    });

    on<SubmitEvent>((event, emit) async {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) return;

      if (state is UpdateState) {
        final col = event.collection;
        await FirestoreCollectionProvider.helper.updateCollection(
          col.id,
          col.toMap(),
          userEmail,
        );
      } else {
        await FirestoreCollectionProvider.helper.insertCollection(
          event.collection,
          userEmail,
        );
      }
    });

    on<UpdateRequest>((event, emit) {
      emit(UpdateState(state.collectionList, event.collection));
    });

    on<UpdateCancel>((event, emit) {
      emit(InsertState(state.collectionList));
    });

    on<BackendEvent>((event, emit) {
      emit(InsertState(event.collectionList));
    });

    on<DeleteEvent>((event, emit) async {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) return;

      await FirestoreCollectionProvider.helper.deleteCollection(
        event.collectionId,
        {},
        userEmail,
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _authSub?.cancel();
    return super.close();
  }
}

abstract class ManagerEvent {}

class SubmitEvent extends ManagerEvent {
  Collection collection;
  SubmitEvent({required this.collection});
}

class UpdateRequest extends ManagerEvent {
  Collection collection;
  UpdateRequest({required this.collection});
}

class UpdateCancel extends ManagerEvent {}

class BackendEvent extends ManagerEvent {
  List<Collection> collectionList;
  BackendEvent({required this.collectionList});
}

class DeleteEvent extends ManagerEvent {
  String collectionId;
  DeleteEvent({required this.collectionId});
}

class ToggleUsefulEvent extends ManagerEvent {
  Collection collection;
  ToggleUsefulEvent({required this.collection});
}

abstract class ManagerState {
  List<Collection> collectionList;
  ManagerState(this.collectionList);
}

class InsertState extends ManagerState {
  InsertState(super.collectionList);
}

class UpdateState extends ManagerState {
  Collection collection;

  UpdateState(super.collectionList, this.collection);
}
