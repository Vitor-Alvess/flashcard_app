import 'dart:async';

import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/provider/firestore_collection_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManagerBloc extends Bloc<ManagerEvent, ManagerState> {
  StreamSubscription<List<Collection>>? _subscription;

  ManagerBloc() : super(InsertState(const [])) {
    try {
      _subscription = FirestoreCollectionProvider.helper
          .collectionsStream()
          .listen((list) => add(BackendEvent(collectionList: list)));
    } catch (e, st) {
      // Firestore may not be available yet (or plugin not registered).
      // Avoid throwing during bloc construction; log and continue.
      print('ManagerBloc: failed to subscribe to collectionsStream: $e\n$st');
      _subscription = null;
    }
    ;

    on<SubmitEvent>((event, emit) async {
      if (state is UpdateState) {
        final col = event.collection;
        await FirestoreCollectionProvider.helper.updateCollection(
          col.id,
          col.toMap(),
        );
      } else {
        await FirestoreCollectionProvider.helper.insertCollection(
          event.collection,
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
      await FirestoreCollectionProvider.helper.deleteCollection(
        event.collectionId,
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
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
