import 'package:flashcard_app/model/collection.dart';
import 'package:flutter/material.dart';

class CreateCollectionDialog extends StatefulWidget {
  final Function(Collection) onCreate;

  const CreateCollectionDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  bool _showColorPicker = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createCollection() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final collection = Collection(
      id: tempId,
      name: name,
      color: _selectedColor,
      flashcards: [], // Coleção vazia - flashcards serão adicionados depois
      imagePath: null,
    );

    Navigator.of(context).pop();
    widget.onCreate(collection);
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image placeholder
              GestureDetector(
                onTap: () => setState(() => _showColorPicker = !_showColorPicker),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: _selectedColor.computeLuminance() > 0.5
                              ? Colors.black54
                              : Colors.white70,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _showColorPicker = !_showColorPicker),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.orange,
                                  Colors.yellow,
                                  Colors.green,
                                  Colors.blue,
                                  Colors.indigo,
                                  Colors.purple,
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.palette,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showColorPicker) ...[
                const SizedBox(height: 12),
                _buildColorPicker(),
              ],
              const SizedBox(height: 16),
              // Name field
              const Text(
                'Nome',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nome do seu Grupo',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Create button
              ElevatedButton(
                onPressed: _createCollection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Criar novo Grupo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

