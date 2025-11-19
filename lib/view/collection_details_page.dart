import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/model/flashcard.dart';
import 'package:flashcard_app/model/user.dart';
import 'package:flashcard_app/view/study_page.dart';
import 'package:flutter/material.dart';

class CollectionDetailsPage extends StatefulWidget {
  final Collection collection;
  final User user;

  const CollectionDetailsPage({
    super.key,
    required this.collection,
    required this.user,
  });

  @override
  State<CollectionDetailsPage> createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends State<CollectionDetailsPage> {
  late Collection _collection;

  @override
  void initState() {
    super.initState();
    _collection = Collection(
      id: widget.collection.id,
      name: widget.collection.name,
      color: widget.collection.color,
      createdAt: widget.collection.createdAt,
      flashcards: List<Flashcard>.from(widget.collection.flashcards),
      imagePath: widget.collection.imagePath,
    );
  }

  void _showAddQuestionDialog() {
    final formKey = GlobalKey<FormState>();
    final TextEditingController questionController = TextEditingController();
    final TextEditingController answerController = TextEditingController();
    bool caseSensitive = false;
    final pageSetState = setState; // Capture the page's setState

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                "Adicionar flashcard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pergunta",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: questionController,
                        decoration: InputDecoration(
                          hintText: "Pergunta",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Pergunta é obrigatória";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Resposta",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: answerController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Resposta",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Resposta é obrigatória";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: caseSensitive,
                            onChanged: (value) {
                              dialogSetState(() {
                                caseSensitive = value ?? false;
                              });
                            },
                          ),
                          const Text("Case sensitive"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newQuestion = Flashcard(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        question: questionController.text,
                        answer: answerController.text,
                        caseSensitive: caseSensitive,
                      );
                      Navigator.of(context).pop();
                      // Update the main page state
                      pageSetState(() {
                        _collection.addQuestion(newQuestion);
                      });
                    }
                  },
                  child: const Text(
                    "Criar novo Flashcard",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStudyModeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Múltipla escolha"),
                onTap: () {
                  Navigator.pop(context);
                  _handleMultipleChoiceMode();
                },
              ),
              ListTile(
                title: Text("Escrita"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyPage(
                        collection: _collection,
                        mode: StudyMode.written,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text("Autoavaliação"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyPage(
                        collection: _collection,
                        mode: StudyMode.selfAssessment,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleMultipleChoiceMode() {
    // Show warning about mixing answers
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text("Múltipla Escolha"),
          content: const Text(
            "Por padrão, as alternativas serão geradas misturando as respostas de todos os flashcards da coleção.\n\nDeseja aceitar este padrão ou personalizar as alternativas para cada pergunta?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showCustomizeOptionsDialog();
              },
              child: const Text("Personalizar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Check if there are at least 4 questions when accepting default
                if (_collection.flashcards.length < 4) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        title: const Text("Aviso"),
                        content: Text(
                          "Para usar o modo de múltipla escolha com alternativas sorteadas, é necessário ter pelo menos 4 perguntas na coleção.\n\nVocê tem ${_collection.flashcards.length} pergunta(s).\n\nDeseja personalizar as alternativas?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showCustomizeOptionsDialog();
                            },
                            child: const Text(
                              "Personalizar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudyPage(
                      collection: _collection,
                      mode: StudyMode.multipleChoice,
                    ),
                  ),
                );
              },
              child: const Text(
                "Aceitar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCustomizeOptionsDialog() {
    int currentQuestionIndex = 0;
    final List<TextEditingController> optionControllers = [];
    final List<Flashcard> questionsToCustomize = List.from(
      _collection.flashcards,
    );

    // Initialize controllers for first question
    void _initializeControllers(int index) {
      optionControllers.clear();
      final question = questionsToCustomize[index];
      if (question.multipleChoiceOptions != null) {
        // Use existing options
        for (var option in question.multipleChoiceOptions!) {
          optionControllers.add(TextEditingController(text: option));
        }
      } else {
        // Initialize with empty options
        for (int i = 0; i < 4; i++) {
          if (i == 0) {
            optionControllers.add(TextEditingController(text: question.answer));
          } else {
            optionControllers.add(TextEditingController());
          }
        }
      }
    }

    _initializeControllers(0);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentQuestion = questionsToCustomize[currentQuestionIndex];
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text(
                "Personalizar Alternativas (${currentQuestionIndex + 1}/${questionsToCustomize.length})",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pergunta: ${currentQuestion.question}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextFormField(
                          controller: optionControllers[index],
                          decoration: InputDecoration(
                            labelText: "Alternativa ${index + 1}",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                if (currentQuestionIndex > 0)
                  TextButton(
                    onPressed: () {
                      // Save current question options
                      final options = optionControllers
                          .map((c) => c.text.trim())
                          .where((text) => text.isNotEmpty)
                          .toList();
                      final correctAnswer =
                          questionsToCustomize[currentQuestionIndex].answer
                              .trim();

                      // Validate: must have at least 2 options and include the correct answer
                      if (options.length >= 2 &&
                          options.any(
                            (opt) =>
                                opt.toLowerCase() ==
                                correctAnswer.toLowerCase(),
                          )) {
                        questionsToCustomize[currentQuestionIndex]
                                .multipleChoiceOptions =
                            options;
                      }
                      setState(() {
                        currentQuestionIndex--;
                        _initializeControllers(currentQuestionIndex);
                      });
                    },
                    child: const Text("Anterior"),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Save current question options
                    final options = optionControllers
                        .map((c) => c.text.trim())
                        .where((text) => text.isNotEmpty)
                        .toList();
                    final correctAnswer =
                        questionsToCustomize[currentQuestionIndex].answer
                            .trim();

                    // Validate: must have at least 2 options and include the correct answer
                    if (options.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "É necessário pelo menos 2 alternativas",
                          ),
                        ),
                      );
                      return;
                    }

                    if (!options.any(
                      (opt) => opt.toLowerCase() == correctAnswer.toLowerCase(),
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "A resposta correta deve estar entre as alternativas",
                          ),
                        ),
                      );
                      return;
                    }

                    questionsToCustomize[currentQuestionIndex]
                            .multipleChoiceOptions =
                        options;

                    if (currentQuestionIndex <
                        questionsToCustomize.length - 1) {
                      setState(() {
                        currentQuestionIndex++;
                        _initializeControllers(currentQuestionIndex);
                      });
                    } else {
                      // Save all and start study
                      this.setState(() {
                        for (int i = 0; i < questionsToCustomize.length; i++) {
                          final index = _collection.flashcards.indexWhere(
                            (q) => q.id == questionsToCustomize[i].id,
                          );
                          if (index != -1) {
                            _collection
                                    .flashcards[index]
                                    .multipleChoiceOptions =
                                questionsToCustomize[i].multipleChoiceOptions;
                          }
                        }
                      });
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudyPage(
                            collection: _collection,
                            mode: StudyMode.multipleChoice,
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    currentQuestionIndex < questionsToCustomize.length - 1
                        ? "Próxima"
                        : "Concluir",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showViewQuestionDialog(Flashcard question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            "Visualizar Flashcard",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pergunta",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    question.question,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Resposta",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(question.answer, style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "Case sensitive: ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      question.caseSensitive ? "Sim" : "Não",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Fechar"),
            ),
          ],
        );
      },
    );
  }

  void _showEditQuestionDialog(Flashcard question) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController questionController = TextEditingController(
      text: question.question,
    );
    final TextEditingController answerController = TextEditingController(
      text: question.answer,
    );
    bool caseSensitive = question.caseSensitive;
    final pageSetState = setState; // Capture the page's setState

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: const Text(
                "Editar flashcard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pergunta",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: questionController,
                        decoration: InputDecoration(
                          hintText: "Pergunta",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Pergunta é obrigatória";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Resposta",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: answerController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Resposta",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Resposta é obrigatória";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: caseSensitive,
                            onChanged: (value) {
                              dialogSetState(() {
                                caseSensitive = value ?? false;
                              });
                            },
                          ),
                          const Text("Case sensitive"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(context).pop();
                      // Update the question
                      pageSetState(() {
                        final index = _collection.flashcards.indexWhere(
                          (q) => q.id == question.id,
                        );
                        if (index != -1) {
                          _collection.flashcards[index].question =
                              questionController.text;
                          _collection.flashcards[index].answer =
                              answerController.text;
                          _collection.flashcards[index].caseSensitive =
                              caseSensitive;
                        }
                      });
                    }
                  },
                  child: const Text(
                    "Salvar alterações",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteQuestionDialog(Flashcard question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: const Text(
            "Excluir Flashcard",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Tem certeza que deseja excluir esta pergunta?\n\n\"${question.question}\"",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _collection.removeQuestion(question.id);
                });
              },
              child: const Text(
                "Excluir",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showQuestionMenu(BuildContext context, Flashcard question) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility),
                title: Text("Visualizar"),
                onTap: () {
                  Navigator.pop(context);
                  _showViewQuestionDialog(question);
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Editar"),
                onTap: () {
                  Navigator.pop(context);
                  _showEditQuestionDialog(question);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Excluir", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteQuestionDialog(question);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Proteção de autenticação - se não estiver logado, mostrar mensagem
    if (!widget.user.isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Acesso Negado",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(221, 90, 90, 90),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey[600]),
              const SizedBox(height: 24),
              Text(
                "Você precisa estar logado para acessar esta coleção",
                style: TextStyle(color: Colors.white70, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(_collection),
        ),
        title: Text(
          _collection.name,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(221, 90, 90, 90),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: const Color.fromARGB(221, 90, 90, 90),
                child: Text(
                  "Perguntas: ${_collection.flashcards.length}",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Expanded(
                child: _collection.flashcards.isEmpty
                    ? Center(
                        child: Text(
                          "Nenhuma pergunta ainda...",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _collection.flashcards.length,
                        itemBuilder: (context, index) {
                          final question = _collection.flashcards[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                question.question,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                ),
                                onPressed: () =>
                                    _showQuestionMenu(context, question),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              heroTag: "add_question_fab",
              onPressed: _showAddQuestionDialog,
              backgroundColor: Colors.white,
              child: Icon(Icons.add, color: Colors.black),
              shape: CircleBorder(
                side: BorderSide(color: Colors.black, width: 1),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: "study_mode_fab",
              onPressed: _showStudyModeDialog,
              backgroundColor: Colors.white,
              child: Icon(Icons.play_arrow, color: Colors.black),
              shape: CircleBorder(
                side: BorderSide(color: Colors.black, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
