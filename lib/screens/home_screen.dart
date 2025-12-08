import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/category.dart';
import '../models/flashcard_set.dart';
import '../models/flashcard.dart';
import 'create_set_screen_1.dart';
import 'learn_screen.dart';
import 'saved_flashcards_screen.dart';
import 'search_screen.dart';
import 'my_sets_screen.dart';
import 'edit_set_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  List<bool> _toggleSelection = [false, false, false];
  List<FlashcardSet> _filteredSets = [];
  bool _showOnlyMySets = false;

  @override
  void initState() {
    super.initState();
    _filteredSets = mockSets;
  }

  void _deleteSet(String setId) {
    setState(() {
      mockSets.removeWhere((set) => set.id == setId);
      _filterSets();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zestaw usunięty')),
    );
  }

  // NOWA FUNKCJA: Potwierdzenie usunięcia zestawu
  void _confirmDeleteSet(BuildContext context, String setId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potwierdzenie usunięcia'),
        content: const Text(
            'Czy na pewno chcesz usunąć ten zestaw? Tej akcji nie można cofnąć.'),
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
              Navigator.pop(context); 
              _deleteSet(setId);
            },
            child: const Text('Usuń', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addCategory(String name) {
    setState(() {
      mockCategories.add(Category(id: 'c${mockCategories.length + 1}', name: name));
    });
  }

  void _filterSets() {
    setState(() {
      _filteredSets = mockSets.where((set) {
        final categoryMatch = _selectedCategoryId == null || set.categoryId == _selectedCategoryId;
        final searchMatch = _searchController.text.isEmpty ||
            set.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            set.description.toLowerCase().contains(_searchController.text.toLowerCase());
        final mySetsMatch = !_showOnlyMySets || set.ownerId == currentUserId;
        
        return categoryMatch && searchMatch && mySetsMatch;
      }).toList();
    });
  }

  void _onToggleChanged(int index) {
    setState(() {
      for (int i = 0; i < _toggleSelection.length; i++) {
        _toggleSelection[i] = i == index;
      }

      if (index == 0) { // Statystyki
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatsScreen()),
        ).then((_) {
          _resetFilters();
        });
        _toggleSelection[0] = false;
        
      } else if (index == 1) { // Moje
        _showOnlyMySets = true;
        _filterSets();
      } else if (index == 2) { // Zapisane
        _navigateToSavedFlashcards();
        _toggleSelection[2] = false;
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _showOnlyMySets = false;
      _toggleSelection = [false, false, false];
      _filterSets();
    });
  }

  void _navigateToSavedFlashcards() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedFlashcardsScreen()),
    ).then((_) {
      _resetFilters();
    });
  }

  void _navigateToSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchScreen()),
    );
  }

  void _navigateToMySets() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MySetsScreen()),
    ).then((_) {
      _resetFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cognito'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _navigateToSearch,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _navigateToSavedFlashcards,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToMySets,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showOnlyMySets)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Pokazuję tylko moje zestawy'),
                    const Spacer(),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Wyczyść'),
                    ),
                  ],
                ),
              ),
            // Filtr kategorii
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategoria',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategoryId,
              items: [
                const DropdownMenuItem(value: null, child: Text('Wszystkie kategorie')),
                ...mockCategories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
                _filterSets();
              },
            ),
            const SizedBox(height: 10),
            // Wyszukiwarka
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Wyszukaj zestaw',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filterSets(),
            ),
            const SizedBox(height: 10),
            // Przyciski Statystyki / Moje / Zapisane
            ToggleButtons(
              isSelected: _toggleSelection,
              onPressed: _onToggleChanged,
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Statystyki')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Moje')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Zapisane')),
              ],
            ),
            const SizedBox(height: 20),
            // Lista zestawów
            Expanded(
              child: _filteredSets.isEmpty
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
                          Text(
                            _showOnlyMySets 
                                ? 'Nie masz jeszcze własnych zestawów'
                                : 'Brak zestawów spełniających kryteria',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          if (_showOnlyMySets)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateSetScreen1(
                                      onCategoryAdded: _addCategory,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Utwórz pierwszy zestaw'),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredSets.length,
                      itemBuilder: (context, index) {
                        final set = _filteredSets[index];
                        final category = mockCategories.firstWhere(
                          (cat) => cat.id == set.categoryId,
                          orElse: () => Category(id: '?', name: 'Brak kategorii'),
                        );

                        return Card(
                          color: set.ownerId == currentUserId ? Colors.blue[50] : Colors.grey[200],
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: set.ownerId == currentUserId 
                                ? const Icon(Icons.person, color: Colors.blue)
                                : null,
                            title: Text(set.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Kategoria: ${category.name}\n${set.flashcards.length} pytania'),
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
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  // ZMIANA: Wywołanie funkcji z potwierdzeniem
                                  _confirmDeleteSet(context, set.id);
                                } else if (value == 'edit') {
                              
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditSetScreen(set: set),
                                    ),
                                  );
                                  
                                  if (result == true) {
                                    _filterSets();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Zestaw zaktualizowany')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
            setState(() {
              _filterSets();
            });
          });
        },
      ),
    );
  }

}