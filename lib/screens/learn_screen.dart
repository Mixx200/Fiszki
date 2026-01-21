import 'package:flutter/material.dart';
import '../models/flashcard_set.dart';
import '../widgets/flashcard_view.dart';
import 'results_screen.dart';
import '../data/mock_data.dart';

class LearnScreen extends StatefulWidget {
  final FlashcardSet flashcardSet;
  const LearnScreen({Key? key, required this.flashcardSet}) : super(key: key);

  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late PageController _pageController;
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

  Future<bool> _onWillPop() async {
    if (_progress.length == widget.flashcardSet.flashcards.length) {
      return true;
    }

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Przerwać naukę?'),
        content: const Text('Twoje postępy w tej sesji nie zostaną w pełni zapisane.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Zostań'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Wyjdź', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _onAnswered(String flashcardId, bool isKnown) {
    setState(() {
      _progress[flashcardId] = isKnown;
    });

    if (_progress.length == widget.flashcardSet.flashcards.length) {
      _finishLearning();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishLearning() {
    int knownCount = _progress.values.where((known) => known == true).length;
    int unknownCount = _progress.values.length - knownCount;

    updateSetProgress(widget.flashcardSet.id, knownCount, unknownCount);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          known: knownCount,
          unknown: unknownCount,
          set: widget.flashcardSet,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingFlashcards = widget.flashcardSet.flashcards
        .where((f) => !_progress.containsKey(f.id))
        .toList();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.flashcardSet.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: remainingFlashcards.length,
          itemBuilder: (context, index) {
            final flashcard = remainingFlashcards[index];
            return FlashcardView(
              flashcard: flashcard,
              currentIndex: _progress.length + 1,
              totalCount: widget.flashcardSet.flashcards.length,
              onAnswered: (isKnown) => _onAnswered(flashcard.id, isKnown),
            );
          },
        ),
      ),
    );
  }
}
