import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Flashcard> _searchResults = [];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final results = <Flashcard>[];
    final lowerQuery = query.toLowerCase();

    for (final set in mockSets) {
      for (final flashcard in set.flashcards) {
        if (flashcard.question.toLowerCase().contains(lowerQuery) ||
            flashcard.answer.toLowerCase().contains(lowerQuery)) {
          results.add(flashcard);
        }
      }
    }

    setState(() {
      _searchResults = results;
    });
  }

  void _saveFlashcard(Flashcard flashcard) {
    if (!savedFlashcards.any((f) => f.id == flashcard.id)) {
      setState(() {
        savedFlashcards.add(flashcard);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiszka zapisana')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiszka już jest zapisana')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyszukiwanie fiszek'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Szukaj fiszek...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
              ),
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'Wpisz szukaną frazę'
                          : 'Brak wyników dla "${_searchController.text}"',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final flashcard = _searchResults[index];
                      final isSaved = savedFlashcards.any((f) => f.id == flashcard.id);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            flashcard.question,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            flashcard.answer,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () => _saveFlashcard(flashcard),
                          ),
                          onTap: () {
                            _showFlashcardDetail(flashcard);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
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