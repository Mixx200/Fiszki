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
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String? _selectedCategoryId;
  
  late List<Flashcard> _flashcards;
  
  // ZMIANA 1: Nowa zmienna stanu do śledzenia zmian
  bool _changesMade = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.set.title);
    _descController = TextEditingController(text: widget.set.description);
    _selectedCategoryId = widget.set.categoryId;
    _flashcards = List.from(widget.set.flashcards);
    
    // ZMIANA 2: Dodajemy listener, aby oznaczyć zmiany w polach tekstowych
    _titleController.addListener(_markChangesMade);
    _descController.addListener(_markChangesMade);
  }

  // Funkcja pomocnicza do oznaczania zmian
  void _markChangesMade() {
    // Sprawdzamy, czy aktualne wartości różnią się od początkowych (tylko w momencie inicjalizacji)
    // Zmienna _changesMade jest wystarczająca, aby śledzić, czy po wejściu na ekran nastąpiła JAKAKOLWIEK zmiana.
    // Aby uprościć, po prostu ustawiamy ją na true.
    if (!_changesMade) {
      setState(() {
        _changesMade = true;
      });
    }
  }

  @override
  void dispose() {
    // Pamiętaj o usunięciu listenerów
    _titleController.removeListener(_markChangesMade);
    _descController.removeListener(_markChangesMade);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ZMIANA 3: Funkcja do wyświetlania popupu potwierdzającego odrzucenie zmian
  Future<bool> _showDiscardChangesDialog() async {
    if (!_changesMade) {
      return true; // Pozwól na wyjście, jeśli nie ma zmian
    }

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Potwierdzenie'),
          content: const Text('Czy na pewno chcesz odrzucić zmiany?'), // Tekst z Twojej prośby
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              // Zwrócenie 'false' zapobiega wyjściu
              onPressed: () => Navigator.of(context).pop(false), 
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Odrzuć', style: TextStyle(color: Colors.white)),
              // Zwrócenie 'true' pozwala na wyjście
              onPressed: () => Navigator.of(context).pop(true), 
            ),
          ],
        );
      },
    ) ?? false; // Domyślnie blokuj wyjście
  }


  void _saveChanges() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj tytuł zestawu')),
      );
      return;
    }

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
      // ZMIANA 4: Po zapisaniu, oznaczamy, że nie ma już niezapisanych zmian
      _changesMade = false;
    });

    Navigator.pop(context, true);
  }

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
                    _flashcards.add(Flashcard(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      question: questionController.text,
                      answer: answerController.text,
                    ));
                  } else if (index != null) {
                    _flashcards[index] = Flashcard(
                      id: existingFlashcard.id,
                      question: questionController.text,
                      answer: answerController.text,
                    );
                  }
                  // ZMIANA 5: Po dodaniu/edycji fiszki, oznaczamy, że zmiany zostały wprowadzone
                  _changesMade = true;
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
      // ZMIANA 6: Po usunięciu fiszki, oznaczamy, że zmiany zostały wprowadzone
      _changesMade = true;
    });
  }

  void _confirmDeleteFlashcard(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdzenie usunięcia'),
        content: const Text(
            'Czy chcesz usunąć tę fiszkę? Te zmiany nie mogą zostać cofnięte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _deleteFlashcard(index);
              Navigator.pop(context);
            },
            child: const Text('Usuń', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ZMIANA 7: Zawiń główny widżet w WillPopScope
    return WillPopScope(
      onWillPop: _showDiscardChangesDialog, // Wywołaj funkcję sprawdzającą zmiany
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
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    // Listener został dodany w initState, więc nie potrzebujemy tu onChanged
                    decoration: const InputDecoration(
                      labelText: 'Tytuł zestawu',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    // Listener został dodany w initState, więc nie potrzebujemy tu onChanged
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
                        // ZMIANA 8: Oznaczamy, że zmiany zostały wprowadzone
                        _changesMade = true;
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
            // Zmieniony widżet listy
            Expanded(
              child: ListView.builder(
                // Długość listy powiększona o 1 (dla przycisku dodawania)
                itemCount: _flashcards.length + 1,
                itemBuilder: (context, index) {
                  // Jeśli jest to ostatni element (index == _flashcards.length)
                  if (index == _flashcards.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 20.0, left: 10.0, right: 10.0),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Dodaj nową fiszkę'),
                        onPressed: () => _showFlashcardDialog(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    );
                  }

                  // W przeciwnym razie wyświetl normalną fiszkę
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
    );
  }
}