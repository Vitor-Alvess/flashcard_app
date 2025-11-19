class Question {
  String _id;
  String _question;
  String _answer;
  bool _caseSensitive;
  List<String>? _multipleChoiceOptions;

  Question({
    required String id,
    required String question,
    required String answer,
    bool caseSensitive = false,
    List<String>? multipleChoiceOptions,
  }) : _id = id,
       _question = question,
       _answer = answer,
       _caseSensitive = caseSensitive,
       _multipleChoiceOptions = multipleChoiceOptions;

  String get id => _id;
  String get question => _question;
  String get answer => _answer;
  bool get caseSensitive => _caseSensitive;
  List<String>? get multipleChoiceOptions => _multipleChoiceOptions;

  set question(String question) {
    _question = question;
  }

  set answer(String answer) {
    _answer = answer;
  }

  set caseSensitive(bool caseSensitive) {
    _caseSensitive = caseSensitive;
  }

  set multipleChoiceOptions(List<String>? options) {
    _multipleChoiceOptions = options;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'question': _question,
      'answer': _answer,
      'caseSensitive': _caseSensitive,
      'multipleChoiceOptions': _multipleChoiceOptions,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      caseSensitive: json['caseSensitive'] ?? false,
      multipleChoiceOptions: json['multipleChoiceOptions'] != null
          ? List<String>.from(json['multipleChoiceOptions'])
          : null,
    );
  }
}

