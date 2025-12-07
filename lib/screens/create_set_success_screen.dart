import 'package:flutter/material.dart';
import '../models/flashcard_set.dart';
import 'learn_screen.dart';

class CreateSetSuccessScreen extends StatelessWidget {
  final FlashcardSet createdSet;
  const CreateSetSuccessScreen({Key? key, required this.createdSet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(createdSet.title), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Zestaw "${createdSet.title}" utworzony pomyślnie.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Zastąp ten ekran ekranem nauki
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>LearnScreen(flashcardSet: createdSet),
                    ),
                  );
                },
                child: const Text('Ucz się tego zestawu'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Po prostu wróć (jesteśmy już na szczycie stosu)
                  Navigator.pop(context);
                },
                child: const Text('Strona główna'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}