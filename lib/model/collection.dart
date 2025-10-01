import 'package:flutter/material.dart';

class Collection {
  String _id;
  String _name;
  Color _color;
  DateTime _createdAt;
  int _flashcardCount;

  Collection({
    required String id,
    required String name,
    required Color color,
    DateTime? createdAt,
    int flashcardCount = 0,
  }) : _id = id,
       _name = name,
       _color = color,
       _createdAt = createdAt ?? DateTime.now(),
       _flashcardCount = flashcardCount;

  String get id => _id;
  String get name => _name;
  Color get color => _color;
  DateTime get createdAt => _createdAt;
  int get flashcardCount => _flashcardCount;

  set name(String name) {
    _name = name;
  }

  set color(Color color) {
    _color = color;
  }

  set flashcardCount(int count) {
    _flashcardCount = count;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'color': _color.value,
      'createdAt': _createdAt.toIso8601String(),
      'flashcardCount': _flashcardCount,
    };
  }

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      createdAt: DateTime.parse(json['createdAt']),
      flashcardCount: json['flashcardCount'] ?? 0,
    );
  }
}
