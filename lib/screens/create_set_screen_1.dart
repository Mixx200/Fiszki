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

  // Funkcja do pokazywania okna dialogowego dodawania kategorii
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
                  // Odśwież listę kategorii w dropdown
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
      // Stwórz tymczasowy zestaw (jeszcze bez fiszek)
      final tempSet = FlashcardSet(
        id: 'temp_id', // Tymczasowe ID
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _selectedCategoryId!,
        flashcards: [], // Pusta lista fiszek
      );

      // Przejdź do kroku 2
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateSetScreen2(draftSet: tempSet),
        ),
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
                decoration: const InputDecoration(labelText: 'Tytuł'),
                validator: (value) => value == null || value.isEmpty ? 'Tytuł jest wymagany' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Kategoria'),
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
                  IconButton(
                    icon: const Icon(Icons.add, size: 30),
                    onPressed: _showAddCategoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Opis'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _goToNextStep,
                child: const Text('Dalej'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}