import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/flashcard_set.dart'; // Niezbędny, aby pobrać tytuły zestawów

class StatsScreen extends StatelessWidget {
  const StatsScreen({Key? key}) : super(key: key);

  // Generuje listę ostatnich 7 dni na podstawie dynamicznych danych
  List<MapEntry<String, int>> _getLast7DaysStats() {
    List<MapEntry<String, int>> stats = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = date.toIso8601String().split('T')[0];
      
      // Używamy dynamicznej mapy dailyStats
      final count = dailyStats[key] ?? 0;
      stats.add(MapEntry(key, count));
    }
    return stats;
  }
  
  // Generuje statystyki dla zestawów na podstawie dynamicznych danych
  List<Map<String, dynamic>> _getSetStats() {
    List<Map<String, dynamic>> setStats = [];

    for (var set in mockSets) {
      // Pobieranie statystyk z mapy setProgressStats
      final progress = setProgressStats[set.id] ?? {'totalAnswered': 0, 'totalCorrect': 0};
      
      final totalAnswered = progress['totalAnswered'] as int;
      final totalCorrect = progress['totalCorrect'] as int;
      
      final correctPercentage = totalAnswered > 0 
          ? ((totalCorrect / totalAnswered) * 100).round() 
          : 0;

      setStats.add({
        'title': set.title,
        'answered': totalAnswered,
        'correct_percent': correctPercentage,
        'id': set.id,
      });
    }

    // Sortowanie (np. od zestawu z największą liczbą przerobionych fiszek)
    setStats.sort((a, b) => b['answered'].compareTo(a['answered']));

    return setStats;
  }

  @override
  Widget build(BuildContext context) {
    final last7Days = _getLast7DaysStats();
    final setStats = _getSetStats();
    
    // Znajdź maksymalną wartość, aby wyskalować słupki (minimum 10)
    int maxCount = last7Days.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxCount < 10) maxCount = 10;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Twoje postępy'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Przerobione fiszki (ostatnie 7 dni)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: last7Days.map((entry) {
                    final double percentage = entry.value / maxCount;
                    final dateParts = entry.key.split('-');
                    final dayLabel = '${dateParts[2]}.${dateParts[1]}';

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          entry.value > 0 ? entry.value.toString() : '',
                          style: const TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: Colors.grey
                          ),
                        ),
                        const SizedBox(height: 5),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: percentage),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, _) {
                            return Container(
                              width: 20,
                              height: (MediaQuery.of(context).size.height * 0.4) * value + 1,
                              decoration: BoxDecoration(
                                color: entry.key == DateTime.now().toIso8601String().split('T')[0] 
                                    ? Colors.blue
                                    : Colors.blue[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
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

              const SizedBox(height: 40),
              const Text(
                'Statystyki zestawów',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              ...setStats.map((stat) {
                final percent = stat['correct_percent'] as int;
                final answered = stat['answered'] as int;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['title'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Przerobiono fiszek:', style: TextStyle(color: Colors.grey)),
                                  Text(
                                    answered.toString(),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CircularProgressIndicator(
                                          value: percent / 100,
                                          strokeWidth: 4,
                                          backgroundColor: Colors.red[100],
                                          color: percent >= 75 ? Colors.green : Colors.orange,
                                        ),
                                        Center(
                                          child: Text(
                                            '$percent%',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: percent >= 75 ? Colors.green : Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Poprawność', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}