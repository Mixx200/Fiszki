import 'package:flutter/material.dart';
import '../data/mock_data.dart'; // Importujemy currentUserId
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';
import 'create_set_success_screen.dart';

class FlashcardControllers {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  void dispose() {
    questionController.dispose();
    answerController.dispose();
  }
}

class CreateSetScreen2 extends StatefulWidget {
  final FlashcardSet draftSet;
  final bool isEditing;
  const CreateSetScreen2({Key? key, required this.draftSet, this.isEditing = false}) : super(key: key);

  @override
  _CreateSetScreen2State createState() => _CreateSetScreen2State();
}

class _CreateSetScreen2State extends State<CreateSetScreen2> {
  List<FlashcardControllers> _flashcardControllers = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.draftSet.flashcards.isNotEmpty) {
      for (final flashcard in widget.draftSet.flashcards) {
        final controllers = FlashcardControllers();
        controllers.questionController.text = flashcard.question;
        controllers.answerController.text = flashcard.answer;
        _flashcardControllers.add(controllers);
      }
    } else {
      _addFlashcardFields();
    }
  }

  @override
  void dispose() {
    for (final controller in _flashcardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFlashcardFields() {
    setState(() {
      _flashcardControllers.add(FlashcardControllers());
    });
  }

  void _removeFlashcardFields(int index) {
    setState(() {
      _flashcardControllers.removeAt(index);
    });
  }

  void _finishCreatingSet() {
    List<Flashcard> newFlashcards = [];
    for (int i = 0; i < _flashcardControllers.length; i++) {
      final q = _flashcardControllers[i].questionController.text;
      final a = _flashcardControllers[i].answerController.text;

      if (q.isNotEmpty && a.isNotEmpty) {
        newFlashcards.add(
          Flashcard(
            id: widget.isEditing && i < widget.draftSet.flashcards.length 
                ? widget.draftSet.flashcards[i].id 
                : 'f${DateTime.now().millisecondsSinceEpoch}-$i',
            question: q,
            answer: a,
          ),
        );
      }
    }

    if (newFlashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj przynajmniej jedną fiszkę')),
      );
      return;
    }

    final newSet = FlashcardSet(
      id: widget.isEditing ? widget.draftSet.id : 's${mockSets.length + 1}',
      title: widget.draftSet.title,
      description: widget.draftSet.description,
      categoryId: widget.draftSet.categoryId,
      flashcards: newFlashcards,
      ownerId: currentUserId, // DODAJEMY ownerId dla nowych zestawów
    );

    if (widget.isEditing) {
      final index = mockSets.indexWhere((set) => set.id == widget.draftSet.id);
      if (index != -1) {
        mockSets[index] = newSet;
      }
    } else {
      mockSets.add(newSet);
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CreateSetSuccessScreen(createdSet: newSet)),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.draftSet.title),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _finishCreatingSet,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _flashcardControllers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fiszka ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (_flashcardControllers.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeFlashcardFields(index),
                              ),
                          ],
                        ),
                        TextFormField(
                          controller: _flashcardControllers[index].questionController,
                          decoration: const InputDecoration(labelText: 'Pytanie'),
                          maxLines: 2,
                        ),
                        TextFormField(
                          controller: _flashcardControllers[index].answerController,
                          decoration: const InputDecoration(labelText: 'Odpowiedź'),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Dodaj kolejną fiszkę'),
                  onPressed: _addFlashcardFields,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _finishCreatingSet,
                  child: Text(widget.isEditing ? 'Zapisz zmiany' : 'Zakończ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}