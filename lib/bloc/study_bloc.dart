import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/model/flashcard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

enum StudyMode { written, multipleChoice, selfAssessment }

abstract class StudyEvent {}

class InitializeStudy extends StudyEvent {
  final Collection collection;
  final StudyMode mode;

  InitializeStudy({required this.collection, required this.mode});
}

class CheckAnswer extends StudyEvent {
  final String? userAnswer;
  final String? selectedAnswer;

  CheckAnswer({this.userAnswer, this.selectedAnswer});
}

class SelfAssess extends StudyEvent {
  final bool correct;

  SelfAssess({required this.correct});
}

class NextQuestion extends StudyEvent {}

class ShowAnswer extends StudyEvent {}

class PauseStudy extends StudyEvent {}

class ResumeStudy extends StudyEvent {}

class RestartStudy extends StudyEvent {}

abstract class StudyState {}

class StudyInitial extends StudyState {}

class StudyInProgress extends StudyState {
  final List<Flashcard> shuffledQuestions;
  final Map<String, List<String>> multipleChoiceOptions;
  final int currentIndex;
  final bool showAnswer;
  final String? selectedAnswer;
  final bool? isAnswerCorrect;
  final int correctAnswers;
  final Map<String, bool> questionResults;
  final bool isPaused;
  final StudyMode mode;

  StudyInProgress({
    required this.shuffledQuestions,
    required this.multipleChoiceOptions,
    required this.currentIndex,
    required this.showAnswer,
    this.selectedAnswer,
    this.isAnswerCorrect,
    required this.correctAnswers,
    required this.questionResults,
    required this.isPaused,
    required this.mode,
  });

  Flashcard get currentQuestion => shuffledQuestions[currentIndex];
  String get progress => "${currentIndex + 1}/${shuffledQuestions.length}";
  bool get isFinished => currentIndex >= shuffledQuestions.length - 1;
}

class StudyCompleted extends StudyState {
  final int correctAnswers;
  final int totalQuestions;
  final int percentage;
  final Map<String, bool> questionResults;

  StudyCompleted({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
    required this.questionResults,
  });
}

class StudyBloc extends Bloc<StudyEvent, StudyState> {
  StudyBloc() : super(StudyInitial()) {
    on<InitializeStudy>(_onInitializeStudy);
    on<CheckAnswer>(_onCheckAnswer);
    on<SelfAssess>(_onSelfAssess);
    on<NextQuestion>(_onNextQuestion);
    on<ShowAnswer>(_onShowAnswer);
    on<PauseStudy>(_onPauseStudy);
    on<ResumeStudy>(_onResumeStudy);
    on<RestartStudy>(_onRestartStudy);
  }

  void _onInitializeStudy(InitializeStudy event, Emitter<StudyState> emit) {
    final shuffledQuestions = List<Flashcard>.from(event.collection.flashcards);
    shuffledQuestions.shuffle(Random());

    final multipleChoiceOptions = <String, List<String>>{};
    if (event.mode == StudyMode.multipleChoice) {
      final random = Random();
      for (var question in shuffledQuestions) {
        if (question.multipleChoiceOptions != null) {
          List<String> options = List<String>.from(question.multipleChoiceOptions!);
          options.shuffle(random);
          multipleChoiceOptions[question.id] = options;
        } else {
          List<String> allAnswers = event.collection.flashcards
              .map((q) => q.answer)
              .where((answer) => answer != question.answer)
              .toList();
          allAnswers.shuffle(random);
          List<String> options = [question.answer];
          options.addAll(allAnswers.take(3));
          options.shuffle(random);
          multipleChoiceOptions[question.id] = options;
        }
      }
    }

    emit(StudyInProgress(
      shuffledQuestions: shuffledQuestions,
      multipleChoiceOptions: multipleChoiceOptions,
      currentIndex: 0,
      showAnswer: false,
      correctAnswers: 0,
      questionResults: {},
      isPaused: false,
      mode: event.mode,
    ));
  }

