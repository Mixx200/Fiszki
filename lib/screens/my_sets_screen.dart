import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/flashcard_set.dart';
import '../models/category.dart'; 
import 'learn_screen.dart';
import 'create_set_screen_2.dart';
import 'create_set_screen_1.dart'; 

class MySetsScreen extends StatefulWidget {
  const MySetsScreen({Key? key}) : super(key: key);

  @override
  _MySetsScreenState createState() => _MySetsScreenState();
}

class _MySetsScreenState extends State<MySetsScreen> {
  List<FlashcardSet> get mySets {
    return mockSets.where((set) => set.ownerId == currentUserId).toList();
  }

  void _deleteSet(String setId) {
    setState(() {
      mockSets.removeWhere((set) => set.id == setId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zestaw usunięty')),
    );
  }

  void _editSet(FlashcardSet set) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateSetScreen2(draftSet: set, isEditing: true),
      ),
    ).then((_) {
      setState(() {}); // Odśwież po powrocie z edycji
    });
  }

  // Funkcja do dodawania kategorii (potrzebna dla CreateSetScreen1)
  void _addCategory(String name) {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje zestawy'),
      ),
      body: mySets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.collections_bookmark,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nie masz jeszcze własnych zestawów',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Utwórz swój pierwszy zestaw fiszek!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: mySets.length,
              itemBuilder: (context, index) {
                final set = mySets[index];
                final category = mockCategories.firstWhere(
                  (cat) => cat.id == set.categoryId,
                  orElse: () => Category(id: '?', name: 'Brak kategorii'), // POPRAWIONE
                );

                return Card(
                  color: Colors.blue[50],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: Text(set.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Kategoria: ${category.name}\n${set.flashcards.length} pytania'), // POPRAWIONE
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LearnScreen(flashcardSet: set),
                        ),
                      );
                    },
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edytuj')),
                        const PopupMenuItem(value: 'delete', child: Text('Usuń')),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteSet(set.id);
                        } else if (value == 'edit') {
                          _editSet(set);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateSetScreen1(
                onCategoryAdded: _addCategory, 
              ),
            ),
          ).then((_) {
            setState(() {}); // Odśwież po powrocie
          });
        },
      ),
    );
  }

}
