import 'package:flutter/material.dart';
import '../models/flashcard_set.dart';
import '../models/flashcard.dart';
import '../models/category.dart';
import '../data/mock_data.dart';

class EditSetScreen extends StatefulWidget {
  final FlashcardSet set;

  const EditSetScreen({Key? key, required this.set}) : super(key: key);

  @override
  _EditSetScreenState createState() => _EditSetScreenState();
}

class _EditSetScreenState extends State<EditSetScreen> {
  // Klucz do walidacji głównego formularza (Tytuł, Opis, Kategoria)
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String? _selectedCategoryId;
  late List<Flashcard> _flashcards;
  bool _changesMade = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.set.title);
    _descController = TextEditingController(text: widget.set.description);
    _selectedCategoryId = widget.set.categoryId;
    _flashcards = List.from(widget.set.flashcards);
    
    _titleController.addListener(_markChangesMade);
    _descController.addListener(_markChangesMade);
  }

  void _markChangesMade() {
    if (!_changesMade) {
      setState(() {
        _changesMade = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_markChangesMade);
    _descController.removeListener(_markChangesMade);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<bool> _showDiscardChangesDialog() async {
    if (!_changesMade) return true;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potwierdzenie'),
          content: const Text('Czy na pewno chcesz odrzucić zmiany?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Odrzuć', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _saveChanges() {
    // Uruchomienie walidacji pól
    if (_formKey.currentState!.validate()) {
      setState(() {
        int index = mockSets.indexWhere((s) => s.id == widget.set.id);

        if (index != -1) {
          mockSets[index] = FlashcardSet(
            id: widget.set.id,
            title: _titleController.text,
            description: _descController.text,
            categoryId: _selectedCategoryId ?? 'c3',
            flashcards: _flashcards,
            ownerId: widget.set.ownerId,
          );
        }
        _changesMade = false;
      });

      Navigator.pop(context, true);
    } else {
      // Opcjonalny komunikat, gdy pola są puste
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wypełnij wymagane pola')),
      );
    }
  }

  void _showFlashcardDialog({Flashcard? existingFlashcard, int? index}) {
    final questionController = TextEditingController(text: existingFlashcard?.question ?? '');
    final answerController = TextEditingController(text: existingFlashcard?.answer ?? '');
    final _dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(existingFlashcard == null ? 'Dodaj fiszkę' : 'Edytuj fiszkę'),
        content: Form(
          key: _dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Pytanie'),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Wpisz pytanie' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Odpowiedź'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Wpisz odpowiedź' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_dialogFormKey.currentState!.validate()) {
                String? message;

                setState(() {
                  if (existingFlashcard == null) {
                    _flashcards.add(Flashcard(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      question: questionController.text,
                      answer: answerController.text,
                    ));
                    message = 'Fiszka dodana pomyślnie';
                  } else if (index != null) {
                    _flashcards[index] = Flashcard(
                      id: existingFlashcard.id,
                      question: questionController.text,
                      answer: answerController.text,
                    );
                    message = 'Fiszka zaktualizowana pomyślnie';
                  }
                  _changesMade = true;
                });

                Navigator.pop(dialogContext);
                
                if (message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message!),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }

  void _deleteFlashcard(int index) {
    setState(() {
      _flashcards.removeAt(index);
      _changesMade = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fiszka usunięta'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteFlashcard(int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Potwierdzenie usunięcia'),
        content: const Text(
            'Czy chcesz usunąć tę fiszkę? Te zmiany nie mogą zostać cofnięte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteFlashcard(index);
            },
            child: const Text('Usuń', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showDiscardChangesDialog,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edycja zestawu'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tytuł zestawu',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'To pole jest wymagane';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Opis',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'To pole jest wymagane';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Kategoria',
                        border: OutlineInputBorder(),
                      ),
                      items: mockCategories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                          _changesMade = true;
                        });
                      },
                      validator: (value) => value == null ? 'Wybierz kategorię' : null,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 0.0, left: 16.0, right: 16.0),
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj nową fiszkę'),
                  onPressed: () => _showFlashcardDialog(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fiszki (${_flashcards.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _flashcards.length,
                  itemBuilder: (context, index) {
                    final card = _flashcards[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: ListTile(
                        title: Text(card.question, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(card.answer, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteFlashcard(index),
                        ),
                        onTap: () => _showFlashcardDialog(existingFlashcard: card, index: index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
