import '../models/category.dart';
import '../models/flashcard.dart';
import '../models/flashcard_set.dart';

// Zmodyfikowane struktury danych do śledzenia statystyk
// --------------------------------------------------------------------------

// 1. Statystyki dzienne (Liczba przerobionych fiszek)
// Początkowo pusta, statystyki resetują się.
// Format: {'YYYY-MM-DD': Liczba_fiszki}
Map<String, int> dailyStats = {};

// 2. Statystyki zestawów
// Klucz: ID zestawu (String)
// Wartość: Mapa statystyk {'totalAnswered': int, 'totalCorrect': int}
Map<String, Map<String, int>> setProgressStats = {};

// Funkcja pomocnicza do formatowania daty na klucz (np. "2023-11-24")
String _getDateKey(DateTime date) {
  return date.toIso8601String().split('T')[0];
}

// Funkcja wywoływana, gdy użytkownik przerobi fiszkę (przykładowa, aktualizuje tylko statystyki dzienne)
void recordFlashcardStudy() {
  final todayKey = _getDateKey(DateTime.now());
  if (dailyStats.containsKey(todayKey)) {
    dailyStats[todayKey] = dailyStats[todayKey]! + 1;
  } else {
    dailyStats[todayKey] = 1;
  }
}

// Dodaj tę funkcję do mock_data.dart:

void updateSetProgress(String setId, int totalKnown, int totalUnknown) {
  final totalAnsweredInSession = totalKnown + totalUnknown;
  final totalCorrectInSession = totalKnown;
  final todayKey = _getDateKey(DateTime.now());
  
  if (totalAnsweredInSession == 0) return; // Nic do zapisania
  
  // 1. Aktualizacja statystyk dziennych (dailyStats)
  dailyStats.update(
    todayKey, 
    (currentCount) => currentCount + totalAnsweredInSession, 
    ifAbsent: () => totalAnsweredInSession
  );

  // 2. Aktualizacja statystyk zestawu (setProgressStats)
  
  // Zapewnienie, że klucz istnieje
  setProgressStats.putIfAbsent(setId, () => {'totalAnswered': 0, 'totalCorrect': 0});
  
  // Aktualizacja wartości
  setProgressStats[setId]!['totalAnswered'] = 
      setProgressStats[setId]!['totalAnswered']! + totalAnsweredInSession;
  
  setProgressStats[setId]!['totalCorrect'] = 
      setProgressStats[setId]!['totalCorrect']! + totalCorrectInSession;
  
  // Opcjonalnie: Jeśli używasz Hive lub innego mechanizmu trwałości, 
  // w tym miejscu powinien nastąpić zapis (np. Box.put(key, map)).
}

// --------------------------------------------------------------------------
// ISTNIEJĄCE DANE MOCK
// --------------------------------------------------------------------------

// zapisane fiszki:
List<Flashcard> savedFlashcards = [];

// ID bieżącego użytkownika 
String currentUserId = 'user_123';


// Lista kategorii
List<Category> mockCategories = [
  Category(id: 'c1', name: 'Liceum'),
  Category(id: 'c2', name: 'Studia'),
  Category(id: 'c3', name: 'Inne'),
];

