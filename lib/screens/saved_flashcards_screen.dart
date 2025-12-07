import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/flashcard.dart';

class SavedFlashcardsScreen extends StatefulWidget {
  const SavedFlashcardsScreen({Key? key}) : super(key: key);

  @override
  _SavedFlashcardsScreenState createState() => _SavedFlashcardsScreenState();
}

class _SavedFlashcardsScreenState extends State<SavedFlashcardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zapisane fiszki'),
      ),
      body: savedFlashcards.isEmpty
          ? const Center(
              child: Text('Brak zapisanych fiszek'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: savedFlashcards.length,
              itemBuilder: (context, index) {
                final flashcard = savedFlashcards[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      flashcard.question,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(flashcard.answer),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          savedFlashcards.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fiszka usunięta')),
                        );
                      },
                    ),
                    onTap: () {
                      _showFlashcardDetail(flashcard);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showFlashcardDetail(Flashcard flashcard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fiszka'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pytanie:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const SizedBox(height: 5),
              Text(flashcard.question),
              const SizedBox(height: 15),
              Text(
                'Odpowiedź:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const SizedBox(height: 5),
              Text(flashcard.answer),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
        ],
      ),
    );
  }
}