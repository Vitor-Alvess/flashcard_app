import 'package:flutter/material.dart';
import 'package:flashcard_app/model/question.dart';

class Collection {
  String _id;
  String _name;
  Color _color;
  DateTime _createdAt;
  List<Question> _questions;
  String? _imagePath;

  Collection({
    required String id,
    required String name,
    required Color color,
    DateTime? createdAt,
    List<Question>? questions,
    String? imagePath,
  }) : _id = id,
       _name = name,
       _color = color,
       _createdAt = createdAt ?? DateTime.now(),
       _questions = questions ?? [],
       _imagePath = imagePath;

  String get id => _id;
  String get name => _name;
  Color get color => _color;
  DateTime get createdAt => _createdAt;
  List<Question> get questions => _questions;
  int get flashcardCount => _questions.length;
  String? get imagePath => _imagePath;

  set name(String name) {
    _name = name;
  }

  set color(Color color) {
    _color = color;
  }

  set imagePath(String? path) {
    _imagePath = path;
  }

  void addQuestion(Question question) {
    _questions.add(question);
  }

  void removeQuestion(String questionId) {
    _questions.removeWhere((q) => q.id == questionId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'color': _color.value,
      'createdAt': _createdAt.toIso8601String(),
      'questions': _questions.map((q) => q.toJson()).toList(),
      'imagePath': _imagePath,
    };
  }

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      createdAt: DateTime.parse(json['createdAt']),
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
      imagePath: json['imagePath'],
    );
  }
}
