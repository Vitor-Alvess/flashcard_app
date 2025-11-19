import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/model/question.dart';
import 'package:flutter/material.dart';

class CollectionDetailsPage extends StatefulWidget {
  final Collection collection;

  const CollectionDetailsPage({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionDetailsPage> createState() => _CollectionDetailsPageState();
}

class _CollectionDetailsPageState extends State<CollectionDetailsPage> {
  late Collection _collection;

  @override
  void initState() {
    super.initState();
    // Create a new instance to avoid reference issues
    _collection = Collection(
      id: widget.collection.id,
      name: widget.collection.name,
      color: widget.collection.color,
      createdAt: widget.collection.createdAt,
      questions: List<Question>.from(widget.collection.questions),
    );
  }

  void _showAddQuestionDialog() {
    final formKey = GlobalKey<FormState>();
    final TextEditingController questionController = TextEditingController();
    final TextEditingController answerController = TextEditingController();
    bool caseSensitive = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                              setState(() {
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
                      final newQuestion = Question(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        question: questionController.text,
                        answer: answerController.text,
                        caseSensitive: caseSensitive,
                      );
                      setState(() {
                        _collection.addQuestion(newQuestion);
                      });
                      Navigator.of(context).pop();
                      this.setState(() {});
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

  void _showQuestionMenu(BuildContext context, Question question) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility),
                title: Text("Visualizar"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement view question
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Editar"),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit question
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Excluir", style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    _collection.removeQuestion(question.id);
                  });
                  Navigator.pop(context);
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color.fromARGB(221, 90, 90, 90),
                child: Text(
                  "Perguntas: ${_collection.questions.length}",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              Expanded(
                child: _collection.questions.isEmpty
                    ? Center(
                        child: Text(
                          "Nenhuma pergunta ainda...",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _collection.questions.length,
                        itemBuilder: (context, index) {
                          final question = _collection.questions[index];
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
                                icon: Icon(Icons.more_vert, color: Colors.black),
                                onPressed: () => _showQuestionMenu(context, question),
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
              onPressed: () {
                // TODO: Implement create action
              },
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
              onPressed: () {
                // TODO: Implement start action
              },
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

