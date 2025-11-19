class Question {
  String _id;
  String _question;
  String _answer;
  bool _caseSensitive;

  Question({
    required String id,
    required String question,
    required String answer,
    bool caseSensitive = false,
  }) : _id = id,
       _question = question,
       _answer = answer,
       _caseSensitive = caseSensitive;

  String get id => _id;
  String get question => _question;
  String get answer => _answer;
  bool get caseSensitive => _caseSensitive;

  set question(String question) {
    _question = question;
  }

  set answer(String answer) {
    _answer = answer;
  }

  set caseSensitive(bool caseSensitive) {
    _caseSensitive = caseSensitive;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'question': _question,
      'answer': _answer,
      'caseSensitive': _caseSensitive,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      caseSensitive: json['caseSensitive'] ?? false,
    );
  }
}

