import 'package:flutter/material.dart';
import '../models/flashcard_set.dart';
import '../models/flashcard.dart';
import '../models/category.dart';
import '../data/mock_data.dart'; // Upewnij się, że ścieżka do mock_data jest poprawna

class EditSetScreen extends StatefulWidget {
  final FlashcardSet set;

  const EditSetScreen({Key? key, required this.set}) : super(key: key);

  @override
  _EditSetScreenState createState() => _EditSetScreenState();
}

class _EditSetScreenState extends State<EditSetScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String? _selectedCategoryId;
  
  // Lokalna lista fiszek do edycji (zmiany tutaj nie wpływają na główną listę dopóki nie zapiszemy)
  late List<Flashcard> _flashcards;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.set.title);
    _descController = TextEditingController(text: widget.set.description);
    _selectedCategoryId = widget.set.categoryId;
    // Tworzymy kopię listy fiszek
    _flashcards = List.from(widget.set.flashcards);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj tytuł zestawu')),
      );
      return;
    }

    setState(() {
      // Szukamy oryginalnego zestawu w mockSets i go podmieniamy
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
    });

    // Wracamy do poprzedniego ekranu z informacją o sukcesie (true)
    Navigator.pop(context, true);
  }

  // Dialog dodawania/edycji pojedynczej fiszki
  void _showFlashcardDialog({Flashcard? existingFlashcard, int? index}) {
    final questionController = TextEditingController(text: existingFlashcard?.question ?? '');
    final answerController = TextEditingController(text: existingFlashcard?.answer ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingFlashcard == null ? 'Dodaj fiszkę' : 'Edytuj fiszkę'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Pytanie'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Odpowiedź'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
                setState(() {
                  if (existingFlashcard == null) {
                    // Dodanie nowej
                    _flashcards.add(Flashcard(
                      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generowanie ID
                      question: questionController.text,
                      answer: answerController.text,
                    ));
                  } else if (index != null) {
                    // Aktualizacja istniejącej
                    _flashcards[index] = Flashcard(
                      id: existingFlashcard.id,
                      question: questionController.text,
                      answer: answerController.text,
                    );
                  }
                });
                Navigator.pop(context);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edycja zestawu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          )
        ],
      ),
      body: Column(
        children: [
          // Formularz edycji danych zestawu
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tytuł zestawu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Opis',
                    border: OutlineInputBorder(),
                  ),
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
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
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
          // Lista fiszek
          Expanded(
            child: _flashcards.isEmpty
                ? const Center(child: Text('Brak fiszek w tym zestawie'))
                : ListView.builder(
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
                            onPressed: () => _deleteFlashcard(index),
                          ),
                          onTap: () => _showFlashcardDialog(existingFlashcard: card, index: index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFlashcardDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}