// Lista zestawów fiszek
List<FlashcardSet> mockSets = [
  // 1. Bazy danych
  FlashcardSet(
    id: 's1',
    title: 'Bazy danych - podstawy',
    description: 'Relacyjne bazy danych i SQL.',
    categoryId: 'c2',
    flashcards: [
      Flashcard(
        id: 'f1-1',
        question: 'Czym jest baza danych?',
        answer:
            'Zbiór powiązanych danych przechowywanych w uporządkowany sposób, zwykle zarządzanych przez system zarządzania bazą danych (DBMS).',
      ),
      Flashcard(
        id: 'f1-2',
        question: 'Co to jest DBMS?',
        answer:
            'System zarządzania bazą danych (Database Management System) to oprogramowanie umożliwiające tworzenie, modyfikację i udostępnianie baz danych.',
      ),
      Flashcard(
        id: 'f1-3',
        question: 'Czym jest relacyjna baza danych?',
        answer:
            'Baza danych, w której dane są przechowywane w tabelach (relacjach) powiązanych ze sobą kluczami.',
      ),
      Flashcard(
        id: 'f1-4',
        question: 'Co oznacza skrót SQL?',
        answer: 'Structured Query Language, język zapytań do baz relacyjnych.',
      ),
      Flashcard(
        id: 'f1-5',
        question: 'Polecenie SQL do pobierania danych z tabeli?',
        answer: 'SELECT kolumny FROM nazwa_tabeli WHERE warunek;',
      ),
      Flashcard(
        id: 'f1-6',
        question: 'Polecenie SQL do wstawiania nowego wiersza?',
        answer:
            'INSERT INTO nazwa_tabeli (kolumny) VALUES (wartości);',
      ),
      Flashcard(
        id: 'f1-7',
        question: 'Polecenie SQL do aktualizacji danych w tabeli?',
        answer:
            'UPDATE nazwa_tabeli SET kolumna = wartość WHERE warunek;',
      ),
      Flashcard(
        id: 'f1-8',
        question: 'Polecenie SQL do usuwania wierszy?',
        answer: 'DELETE FROM nazwa_tabeli WHERE warunek;',
      ),
      Flashcard(
        id: 'f1-9',
        question: 'Czym jest klucz główny (PRIMARY KEY)?',
        answer:
            'Kolumna lub zestaw kolumn jednoznacznie identyfikujący każdy wiersz w tabeli, nie dopuszcza wartości NULL i duplikatów.',
      ),
      Flashcard(
        id: 'f1-10',
        question: 'Czym jest klucz obcy (FOREIGN KEY)?',
        answer:
            'Kolumna, która odwołuje się do klucza głównego w innej tabeli i służy do tworzenia relacji między tabelami.',
      ),
      Flashcard(
        id: 'f1-11',
        question: 'Wymień trzy podstawowe typy relacji między tabelami.',
        answer:
            '1. Jeden do jednego\n2. Jeden do wielu\n3. Wiele do wielu',
      ),
      Flashcard(
        id: 'f1-12',
        question: 'Czym jest indeks w bazie danych?',
        answer:
            'Struktura danych przyspieszająca wyszukiwanie w tabeli kosztem dodatkowego miejsca i czasu przy modyfikacjach.',
      ),
      Flashcard(
        id: 'f1-13',
        question: 'Czym jest normalizacja bazy danych?',
        answer:
            'Proces organizacji danych w tabelach w celu redukcji redundancji i uniknięcia anomalii modyfikacji.',
      ),
      Flashcard(
        id: 'f1-14',
        question: 'Co to jest transakcja w bazie danych?',
        answer:
            'Sekwencja operacji traktowana jako jedna całość, która jest albo w całości zatwierdzona (COMMIT), albo wycofana (ROLLBACK).',
      ),
      Flashcard(
        id: 'f1-15',
        question: 'Jakie są właściwości transakcji ACID?',
        answer:
            '1. Atomicity\n2. Consistency\n3. Isolation\n4. Durability',
      ),
      Flashcard(
        id: 'f1-16',
        question: 'Do czego służy klauzula WHERE w SQL?',
        answer:
            'Do filtrowania wierszy spełniających określony warunek w zapytaniu.',
      ),
      Flashcard(
        id: 'f1-17',
        question: 'Do czego służy klauzula GROUP BY?',
        answer:
            'Do grupowania wierszy według wartości w kolumnach, zwykle z funkcjami agregującymi.',
      ),
      Flashcard(
        id: 'f1-18',
        question: 'Czym różni się INNER JOIN od LEFT JOIN?',
        answer:
            'INNER JOIN zwraca tylko dopasowane wiersze z obu tabel, LEFT JOIN zwraca wszystkie wiersze z tabeli lewej i dopasowane z prawej (lub NULL).',
      ),
      Flashcard(
        id: 'f1-19',
        question: 'Czym jest widok (VIEW) w bazie danych?',
        answer:
            'Logiczna tabela zdefiniowana przez zapytanie SQL, przechowująca definicję, a nie fizycznie dane.',
      ),
      Flashcard(
        id: 'f1-20',
        question: 'Czym różni się baza relacyjna od nierelacyjnej (NoSQL)?',
        answer:
            'Relacyjna używa tabel i SQL, a NoSQL zwykle innych modeli danych (dokumenty, klucze-wartości, grafy) oraz elastycznych schematów.',
      ),
    ],
  ),

  // 2. Java
  FlashcardSet(
    id: 's2',
    title: 'Java - podstawy',
    description: 'Składnia, klasy, obiekty i podstawowe mechanizmy języka Java.',
    categoryId: 'c2',
    flashcards: [
      Flashcard(
        id: 'f2-1',
        question: 'Czym jest JVM?',
        answer:
            'Java Virtual Machine, maszyna wirtualna wykonująca bajtkod Javy niezależnie od systemu operacyjnego.',
      ),
      Flashcard(
        id: 'f2-2',
        question: 'Co to jest klasa w Javie?',
        answer:
            'Szablon (typ) definiujący pola i metody, na podstawie którego tworzone są obiekty.',
      ),
      Flashcard(
        id: 'f2-3',
        question: 'Co to jest obiekt w Javie?',
        answer:
            'Konkretny egzemplarz klasy, posiadający własne wartości pól i zachowania zdefiniowane metodami.',
      ),
      Flashcard(
        id: 'f2-4',
        question: 'Jak wygląda metoda main w Javie?',
        answer:
            'public static void main(String[] args) { }',
      ),
      Flashcard(
        id: 'f2-5',
        question: 'Czym jest dziedziczenie w Javie?',
        answer:
            'Mechanizm pozwalający klasie pochodnej przejąć pola i metody klasy bazowej.',
      ),
      Flashcard(
        id: 'f2-6',
        question: 'Jak deklaruje się dziedziczenie w definicji klasy?',
        answer:
            'class KlasaPochodna extends KlasaBazowa { }',
      ),
      Flashcard(
        id: 'f2-7',
        question: 'Czym jest interfejs w Javie?',
        answer:
            'Typ określający zbiór metod, które klasa musi zaimplementować, bez implementacji domyślnej (oprócz metod domyślnych).',
      ),
      Flashcard(
        id: 'f2-8',
        question: 'Słowo kluczowe do implementacji interfejsu?',
        answer: 'implements',
      ),
      Flashcard(
        id: 'f2-9',
        question: 'Do czego służy słowo kluczowe static?',
        answer:
            'Oznacza, że pole lub metoda należy do klasy, a nie do konkretnego obiektu.',
      ),
      Flashcard(
        id: 'f2-10',
        question: 'Czym jest przeciążanie metod (overloading)?',
        answer:
            'Definiowanie wielu metod o tej samej nazwie, ale różnych listach parametrów.',
      ),
      Flashcard(
        id: 'f2-11',
        question: 'Czym jest przesłanianie metod (overriding)?',
        answer:
            'Ponowna implementacja metody z klasy bazowej w klasie potomnej z tą samą sygnaturą.',
      ),
      Flashcard(
        id: 'f2-12',
        question: 'Do czego służy słowo kluczowe this?',
        answer:
            'Odnosi się do bieżącego obiektu, pozwala np. odwołać się do jego pól i metod.',
      ),
      Flashcard(
        id: 'f2-13',
        question: 'Do czego służy słowo kluczowe super?',
        answer:
            'Odnosi się do klasy bazowej, umożliwia wywołanie jej konstruktora lub metod.',
      ),
      Flashcard(
        id: 'f2-14',
        question: 'Podaj przykład kolekcji w Javie.',
        answer:
            'ArrayList, LinkedList, HashSet, HashMap, TreeSet, itp.',
      ),
      Flashcard(
        id: 'f2-15',
        question: 'Jak obsługiwane są wyjątki w Javie?',
        answer:
            'Za pomocą bloków try, catch, finally oraz instrukcji throw i throws.',
      ),
      Flashcard(
        id: 'f2-16',
        question: 'Czym różni się wyjątek checked od unchecked?',
        answer:
            'Checked musi być obsłużony lub zadeklarowany w sygnaturze metody, unchecked (RuntimeException) nie wymaga takiej deklaracji.',
      ),
      Flashcard(
        id: 'f2-17',
        question: 'Co to jest pakiet (package) w Javie?',
        answer:
            'Logiczne pogrupowanie klas w przestrzeni nazw, zwykle odpowiada strukturze katalogów.',
      ),
      Flashcard(
        id: 'f2-18',
        question: 'Czym jest enkapsulacja?',
        answer:
            'Ukrywanie implementacji klasy poprzez prywatne pola i udostępnianie dostępu przez publiczne metody.',
      ),
      Flashcard(
        id: 'f2-19',
        question: 'Co oznacza skrót JDK?',
        answer:
            'Java Development Kit, zestaw narzędzi do tworzenia aplikacji w Javie.',
      ),
      Flashcard(
        id: 'f2-20',
        question: 'Do czego służą adnotacje w Javie?',
        answer:
            'Do przekazywania metadanych o kodzie, używanych przez kompilator, biblioteki lub frameworki.',
      ),
    ],
  ),

  // 3. Python
  FlashcardSet(
    id: 's3',
    title: 'Python - podstawy',
    description: 'Składnia Pythona, typy danych i podstawowe konstrukcje.',
    categoryId: 'c2',
    flashcards: [
      Flashcard(
        id: 'f3-1',
        question: 'Jak oznacza się blok kodu w Pythonie?',
        answer:
            'Za pomocą wcięć (indentation), a nie nawiasów klamrowych.',
      ),
      Flashcard(
        id: 'f3-2',
        question: 'Jak zadeklarować zmienną w Pythonie?',
        answer:
            'Nie ma deklaracji typu, po prostu przypisujemy wartość, na przykład: x = 10',
      ),
      Flashcard(
        id: 'f3-3',
        question: 'Wymień podstawowe typy danych w Pythonie.',
        answer:
            'int, float, bool, str, list, tuple, dict, set',
      ),
      Flashcard(
        id: 'f3-4',
        question: 'Jak zdefiniować funkcję w Pythonie?',
        answer:
            'Za pomocą słowa kluczowego def, na przykład: def nazwa(parametry):',
      ),
      Flashcard(
        id: 'f3-5',
        question: 'Jak utworzyć listę w Pythonie?',
        answer:
            'Za pomocą nawiasów kwadratowych, na przykład: lista = [1, 2, 3]',
      ),
      Flashcard(
        id: 'f3-6',
        question: 'Czym różni się lista od krotki (tuple)?',
        answer:
            'Lista jest modyfikowalna, a krotka niemodyfikowalna po utworzeniu.',
      ),
      Flashcard(
        id: 'f3-7',
        question: 'Jak iterować po elementach listy?',
        answer:
            'Za pomocą pętli for, na przykład: for x in lista:',
      ),
      Flashcard(
        id: 'f3-8',
        question: 'Jak wygląda instrukcja warunkowa if w Pythonie?',
        answer:
            'if warunek:\n    blok_kodu\nelif inny_warunek:\n    blok\nelse:\n    blok',
      ),
      Flashcard(
        id: 'f3-9',
        question: 'Czym jest słownik (dict) w Pythonie?',
        answer:
            'Struktura danych przechowująca pary klucz-wartość, na przykład: d = {\"a\": 1}',
      ),
      Flashcard(
        id: 'f3-10',
        question: 'Jak obsłużyć wyjątek w Pythonie?',
        answer:
            'Za pomocą bloków try i except, na przykład: try: ... except Exception as e: ...',
      ),
      Flashcard(
        id: 'f3-11',
        question: 'Jak zdefiniować klasę w Pythonie?',
        answer:
            'Za pomocą słowa kluczowego class, na przykład: class MyClass:',
      ),
      Flashcard(
        id: 'f3-12',
        question: 'Jak wygląda konstruktor w klasie Pythona?',
        answer:
            'Metoda __init__(self, parametry), wywoływana przy tworzeniu obiektu.',
      ),
      Flashcard(
        id: 'f3-13',
        question: 'Co oznacza parametr self w metodach?',
        answer:
            'Odniesienie do bieżącego obiektu, przekazywane jako pierwszy parametr metod instancji.',
      ),
      Flashcard(
        id: 'f3-14',
        question: 'Jak importować moduł w Pythonie?',
        answer:
            'Za pomocą instrukcji import, na przykład: import math lub from math import sqrt',
      ),
      Flashcard(
        id: 'f3-15',
        question: 'Jak stworzyć wirtualne środowisko w Pythonie?',
        answer:
            'Na przykład poleceniem python -m venv venv, a następnie aktywacja środowiska.',
      ),
      Flashcard(
        id: 'f3-16',
        question: 'Czym jest list comprehension?',
        answer:
            'Skrócona składnia do tworzenia list, na przykład: [x * 2 for x in lista if x > 0]',
      ),
      Flashcard(
        id: 'f3-17',
        question: 'Jak odczytać plik tekstowy w Pythonie?',
        answer:
            'with open(\"plik.txt\", \"r\", encoding=\"utf-8\") as f:\n    dane = f.read()',
      ),
      Flashcard(
        id: 'f3-18',
        question: 'Czym jest pip?',
        answer:
            'Menedżer pakietów Pythona służący do instalowania bibliotek zewnętrznych.',
      ),
      Flashcard(
        id: 'f3-19',
        question: 'Czym różni się funkcja od generatora?',
        answer:
            'Generator używa słowa kluczowego yield i zwraca kolejne wartości na żądanie, zamiast jednorazowo całego wyniku.',
      ),
      Flashcard(
        id: 'f3-20',
        question: 'Czym jest PEP 8?',
        answer:
            'Dokument określający zalecenia dotyczące stylu kodu w Pythonie.',
      ),
    ],
  ),

  // 4. Języki formalne
  FlashcardSet(
    id: 's4',
    title: 'Języki formalne i automaty',
    description: 'Podstawowe pojęcia języków formalnych i automatów.',
    categoryId: 'c2',
    flashcards: [
      Flashcard(
        id: 'f4-1',
        question: 'Czym jest alfabet w teorii języków formalnych?',
        answer:
            'Skończony zbiór symboli, z których budowane są słowa, na przykład {a, b}.',
      ),
      Flashcard(
        id: 'f4-2',
        question: 'Co to jest słowo nad alfabetem?',
        answer:
            'Skończony ciąg symboli z alfabetu, na przykład aba lub pusty ciąg.',
      ),
      Flashcard(
        id: 'f4-3',
        question: 'Czym jest język formalny?',
        answer:
            'Dowolny zbiór słów nad danym alfabetem, na przykład wszystkie słowa z parzystą liczbą symboli a.',
      ),
      Flashcard(
        id: 'f4-4',
        question: 'Co to jest gramatyka formalna?',
        answer:
            'Czwórka (N, T, P, S) gdzie N to nieterminale, T terminale, P produkcje, S symbol startowy.',
      ),
      Flashcard(
        id: 'f4-5',
        question: 'Czym jest automat skończony (DFA)?',
        answer:
            'Model obliczeń złożony ze skończonej liczby stanów, opisujący rozpoznawanie języków regularnych.',
      ),
      Flashcard(
        id: 'f4-6',
        question: 'Czym różni się NFA od DFA?',
        answer:
            'NFA dopuszcza wiele przejść dla tego samego symbolu i stanu oraz przejścia epsilon, DFA ma jedno przejście deterministyczne.',
      ),
      Flashcard(
        id: 'f4-7',
        question: 'Jakiego typu języki rozpoznaje automat skończony?',
        answer: 'Języki regularne.',
      ),
      Flashcard(
        id: 'f4-8',
        question: 'Co to jest wyrażenie regularne?',
        answer:
            'Algebraiczny zapis języka regularnego z użyciem operatorów konkatenacji, alternatywy i domknięcia Kleenego.',
      ),
      Flashcard(
        id: 'f4-9',
        question: 'Czym jest automat ze stosem (PDA)?',
        answer:
            'Automat skończony rozszerzony o stos, zdolny do rozpoznawania języków bezkontekstowych.',
      ),
      Flashcard(
        id: 'f4-10',
        question: 'Jakie języki rozpoznaje automat ze stosem?',
        answer: 'Języki bezkontekstowe.',
      ),
      Flashcard(
        id: 'f4-11',
        question: 'Co to jest język bezkontekstowy?',
        answer:
            'Język generowany przez gramatykę bezkontekstową, w której produkcje mają postać A -> alfa.',
      ),
      Flashcard(
        id: 'f4-12',
        question: 'Czym jest maszyna Turinga?',
        answer:
            'Abstrakcyjny model obliczeń z nieskończoną taśmą, głowicą i skończonym zbiorem stanów, modeluje obliczalność.',
      ),
      Flashcard(
        id: 'f4-13',
        question: 'Wymień klasy języków w hierarchii Chomskyego.',
        answer:
            'Typ 3: regularne\nTyp 2: bezkontekstowe\nTyp 1: kontekstowe\nTyp 0: rekurencyjnie przeliczalne',
      ),
      Flashcard(
        id: 'f4-14',
        question: 'Co to jest problem stopu?',
        answer:
            'Problem określenia, czy dana maszyna Turinga zatrzyma się na danym wejściu, znany jako nierozstrzygalny.',
      ),
      Flashcard(
        id: 'f4-15',
        question: 'Czym jest domknięcie Kleenego dla zbioru słów?',
        answer:
            'Zbiór wszystkich skończonych konkatenacji słów z danego zbioru, włącznie z pustym słowem.',
      ),
      Flashcard(
        id: 'f4-16',
        question: 'Co oznacza, że klasa języków jest domknięta na operację?',
        answer:
            'Że wynik zastosowania operacji do języków z tej klasy również należy do tej klasy.',
      ),
      Flashcard(
        id: 'f4-17',
        question: 'Czym jest drzewo derivacji w gramatyce?',
        answer:
            'Drzewiasta reprezentacja kolejnych zastosowań produkcji od symbolu startowego do słowa terminalnego.',
      ),
      Flashcard(
        id: 'f4-18',
        question: 'Co to jest język deterministycznie bezkontekstowy?',
        answer:
            'Język bezkontekstowy rozpoznawany przez deterministyczny automat ze stosem.',
      ),
      Flashcard(
        id: 'f4-19',
        question: 'Czym jest lewostronna i prawostronna derivacja?',
        answer:
            'Lewostronna zawsze rozwija najbardziej lewy nieterminal, prawostronna najbardziej prawy.',
      ),
      Flashcard(
        id: 'f4-20',
        question: 'Co oznacza pojęcie rozstrzygalności problemu?',
        answer:
            'Istnieje algorytm, który dla każdego wejścia w skończonym czasie odpowiada tak lub nie.',
      ),
    ],
  ),

  // 5. Grafika komputerowa
  FlashcardSet(
    id: 's5',
    title: 'Grafika komputerowa - podstawy',
    description: 'Modele kolorów, rasteryzacja, wektory i renderowanie.',
    categoryId: 'c2',
    flashcards: [
      Flashcard(
        id: 'f5-1',
        question: 'Czym jest piksel?',
        answer:
            'Najmniejszy element obrazu rastrowego, reprezentujący pojedynczy punkt o określonym kolorze.',
      ),
      Flashcard(
        id: 'f5-2',
        question: 'Czym różni się grafika rastrowa od wektorowej?',
        answer:
            'Rastrowa przechowuje obraz jako siatkę pikseli, wektorowa jako obiekty geometryczne opisane wzorami.',
      ),
      Flashcard(
        id: 'f5-3',
        question: 'Co to jest rozdzielczość obrazu?',
        answer:
            'Liczba pikseli w poziomie i pionie, na przykład 1920 x 1080.',
      ),
      Flashcard(
        id: 'f5-4',
        question: 'Co to jest głębia koloru?',
        answer:
            'Liczba bitów używanych do reprezentacji koloru piksela, na przykład 24 bity dla RGB.',
      ),
      Flashcard(
        id: 'f5-5',
        question: 'Wymień popularne modele kolorów.',
        answer:
            'RGB, CMYK, HSV, HSL, YUV.',
      ),
      Flashcard(
        id: 'f5-6',
        question: 'Do czego używany jest model RGB?',
        answer:
            'Do opisu kolorów w urządzeniach świecących, takich jak monitory i ekrany.',
      ),
      Flashcard(
        id: 'f5-7',
        question: 'Do czego używany jest model CMYK?',
        answer:
            'W druku, do mieszania tuszy w kolorach cyjan, magenta, żółty i czarny.',
      ),
      Flashcard(
        id: 'f5-8',
        question: 'Czym jest tekstura w grafice 3D?',
        answer:
            'Obraz nakładany na powierzchnię obiektu 3D w celu nadania jej szczegółów.',
      ),
      Flashcard(
        id: 'f5-9',
        question: 'Co to jest mapowanie tekstur (texture mapping)?',
        answer:
            'Proces przypisywania współrzędnych tekstury punktom powierzchni obiektu 3D.',
      ),
      Flashcard(
        id: 'f5-10',
        question: 'Czym jest rasteryzacja?',
        answer:
            'Przekształcanie prymitywów geometrycznych (na przykład trójkątów) na piksele obrazu.',
      ),
      Flashcard(
        id: 'f5-11',
        question: 'Co to jest bufor głębi (Z-buffer)?',
        answer:
            'Struktura przechowująca informacje o odległości każdego piksela od kamery, służy do ukrywania niewidocznych powierzchni.',
      ),
      Flashcard(
        id: 'f5-12',
        question: 'Czym jest cieniowanie (shading)?',
        answer:
            'Wyznaczanie koloru pikseli na podstawie oświetlenia, materiału i geometrii powierzchni.',
      ),
      Flashcard(
        id: 'f5-13',
        question: 'Wymień przykładowe modele cieniowania.',
        answer:
            'Flat, Gouraud, Phong.',
      ),
      Flashcard(
        id: 'f5-14',
        question: 'Czym jest antyaliasing?',
        answer:
            'Technika wygładzania poszarpanych krawędzi poprzez odpowiednie próbkowanie i filtrowanie.',
      ),
      Flashcard(
        id: 'f5-15',
        question: 'Czym jest aliasing w grafice?',
        answer:
            'Zniekształcenia obrazu wynikające z niedostatecznego próbkowania sygnału.',
      ),
      Flashcard(
        id: 'f5-16',
        question: 'Co to jest pipeline renderingu?',
        answer:
            'Sekwencja etapów przetwarzania sceny 3D do obrazu 2D, na przykład transformacje, rasteryzacja, cieniowanie.',
      ),
      Flashcard(
        id: 'f5-17',
        question: 'Czym jest model oświetlenia Phonga?',
        answer:
            'Empiryczny model oświetlenia uwzględniający składową ambient, dyfuzyjną i lustrzaną.',
      ),
      Flashcard(
        id: 'f5-18',
        question: 'Co to jest ray tracing?',
        answer:
            'Metoda renderingu śledząca promienie światła w scenie, pozwalająca uzyskać realistyczne odbicia i cienie.',
      ),
      Flashcard(
        id: 'f5-19',
        question: 'Czym jest siatka trójkątów (mesh)?',
        answer:
            'Reprezentacja obiektu 3D jako zbioru połączonych wierzchołków tworzących trójkąty.',
      ),
      Flashcard(
        id: 'f5-20',
        question: 'Czym jest transformacja model-view-projection?',
        answer:
            'Łączne przekształcenie współrzędnych obiektu z przestrzeni modelu do przestrzeni ekranu za pomocą macierzy model, view i projection.',
      ),
    ],
  ),

    // Zestawy użytkownika (z ownerId)
  FlashcardSet(
    id: 's6',
    title: 'Moje fiszki z matematyki',
    description: 'Wzory i twierdzenia matematyczne.',
    categoryId: 'c1',
    flashcards: [
      Flashcard(
        id: 'f6-1',
        question: 'Co to jest pochodna?',
        answer: 'Miara szybkości zmiany funkcji.',
      ),
      Flashcard(
        id: 'f6-2',
        question: 'Wzór na pole koła',
        answer: 'πr²',
      ),
    ],
    ownerId: currentUserId, // Zestaw utworzony przez użytkownika
  ),

  FlashcardSet(
    id: 's7',
    title: 'Angielskie słówka',
    description: 'Codzienne zwroty po angielsku.',
    categoryId: 'c3',
    flashcards: [
      Flashcard(
        id: 'f7-1',
        question: 'Hello',
        answer: 'Cześć',
      ),
      Flashcard(
        id: 'f7-2',
        question: 'Thank you',
        answer: 'Dziękuję',
      ),
    ],
    ownerId: currentUserId, // Zestaw utworzony przez użytkownika
  ),

  
];