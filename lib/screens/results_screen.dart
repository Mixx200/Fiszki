import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import '../models/flashcard_set.dart';
import 'learn_screen.dart';

class ResultsScreen extends StatelessWidget {
  final int known;
  final int unknown;
  final FlashcardSet set; // Zestaw do powtórzenia

  const ResultsScreen({
    Key? key,
    required this.known,
    required this.unknown,
    required this.set,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int total = known + unknown;
    final double knownPercent = (total == 0) ? 0 : (known / total) * 100;
    final double unknownPercent = (total == 0) ? 0 : (unknown / total) * 100;

    // Dane do wykresu
    Map<String, double> dataMap = {
      "Umiesz": known.toDouble(),
      "Nie umiesz": unknown.toDouble(),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Wyniki'), automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gratulacje!',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              Text(
                'Ukończyłeś/aś zestaw "${set.title}"',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              
              // Wykres kołowy
              PieChart(
                dataMap: dataMap,
                colorList: const [Colors.blue, Colors.red], // Umiem, Nie umiem
                chartRadius: MediaQuery.of(context).size.width / 2.5,
                legendOptions: const LegendOptions(showLegends: false),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: false,
                  showChartValues: false,
                ),
              ),
              
              const SizedBox(height: 20),
              Text(
                '${knownPercent.toStringAsFixed(0)}% umiesz',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Text(
                '${unknownPercent.toStringAsFixed(0)}% nie umiesz',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Zastąp ten ekran nową sesją nauki
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearnScreen(flashcardSet: set),
                    ),
                  );
                },
                child: const Text('Powtórz zestaw'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Wróć do ekranu głównego
                  Navigator.of(context).popUntil((route) => route.isFirst);
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