  void _onCheckAnswer(CheckAnswer event, Emitter<StudyState> emit) {
    if (state is! StudyInProgress) return;

    final currentState = state as StudyInProgress;
    final currentQuestion = currentState.currentQuestion;
    bool isCorrect = false;

    if (currentState.mode == StudyMode.written) {
      final userAnswer = (event.userAnswer ?? '').trim();
      final correctAnswer = currentQuestion.answer.trim();
      final isCaseSensitive = currentQuestion.caseSensitive;

      isCorrect = isCaseSensitive
          ? userAnswer == correctAnswer
          : userAnswer.toLowerCase() == correctAnswer.toLowerCase();
    } else if (currentState.mode == StudyMode.multipleChoice) {
      isCorrect = event.selectedAnswer == currentQuestion.answer;
    }

    final questionResults = Map<String, bool>.from(currentState.questionResults);
    final wasAlreadyAnswered = questionResults.containsKey(currentQuestion.id);
    if (!wasAlreadyAnswered) {
      questionResults[currentQuestion.id] = isCorrect;
    }

    // Incrementar apenas se a resposta estava correta E não foi respondida antes
    final correctAnswers = isCorrect && !wasAlreadyAnswered
        ? currentState.correctAnswers + 1
        : currentState.correctAnswers;

    emit(StudyInProgress(
      shuffledQuestions: currentState.shuffledQuestions,
      multipleChoiceOptions: currentState.multipleChoiceOptions,
      currentIndex: currentState.currentIndex,
      showAnswer: true,
      selectedAnswer: event.selectedAnswer,
      isAnswerCorrect: isCorrect,
      correctAnswers: correctAnswers,
      questionResults: questionResults,
      isPaused: currentState.isPaused,
      mode: currentState.mode,
    ));
  }

  void _onSelfAssess(SelfAssess event, Emitter<StudyState> emit) {
    if (state is! StudyInProgress) return;

    final currentState = state as StudyInProgress;
    final currentQuestion = currentState.currentQuestion;

    final questionResults = Map<String, bool>.from(currentState.questionResults);
    final wasAlreadyAnswered = questionResults.containsKey(currentQuestion.id);
    if (!wasAlreadyAnswered) {
      questionResults[currentQuestion.id] = event.correct;
    }

    // Incrementar apenas se a resposta estava correta E não foi respondida antes
    final correctAnswers = event.correct && !wasAlreadyAnswered
        ? currentState.correctAnswers + 1
        : currentState.correctAnswers;

    final updatedState = StudyInProgress(
      shuffledQuestions: currentState.shuffledQuestions,
      multipleChoiceOptions: currentState.multipleChoiceOptions,
      currentIndex: currentState.currentIndex,
      showAnswer: true,
      selectedAnswer: currentState.selectedAnswer,
      isAnswerCorrect: event.correct,
      correctAnswers: correctAnswers,
      questionResults: questionResults,
      isPaused: currentState.isPaused,
      mode: currentState.mode,
    );

    emit(updatedState);
    add(NextQuestion());
  }

  void _onNextQuestion(NextQuestion event, Emitter<StudyState> emit) {
    if (state is! StudyInProgress) return;

    final currentState = state as StudyInProgress;

    if (currentState.isFinished) {
      final totalQuestions = currentState.shuffledQuestions.length;
      // Recalcular acertos baseado no questionResults para garantir precisão
      final actualCorrectAnswers = currentState.questionResults.values
          .where((isCorrect) => isCorrect == true)
          .length;
      final percentage = totalQuestions > 0
          ? (actualCorrectAnswers / totalQuestions * 100).round()
          : 0;

      emit(StudyCompleted(
        correctAnswers: actualCorrectAnswers,
        totalQuestions: totalQuestions,
        percentage: percentage,
        questionResults: currentState.questionResults,
      ));
    } else {
      emit(StudyInProgress(
        shuffledQuestions: currentState.shuffledQuestions,
        multipleChoiceOptions: currentState.multipleChoiceOptions,
        currentIndex: currentState.currentIndex + 1,
        showAnswer: false,
        selectedAnswer: null,
        isAnswerCorrect: null,
        correctAnswers: currentState.correctAnswers,
        questionResults: currentState.questionResults,
        isPaused: currentState.isPaused,
        mode: currentState.mode,
      ));
    }
  }

