import 'package:flutter/material.dart';
import '../models/flashcard_set.dart';
import '../widgets/flashcard_view.dart';
import 'results_screen.dart';
import '../data/mock_data.dart'; // Upewnij się, że ten import tu jest i zawiera updateSetProgress

class LearnScreen extends StatefulWidget {
  final FlashcardSet flashcardSet;
  const LearnScreen({Key? key, required this.flashcardSet}) : super(key: key);

  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late PageController _pageController;
  // Mapa do śledzenia postępów: klucz to ID fiszki, wartość to true (umiem) / false (nie umiem)
  final Map<String, bool> _progress = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAnswered(String flashcardId, bool isKnown) {
    // USUŃ TUTAJ POJEDYNCZE ZAPISYWANIE! 
    // recordFlashcardStudy(); // Ta linia została usunięta, aby zapobiec podwójnemu liczeniu
    
    // Zapisz postęp
    setState(() {
      _progress[flashcardId] = isKnown;
    });

    // Sprawdź, czy to ostatnia fiszka
    if (_progress.length == widget.flashcardSet.flashcards.length) {
      _finishLearning();
    } else {
      // Przejdź do następnej strony
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishLearning() {
    // Oblicz wyniki
    int knownCount = _progress.values.where((known) => known == true).length;
    int unknownCount = _progress.values.length - knownCount;
    
    // === KLUCZOWA ZMIANA: JEDNOKROTNY ZAPIS STATYSTYK SESJI ===
    // Zapisz wyniki całej sesji raz, zanim nastąpi nawigacja
    updateSetProgress(widget.flashcardSet.id, knownCount, unknownCount);
    // ========================================================

    // Przejdź do ekranu wyników
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          known: knownCount,
          unknown: unknownCount,
          set: widget.flashcardSet, // Przekaż zestaw do powtórki
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrujemy fiszki, których jeszcze nie oceniliśmy
    final remainingFlashcards = widget.flashcardSet.flashcards
        .where((f) => !_progress.containsKey(f.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.flashcardSet.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Wróć do ekranu głównego, usuwając wszystko po drodze
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Wyłącz przewijanie gestem
        itemCount: remainingFlashcards.length,
        itemBuilder: (context, index) {
          final flashcard = remainingFlashcards[index];
          return FlashcardView(
            flashcard: flashcard,
            currentIndex: _progress.length + 1, // Aktualny numer
            totalCount: widget.flashcardSet.flashcards.length, // Całkowita liczba
            onAnswered: (isKnown) => _onAnswered(flashcard.id, isKnown),
          );
        },
      ),
    );
  }
}