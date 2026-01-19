import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/category.dart';
import '../models/flashcard_set.dart';
import 'create_set_screen_2.dart';

class CreateSetScreen1 extends StatefulWidget {
  final Function(String) onCategoryAdded;
  const CreateSetScreen1({Key? key, required this.onCategoryAdded}) : super(key: key);

  @override
  _CreateSetScreen1State createState() => _CreateSetScreen1State();
}

class _CreateSetScreen1State extends State<CreateSetScreen1> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;

  void _showAddCategoryDialog() {
    final _categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nowa kategoria'),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(labelText: 'Nazwa kategorii'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Dodaj'),
              onPressed: () {
                if (_categoryNameController.text.isNotEmpty) {
                  widget.onCategoryAdded(_categoryNameController.text);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      final tempSet = FlashcardSet(
        id: 'temp_id',
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategoryId!,
        flashcards: [],
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateSetScreen2(draftSet: tempSet),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wypełnij wymagane pola (Tytuł i Kategoria)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowy zestaw')), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tytuł *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Tytuł jest wymagany' : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kategoria *',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedCategoryId,
                      items: mockCategories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) => value == null ? 'Wybierz kategorię' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_box, size: 40, color: Colors.blue),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Opis (opcjonalnie)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                onPressed: _goToNextStep,
                child: const Text('Dalej', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
