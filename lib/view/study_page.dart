import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/model/question.dart';
import 'package:flashcard_app/view/results_page.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum StudyMode { written, multipleChoice, selfAssessment }

class StudyPage extends StatefulWidget {
  final Collection collection;
  final StudyMode mode;

  const StudyPage({super.key, required this.collection, required this.mode});

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
  int _correctAnswers = 0;
  Map<String, bool> _questionResults =
      {}; // Track if each question was answered correctly

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
          _multipleChoiceOptions[question.id] = List<String>.from(
            question.multipleChoiceOptions!,
          );
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
      // Finished - show results
      _showResults();
    }
  }

  void _selfAssess(bool correct) {
    final currentQuestion = _shuffledQuestions[_currentIndex];
    // Track result
    if (!_questionResults.containsKey(currentQuestion.id)) {
      _questionResults[currentQuestion.id] = correct;
      if (correct) {
        _correctAnswers++;
      }
    }
    // Move to next question
    _nextQuestion();
  }

  void _showResults() {
    final totalQuestions = _shuffledQuestions.length;
    final percentage = totalQuestions > 0
        ? (_correctAnswers / totalQuestions * 100).round()
        : 0;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          correctAnswers: _correctAnswers,
          totalQuestions: totalQuestions,
          percentage: percentage,
        ),
      ),
    );
  }

  void _checkAnswer() {
    final currentQuestion = _shuffledQuestions[_currentIndex];
    bool isCorrect = false;

    if (widget.mode == StudyMode.written) {
      final userAnswer = _answerController.text.trim();
      final correctAnswer = currentQuestion.answer.trim();
      final isCaseSensitive = currentQuestion.caseSensitive;

      isCorrect = isCaseSensitive
          ? userAnswer == correctAnswer
          : userAnswer.toLowerCase() == correctAnswer.toLowerCase();

      setState(() {
        _showAnswer = true;
        _selectedAnswer = isCorrect ? "correct" : "incorrect";
      });
    } else if (widget.mode == StudyMode.multipleChoice) {
      isCorrect = _selectedAnswer == currentQuestion.answer;
      setState(() {
        _showAnswer = true;
      });
    }

    // Track result
    if (!_questionResults.containsKey(currentQuestion.id)) {
      _questionResults[currentQuestion.id] = isCorrect;
      if (isCorrect) {
        _correctAnswers++;
      }
    }
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
            if (widget.mode == StudyMode.multipleChoice)
              _buildMultipleChoiceMode(currentQuestion),
            if (widget.mode == StudyMode.selfAssessment)
              _buildSelfAssessmentMode(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWrittenMode() {
    final isCorrect = _selectedAnswer == "correct";
    
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 80,
          ),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _showAnswer
                ? (isCorrect ? Colors.green[100] : Colors.red[100])
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: _showAnswer
              ? Column(
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
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                )
              : TextField(
                  controller: _answerController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Escreva sua resposta...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            key: ValueKey(_showAnswer),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAnswer ? _nextQuestion : _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _showAnswer ? "Próxima" : "Verificar",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceMode(Question question) {
    final options = _multipleChoiceOptions[question.id] ?? [];
    final correctAnswer = question.answer;

    return Column(
      children: [
        ...options.map((option) {
          final isCorrect = option == correctAnswer;
          final isSelected = _selectedAnswer == option;
          
          return GestureDetector(
            onTap: _showAnswer
                ? null
                : () {
                    setState(() {
                      _selectedAnswer = option;
                    });
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: 60,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: _showAnswer
                    ? (isCorrect
                        ? Colors.green[100]
                        : (isSelected && !isCorrect)
                            ? Colors.red[100]
                            : Colors.grey[200])
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showAnswer && isCorrect
                      ? Colors.green
                      : Colors.transparent,
                  width: _showAnswer && isCorrect ? 2 : 0,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Radio<String>(
                      value: option,
                      groupValue: _selectedAnswer,
                      onChanged: _showAnswer ? null : (value) {
                        setState(() {
                          _selectedAnswer = value;
                        });
                      },
                      activeColor: _showAnswer
                          ? (isCorrect ? Colors.green : Colors.grey)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: _showAnswer ? Colors.black : Colors.white,
                        fontSize: 16,
                        fontWeight: _showAnswer && isCorrect
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (_showAnswer && isCorrect)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[900],
                        size: 24,
                      ),
                    ),
                  if (!_showAnswer && isSelected)
                    const SizedBox(width: 32), // Reserve space for icon
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            key: ValueKey(_showAnswer),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showAnswer
                  ? _nextQuestion
                  : (_selectedAnswer != null ? _checkAnswer : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _showAnswer ? "Próxima" : "Verificar",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelfAssessmentMode() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showAnswer
          ? Row(
              key: const ValueKey('assessment'),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              key: const ValueKey('show_answer'),
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
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
