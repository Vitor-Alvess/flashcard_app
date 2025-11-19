import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/model/question.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum StudyMode { written, multipleChoice, selfAssessment }

class StudyPage extends StatefulWidget {
  final Collection collection;
  final StudyMode mode;

  const StudyPage({
    super.key,
    required this.collection,
    required this.mode,
  });

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  String? _selectedAnswer;
  final TextEditingController _answerController = TextEditingController();
  List<Question> _shuffledQuestions = [];
  Map<String, List<String>> _multipleChoiceOptions = {};

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List<Question>.from(widget.collection.questions);
    _shuffledQuestions.shuffle(Random());
    _prepareMultipleChoiceOptions();
  }

  void _prepareMultipleChoiceOptions() {
    if (widget.mode == StudyMode.multipleChoice) {
      for (var question in _shuffledQuestions) {
        if (question.multipleChoiceOptions != null) {
          // Use personalized options
          _multipleChoiceOptions[question.id] = List<String>.from(question.multipleChoiceOptions!);
        } else {
          // Mix answers from all questions
          List<String> allAnswers = widget.collection.questions
              .map((q) => q.answer)
              .where((answer) => answer != question.answer)
              .toList();
          allAnswers.shuffle(Random());
          List<String> options = [question.answer];
          options.addAll(allAnswers.take(3));
          options.shuffle(Random());
          _multipleChoiceOptions[question.id] = options;
        }
      }
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _shuffledQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _selectedAnswer = null;
        _answerController.clear();
      });
    } else {
      // Finished
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text("Parabéns!"),
          content: const Text("Você completou todas as perguntas!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close study page
              },
              child: const Text("Fechar"),
            ),
          ],
        );
      },
    );
  }

  void _checkAnswer() {
    if (widget.mode == StudyMode.written) {
      final userAnswer = _answerController.text.trim();
      final correctAnswer = _shuffledQuestions[_currentIndex].answer.trim();
      final isCaseSensitive = _shuffledQuestions[_currentIndex].caseSensitive;

      bool isCorrect = isCaseSensitive
          ? userAnswer == correctAnswer
          : userAnswer.toLowerCase() == correctAnswer.toLowerCase();

      setState(() {
        _showAnswer = true;
        _selectedAnswer = isCorrect ? "correct" : "incorrect";
      });
    } else if (widget.mode == StudyMode.multipleChoice) {
      setState(() {
        _showAnswer = true;
      });
    }
  }

  void _selfAssess(bool correct) {
    // Move to next question
    _nextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (_shuffledQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: Text(widget.collection.name),
          backgroundColor: const Color.fromARGB(221, 90, 90, 90),
        ),
        body: const Center(
          child: Text(
            "Não há perguntas para estudar",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final currentQuestion = _shuffledQuestions[_currentIndex];
    final progress = "${_currentIndex + 1}/${_shuffledQuestions.length}";

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.pause, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.collection.name,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                progress,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
        backgroundColor: const Color.fromARGB(221, 90, 90, 90),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _showAnswer && widget.mode == StudyMode.selfAssessment
                        ? currentQuestion.answer
                        : currentQuestion.question,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (widget.mode == StudyMode.written) _buildWrittenMode(),
            if (widget.mode == StudyMode.multipleChoice) _buildMultipleChoiceMode(currentQuestion),
            if (widget.mode == StudyMode.selfAssessment) _buildSelfAssessmentMode(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWrittenMode() {
    if (_showAnswer) {
      final isCorrect = _selectedAnswer == "correct";
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? "Correto!" : "Incorreto",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green[900] : Colors.red[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Resposta correta: ${_shuffledQuestions[_currentIndex].answer}",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Próxima",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _answerController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Escreva sua resposta...",
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _checkAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Verificar",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceMode(Question question) {
    final options = _multipleChoiceOptions[question.id] ?? [];
    final correctAnswer = question.answer;

    if (_showAnswer) {
      return Column(
        children: [
          ...options.map((option) {
            final isCorrect = option == correctAnswer;
            final isSelected = _selectedAnswer == option;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green[100]
                    : (isSelected && !isCorrect)
                        ? Colors.red[100]
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: null,
                  ),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    Icon(Icons.check_circle, color: Colors.green[900]),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Próxima",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        ...options.map((option) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: RadioListTile<String>(
              value: option,
              groupValue: _selectedAnswer,
              onChanged: (value) {
                setState(() {
                  _selectedAnswer = value;
                });
              },
              title: Text(
                option,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              activeColor: Colors.white,
            ),
          );
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedAnswer != null ? _checkAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Verificar",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelfAssessmentMode() {
    if (_showAnswer) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _selfAssess(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Errei",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _selfAssess(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[300],
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Acertei",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _showAnswer = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Ver resposta",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}

