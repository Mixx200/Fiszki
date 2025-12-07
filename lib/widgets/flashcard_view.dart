import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../data/mock_data.dart';

class FlashcardView extends StatefulWidget {
  final Flashcard flashcard;
  final int currentIndex;
  final int totalCount;
  final Function(bool isKnown) onAnswered;

  const FlashcardView({
    Key? key,
    required this.flashcard,
    required this.currentIndex,
    required this.totalCount,
    required this.onAnswered,
  }) : super(key: key);

  @override
  _FlashcardViewState createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> {
  bool _isAnswerVisible = false;
  bool _isAssessmentVisible = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  void _checkIfSaved() {
    setState(() {
      _isSaved = savedFlashcards.any((f) => f.id == widget.flashcard.id);
    });
  }

  void _toggleSave() {
    setState(() {
      if (_isSaved) {
        savedFlashcards.removeWhere((f) => f.id == widget.flashcard.id);
        _isSaved = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fiszka usunięta z zapisanych')),
        );
      } else {
        savedFlashcards.add(widget.flashcard);
        _isSaved = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fiszka zapisana')),
        );
      }
    });
  }

  void _showAnswer() {
    setState(() {
      _isAnswerVisible = true;
    });
  }

  void _hideAnswer() {
    setState(() {
      _isAnswerVisible = false;
      _isAssessmentVisible = false;
    });
  }
  
  void _showAssessment() {
     setState(() {
      _isAssessmentVisible = true;
    });
  }

  void _submitAnswer(bool isKnown) {
    widget.onAnswered(isKnown);
    setState(() {
      _isAnswerVisible = false;
      _isAssessmentVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Górny pasek z licznikiem i przyciskiem zapisu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.currentIndex} / ${widget.totalCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: _isSaved ? Colors.blue : Colors.grey,
                ),
                onPressed: _toggleSave,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Główny kontener Pytanie/Odpowiedź
          Expanded(
            child: Card(
              color: _isAnswerVisible ? Colors.blue : Colors.grey[200],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _isAnswerVisible ? widget.flashcard.answer : widget.flashcard.question,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _isAnswerVisible ? Colors.white : Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Sekcja przycisków
          if (!_isAnswerVisible)
            ElevatedButton(
              onPressed: _showAnswer,
              child: const Text('Pokaż odpowiedź'),
            )
          else if (_isAnswerVisible && !_isAssessmentVisible)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _showAssessment,
                  child: const Text('Oceń odpowiedź'),
                ),
                TextButton(
                  onPressed: _hideAnswer,
                  child: const Text('Ukryj odpowiedź'),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Czy umiesz tę fiszkę?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _submitAnswer(false),
                        child: const Text('Nie umiem'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () => _submitAnswer(true),
                        child: const Text('Umiem'),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _hideAnswer,
                  child: const Text('Ukryj odpowiedź'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}