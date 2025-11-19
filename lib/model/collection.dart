import 'package:flashcard_app/model/flashcard.dart';
import 'package:flutter/material.dart';

class Collection {
  String _id;
  String _name;
  Color _color;
  DateTime _createdAt;
  int _flashcardCount;
  List<Flashcard> _flashcards;

  Collection({
    required String id,
    required String name,
    required Color color,
    DateTime? createdAt,
    int flashcardCount = 0,
    required List<Flashcard> flashcards,
  }) : _id = id,
       _name = name,
       _color = color,
       _createdAt = createdAt ?? DateTime.now(),
       _flashcardCount = flashcardCount,
       _flashcards = flashcards;

  String get id => _id;
  String get name => _name;
  Color get color => _color;
  DateTime get createdAt => _createdAt;
  int get flashcardCount => _flashcardCount;
  List<Flashcard> get flashcards => _flashcards;

  set name(String name) {
    _name = name;
  }

  set color(Color color) {
    _color = color;
  }

  set flashcardCount(int count) {
    _flashcardCount = count;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'color': _color.toARGB32(),
      'createdAt': _createdAt.toIso8601String(),
      'flashcardCount': _flashcardCount,
      'flashcards': _flashcards
          .map((f) => {'question': f.question, 'answer': f.answer})
          .toList(),
    };
  }

  factory Collection.fromMap(Map<String, dynamic> map) {
    final rawFlashcards = map['flashcards'];
    List<Flashcard> parsedFlashcards = [];

    if (rawFlashcards is List) {
      for (final item in rawFlashcards) {
        if (item is Map<String, dynamic>) {
          parsedFlashcards.add(
            Flashcard(
              question: item['question'] ?? '',
              answer: item['answer'] ?? '',
            ),
          );
        } else if (item is Map) {
          parsedFlashcards.add(
            Flashcard(
              question: item['question'] ?? '',
              answer: item['answer'] ?? '',
            ),
          );
        }
      }
    }

    return Collection(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      flashcardCount: map['flashcardCount'] ?? 0,
      flashcards: parsedFlashcards,
    );
  }
}
