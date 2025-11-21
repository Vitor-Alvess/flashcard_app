import 'package:flashcard_app/model/flashcard.dart';
import 'package:flutter/material.dart';

class Collection {
  String _id;
  String _name;
  Color _color;
  DateTime _createdAt;
  int _flashcardCount;
  List<Flashcard> _flashcards;
  String? _imagePath;
  String? _userId;

  Collection({
    required String id,
    required String name,
    required Color color,
    DateTime? createdAt,
    int flashcardCount = 0,
    required List<Flashcard> flashcards,
    required String? imagePath,
    String? userId,
  }) : _id = id,
       _name = name,
       _color = color,
       _createdAt = createdAt ?? DateTime.now(),
       _flashcardCount = flashcardCount,
       _flashcards = flashcards,
       _imagePath = imagePath,
       _userId = userId;

  String get id => _id;
  String get name => _name;
  Color get color => _color;
  DateTime get createdAt => _createdAt;
  List<Flashcard> get flashcards => _flashcards;
  int get flashcardCount => _flashcards.length;
  String? get imagePath => _imagePath;
  String? get userId => _userId;

  set name(String name) {
    _name = name;
  }

  set color(Color color) {
    _color = color;
  }

  set imagePath(String? path) {
    _imagePath = path;
  }

  set userId(String? userId) {
    _userId = userId;
  }

  void addQuestion(Flashcard question) {
    _flashcards.add(question);
  }

  void removeQuestion(String questionId) {
    _flashcards.removeWhere((q) => q.id == questionId);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'color': _color.toARGB32(),
      'createdAt': _createdAt.toIso8601String(),
      'flashcards': _flashcards.map((f) => f.toJson()).toList(),
      'imagePath': _imagePath != null && _imagePath!.isNotEmpty
          ? _imagePath
          : null,
      'userId': _userId,
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
      createdAt: DateTime.parse(map['createdAt']),
      flashcards:
          (map['flashcards'] as List<dynamic>?)
              ?.map((q) => Flashcard.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      imagePath: map['imagePath'],
      userId: map['userId'],
    );
  }
}
