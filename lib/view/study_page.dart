import 'package:flashcard_app/bloc/auth_bloc.dart';
import 'package:flashcard_app/bloc/history_bloc.dart';
import 'package:flashcard_app/bloc/study_bloc.dart';
import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/model/study_history.dart';
import 'package:flashcard_app/view/results_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudyPage extends StatefulWidget {
  final Collection collection;
  final StudyMode mode;

  const StudyPage({super.key, required this.collection, required this.mode});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<StudyBloc>().add(
          InitializeStudy(
            collection: widget.collection,
            mode: widget.mode,
          ),
        );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StudyBloc, StudyState>(
          listener: (context, state) {
            if (state is StudyCompleted) {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                final history = StudyHistory(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  collectionId: widget.collection.id,
                  collectionName: widget.collection.name,
                  mode: widget.mode,
                  correctAnswers: state.correctAnswers,
                  totalQuestions: state.totalQuestions,
                  percentage: state.percentage,
                  completedAt: DateTime.now(),
                  userId: authState.username,
                  questionResults: state.questionResults,
                );
                context.read<HistoryBloc>().add(AddHistory(history: history));
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultsPage(
                    correctAnswers: state.correctAnswers,
                    totalQuestions: state.totalQuestions,
                    percentage: state.percentage,
                  ),
                ),
              );
            } else if (state is StudyInProgress && !state.showAnswer) {
              _answerController.clear();
            }
          },
        ),
      ],
      child: BlocBuilder<StudyBloc, StudyState>(
        builder: (context, state) {
          if (state is StudyInitial) {
            return Scaffold(
              backgroundColor: Colors.black87,
              appBar: AppBar(
                title: Text(widget.collection.name),
                backgroundColor: const Color.fromARGB(221, 90, 90, 90),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is StudyInProgress) {
            if (state.shuffledQuestions.isEmpty) {
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

            final currentQuestion = state.currentQuestion;
            final progress = state.progress;

            return Scaffold(
              backgroundColor: Colors.black87,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  onPressed: () {
                    context.read<StudyBloc>().add(PauseStudy());
                  },
                ),
                title: Text(
                  widget.collection.name,
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: Text(
                        progress,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
                backgroundColor: const Color.fromARGB(221, 90, 90, 90),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Stack(
                children: [
                  Opacity(
                    opacity: state.isPaused ? 0.3 : 1.0,
                    child: Padding(
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
                                  state.showAnswer && state.mode == StudyMode.selfAssessment
                                      ? currentQuestion.answer
                                      : currentQuestion.question,
                                  style: const TextStyle(
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
                          if (state.mode == StudyMode.written)
                            _buildWrittenMode(state),
                          if (state.mode == StudyMode.multipleChoice)
                            _buildMultipleChoiceMode(state, currentQuestion),
                          if (state.mode == StudyMode.selfAssessment)
                            _buildSelfAssessmentMode(state),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  if (state.isPaused) _buildPauseModal(),
                ],
              ),
            );
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildWrittenMode(StudyInProgress state) {
    final isCorrect = state.isAnswerCorrect == true;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: state.showAnswer
                ? (isCorrect ? Colors.green[100] : Colors.red[100])
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: state.showAnswer
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
                      "Resposta correta: ${state.currentQuestion.answer}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
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
            key: ValueKey(state.showAnswer),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.showAnswer
                  ? () => context.read<StudyBloc>().add(NextQuestion())
                  : () => context.read<StudyBloc>().add(
                        CheckAnswer(userAnswer: _answerController.text),
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                state.showAnswer ? "Próxima" : "Verificar",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceMode(StudyInProgress state, currentQuestion) {
    final options = state.multipleChoiceOptions[currentQuestion.id] ?? [];
    final correctAnswer = currentQuestion.answer;

    return Column(
      children: [
        ...options.map((option) {
          final isCorrect = option == correctAnswer;
          final isSelected = state.selectedAnswer == option;

          return GestureDetector(
            onTap: state.showAnswer
                ? null
                : () {
                    context.read<StudyBloc>().add(
                          CheckAnswer(selectedAnswer: option),
                        );
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 12),
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: state.showAnswer
                    ? (isCorrect
                          ? Colors.green[100]
                          : (isSelected && !isCorrect)
                          ? Colors.red[100]
                          : Colors.grey[200])
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.showAnswer && isCorrect
                      ? Colors.green
                      : Colors.transparent,
                  width: state.showAnswer && isCorrect ? 2 : 0,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Radio<String>(
                      value: option,
                      groupValue: state.selectedAnswer,
                      onChanged: state.showAnswer
                          ? null
                          : (value) {
                              context.read<StudyBloc>().add(
                                    CheckAnswer(selectedAnswer: value),
                                  );
                            },
                      activeColor: state.showAnswer
                          ? (isCorrect ? Colors.green : Colors.grey)
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: state.showAnswer ? Colors.black : Colors.white,
                        fontSize: 16,
                        fontWeight: state.showAnswer && isCorrect
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (state.showAnswer && isCorrect)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[900],
                        size: 24,
                      ),
                    ),
                  if (!state.showAnswer && isSelected)
                    const SizedBox(width: 32),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: SizedBox(
            key: ValueKey(state.showAnswer),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.showAnswer
                  ? () => context.read<StudyBloc>().add(NextQuestion())
                  : (state.selectedAnswer != null
                      ? () => context.read<StudyBloc>().add(
                            CheckAnswer(selectedAnswer: state.selectedAnswer),
                          )
                      : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                state.showAnswer ? "Próxima" : "Verificar",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelfAssessmentMode(StudyInProgress state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: state.showAnswer
          ? Row(
              key: const ValueKey('assessment'),
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.read<StudyBloc>().add(
                          SelfAssess(correct: false),
                        ),
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
                    onPressed: () => context.read<StudyBloc>().add(
                          SelfAssess(correct: true),
                        ),
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
                  context.read<StudyBloc>().add(ShowAnswer());
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

  Widget _buildPauseModal() {
    return BlocBuilder<StudyBloc, StudyState>(
      builder: (context, state) {
        if (state is! StudyInProgress) return const SizedBox.shrink();

        return Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Pausado",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<StudyBloc>().add(ResumeStudy());
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text(
                        "Continuar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<StudyBloc>().add(RestartStudy());
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        "Reiniciar",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                      label: const Text(
                        "Sair",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
