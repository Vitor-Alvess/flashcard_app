import 'package:flutter/material.dart';
import 'package:flashcard_app/model/collection.dart';
import 'package:flashcard_app/model/flashcard.dart';
import 'package:flashcard_app/provider/firestore_collection_provider.dart';

class CreateCollectionPage extends StatefulWidget {
  const CreateCollectionPage({super.key});

  @override
  State<CreateCollectionPage> createState() => _CreateCollectionPageState();
}

class _CreateCollectionPageState extends State<CreateCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  Color _selectedColor = Colors.blue;
  bool _showColorPicker = false;
  bool _isSaving = false;

  // Each entry holds a pair of controllers for question and answer
  final List<Map<String, TextEditingController>> _cardsControllers = [];

  @override
  void initState() {
    super.initState();
    // start with one empty card
    _addCard();
  }

  void _addCard() {
    setState(() {
      _cardsControllers.add({
        'q': TextEditingController(),
        'a': TextEditingController(),
      });
    });
  }

  void _removeCard(int index) {
    setState(() {
      _cardsControllers[index]['q']!.dispose();
      _cardsControllers[index]['a']!.dispose();
      _cardsControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _cardsControllers) {
      c['q']?.dispose();
      c['a']?.dispose();
    }
    super.dispose();
  }

  Future<void> _saveCollection() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();

    final flashcards = <Flashcard>[];
    for (final c in _cardsControllers) {
      final q = c['q']!.text.trim();
      final a = c['a']!.text.trim();
      if (q.isNotEmpty || a.isNotEmpty) {
        flashcards.add(Flashcard(question: q, answer: a));
      }
    }

    if (flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adicione pelo menos um flashcard com pergunta e/ou resposta.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final collection = Collection(
        id: tempId,
        name: title,
        color: _selectedColor,
        flashcards: flashcards,
        flashcardCount: flashcards.length,
      );

      final newId = await FirestoreCollectionProvider.helper.insertCollection(
        collection,
      );

      final created = Collection(
        id: newId,
        name: collection.name,
        color: collection.color,
        flashcards: collection.flashcards,
        flashcardCount: collection.flashcardCount,
        createdAt: DateTime.now(),
      );

      Navigator.of(context).pop(created);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildColorPicker() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.grey[300]!,
      Colors.grey[500]!,
      Colors.grey[700]!,
      Colors.brown,
      Colors.lime,
      Colors.deepPurple,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final selected = _selectedColor.value == color.value;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
              _showColorPicker = false;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? Colors.black : Colors.grey[300]!,
                width: selected ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Coleção'),
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : TextButton(
                    onPressed: _saveCollection,
                    child: const Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Color preview / picker toggle
                GestureDetector(
                  onTap: () =>
                      setState(() => _showColorPicker = !_showColorPicker),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Toque para escolher cor',
                        style: TextStyle(
                          color: _selectedColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (_showColorPicker) _buildColorPicker(),
                const SizedBox(height: 12),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título da coleção',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Título é obrigatório';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Flashcards list
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Flashcards',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addCard,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _cardsControllers.isEmpty
                            ? const Center(child: Text('Nenhum flashcard'))
                            : ListView.builder(
                                itemCount: _cardsControllers.length,
                                itemBuilder: (context, index) {
                                  final controllers = _cardsControllers[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: controllers['q'],
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'Pergunta',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                  validator: (v) {
                                                    // allow empty per-row, will be filtered on save
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                onPressed: () =>
                                                    _removeCard(index),
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            controller: controllers['a'],
                                            decoration: const InputDecoration(
                                              labelText: 'Resposta',
                                              border: OutlineInputBorder(),
                                            ),
                                            maxLines: null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveCollection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Criar Coleção',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
