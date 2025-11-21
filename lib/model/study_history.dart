import 'package:flashcard_app/bloc/study_bloc.dart';

class StudyHistory {
  String _id;
  String _collectionId;
  String _collectionName;
  StudyMode _mode;
  int _correctAnswers;
  int _totalQuestions;
  int _percentage;
  DateTime _completedAt;
  String? _userId;
  Map<String, bool> _questionResults;

  StudyHistory({
    required String id,
    required String collectionId,
    required String collectionName,
    required StudyMode mode,
    required int correctAnswers,
    required int totalQuestions,
    required int percentage,
    required DateTime completedAt,
    String? userId,
    Map<String, bool>? questionResults,
  })  : _id = id,
        _collectionId = collectionId,
        _collectionName = collectionName,
        _mode = mode,
        _correctAnswers = correctAnswers,
        _totalQuestions = totalQuestions,
        _percentage = percentage,
        _completedAt = completedAt,
        _userId = userId,
        _questionResults = questionResults ?? {};

  String get id => _id;
  String get collectionId => _collectionId;
  String get collectionName => _collectionName;
  StudyMode get mode => _mode;
  int get correctAnswers => _correctAnswers;
  int get totalQuestions => _totalQuestions;
  int get percentage => _percentage;
  DateTime get completedAt => _completedAt;
  String? get userId => _userId;
  Map<String, bool> get questionResults => _questionResults;

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'collectionId': _collectionId,
      'collectionName': _collectionName,
      'mode': _mode.toString().split('.').last,
      'correctAnswers': _correctAnswers,
      'totalQuestions': _totalQuestions,
      'percentage': _percentage,
      'completedAt': _completedAt.toIso8601String(),
      'userId': _userId,
      'questionResults': _questionResults,
    };
  }

  factory StudyHistory.fromMap(Map<String, dynamic> map) {
    StudyMode mode;
    switch (map['mode']) {
      case 'written':
        mode = StudyMode.written;
        break;
      case 'multipleChoice':
        mode = StudyMode.multipleChoice;
        break;
      case 'selfAssessment':
        mode = StudyMode.selfAssessment;
        break;
      default:
        mode = StudyMode.written;
    }

    Map<String, bool> questionResults = {};
    if (map['questionResults'] != null) {
      final results = map['questionResults'] as Map;
      questionResults = results.map((key, value) => MapEntry(key.toString(), value as bool));
    }

    return StudyHistory(
      id: map['id'] ?? '',
      collectionId: map['collectionId'] ?? '',
      collectionName: map['collectionName'] ?? '',
      mode: mode,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      percentage: map['percentage'] ?? 0,
      completedAt: DateTime.parse(map['completedAt']),
      userId: map['userId'],
      questionResults: questionResults,
    );
  }
}

