import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  // Generuje listę ostatnich 7 dni
  List<MapEntry<String, int>> _getLast7DaysStats() {
    List<MapEntry<String, int>> stats = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = date.toIso8601String().split('T')[0]; // Format YYYY-MM-DD
      final count = dailyStats[key] ?? 0;
      stats.add(MapEntry(key, count));
    }
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final last7Days = _getLast7DaysStats();
    // Znajdź maksymalną wartość, aby wyskalować słupki (minimum 10, żeby wykres nie był pusty przy 0)
    int maxCount = last7Days.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxCount < 10) maxCount = 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje postępy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Przerobione fiszki (ostatnie 7 dni)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            // Wykres
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: last7Days.map((entry) {
                  // Oblicz wysokość słupka jako ułamek dostępnej wysokości
                  // Używamy trochę matematyki, aby słupki były proporcjonalne
                  final double percentage = entry.value / maxCount;
                  
                  // Parsowanie daty, aby wyświetlić np. "Pn", "Wt" lub dzień miesiąca
                  final dateParts = entry.key.split('-');
                  final dayLabel = '${dateParts[2]}.${dateParts[1]}'; // np. 24.11

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Liczba nad słupkiem
                      Text(
                        entry.value > 0 ? entry.value.toString() : '',
                        style: const TextStyle(
                          fontSize: 12, 
                          fontWeight: FontWeight.bold,
                          color: Colors.grey
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Słupek
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: percentage),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, _) {
                          return Container(
                            width: 20,
                            // Ustawiamy minimalną wysokość 1px, żeby było widać podstawę
                            height: (MediaQuery.of(context).size.height * 0.4) * value + 1,
                            decoration: BoxDecoration(
                              color: entry.key == DateTime.now().toIso8601String().split('T')[0] 
                                  ? Colors.blue // Dzisiaj na niebiesko
                                  : Colors.blue[200], // Inne dni jaśniejsze
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      // Etykieta daty
                      Text(
                        dayLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Podsumowanie
            Card(
              color: Colors.blue[50],
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.orange, size: 40),
                title: const Text('Łącznie w tym tygodniu'),
                subtitle: Text(
                  '${last7Days.map((e) => e.value).reduce((a, b) => a + b)} fiszek',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}