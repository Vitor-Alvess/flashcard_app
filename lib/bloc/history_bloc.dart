import 'dart:async';
import 'package:flashcard_app/model/study_history.dart';
import 'package:flashcard_app/provider/firestore_history_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HistoryEvent {}

class LoadHistory extends HistoryEvent {
  final String userId;

  LoadHistory({required this.userId});
}

class AddHistory extends HistoryEvent {
  final StudyHistory history;

  AddHistory({required this.history});
}

class DeleteHistory extends HistoryEvent {
  final String historyId;

  DeleteHistory({required this.historyId});
}

class ResetHistory extends HistoryEvent {}

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<StudyHistory> histories;

  HistoryLoaded({required this.histories});
}

class HistoryError extends HistoryState {
  final String message;

  HistoryError({required this.message});
}

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  StreamSubscription<List<StudyHistory>>? _subscription;

  HistoryBloc() : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<AddHistory>(_onAddHistory);
    on<DeleteHistory>(_onDeleteHistory);
    on<ResetHistory>(_onResetHistory);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      _subscription?.cancel();
      
      // Carregar dados do histórico
      final histories = await FirestoreHistoryProvider.helper.getHistoryByUserId(event.userId);
      print('Loaded ${histories.length} histories for user: ${event.userId}');
      emit(HistoryLoaded(histories: histories));
      
      // Opcionalmente, escutar mudanças em tempo real (mas não é necessário)
      // O histórico será recarregado quando o usuário voltar para a página
    } catch (e, stackTrace) {
      print('Error loading history: $e');
      print('Stack trace: $stackTrace');
      emit(HistoryError(message: e.toString()));
    }
  }

  Future<void> _onAddHistory(AddHistory event, Emitter<HistoryState> emit) async {
    try {
      await FirestoreHistoryProvider.helper.insertHistory(event.history);
      // O stream irá atualizar automaticamente o estado
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteHistory(DeleteHistory event, Emitter<HistoryState> emit) async {
    try {
      await FirestoreHistoryProvider.helper.deleteHistory(event.historyId);
      // O stream irá atualizar automaticamente o estado
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }

  void _onResetHistory(ResetHistory event, Emitter<HistoryState> emit) {
    _subscription?.cancel();
    emit(HistoryInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