  void _onShowAnswer(ShowAnswer event, Emitter<StudyState> emit) {
    if (state is! StudyInProgress) return;

    final currentState = state as StudyInProgress;
    emit(StudyInProgress(
      shuffledQuestions: currentState.shuffledQuestions,
      multipleChoiceOptions: currentState.multipleChoiceOptions,
      currentIndex: currentState.currentIndex,
      showAnswer: true,
      selectedAnswer: currentState.selectedAnswer,
      isAnswerCorrect: currentState.isAnswerCorrect,
      correctAnswers: currentState.correctAnswers,
      questionResults: currentState.questionResults,
      isPaused: currentState.isPaused,
      mode: currentState.mode,
    ));
  }

  void _onPauseStudy(PauseStudy event, Emitter<StudyState> emit) {
    if (state is! StudyInProgress) return;

    final currentState = state as StudyInProgress;
    emit(StudyInProgress(
      shuffledQuestions: currentState.shuffledQuestions,
      multipleChoiceOptions: currentState.multipleChoiceOptions,
      currentIndex: currentState.currentIndex,
      showAnswer: currentState.showAnswer,
      selectedAnswer: currentState.selectedAnswer,
      isAnswerCorrect: currentState.isAnswerCorrect,
      correctAnswers: currentState.correctAnswers,
      questionResults: currentState.questionResults,
      isPaused: true,
      mode: currentState.mode,
    ));
  }

  void _onResumeStudy(ResumeStudy event, Emitter<StudyState> emit) {
    if (state is! StudyInProgress) return;

    final currentState = state as StudyInProgress;
    emit(StudyInProgress(
      shuffledQuestions: currentState.shuffledQuestions,
      multipleChoiceOptions: currentState.multipleChoiceOptions,
      currentIndex: currentState.currentIndex,
      showAnswer: currentState.showAnswer,
      selectedAnswer: currentState.selectedAnswer,
      isAnswerCorrect: currentState.isAnswerCorrect,
      correctAnswers: currentState.correctAnswers,
      questionResults: currentState.questionResults,
      isPaused: false,
      mode: currentState.mode,
    ));
  }

  void _onRestartStudy(RestartStudy event, Emitter<StudyState> emit) {
    if (state is! StudyInProgress) return;

    final currentState = state as StudyInProgress;
    final shuffledQuestions = List<Flashcard>.from(currentState.shuffledQuestions);
    shuffledQuestions.shuffle(Random());

    final multipleChoiceOptions = <String, List<String>>{};
    if (currentState.mode == StudyMode.multipleChoice) {
      final random = Random();
      for (var question in shuffledQuestions) {
        if (question.multipleChoiceOptions != null) {
          List<String> options = List<String>.from(question.multipleChoiceOptions!);
          options.shuffle(random);
          multipleChoiceOptions[question.id] = options;
        } else {
          List<String> allAnswers = currentState.shuffledQuestions
              .map((q) => q.answer)
              .where((answer) => answer != question.answer)
              .toList();
          allAnswers.shuffle(random);
          List<String> options = [question.answer];
          options.addAll(allAnswers.take(3));
          options.shuffle(random);
          multipleChoiceOptions[question.id] = options;
        }
      }
    }

    emit(StudyInProgress(
      shuffledQuestions: shuffledQuestions,
      multipleChoiceOptions: multipleChoiceOptions,
      currentIndex: 0,
      showAnswer: false,
      selectedAnswer: null,
      isAnswerCorrect: null,
      correctAnswers: 0,
      questionResults: {},
      isPaused: false,
      mode: currentState.mode,
    ));
  }
}

