import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:candlesticks/candlesticks.dart'; // Zastępuje fl_chart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giełda App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MarketScreen(),
    );
  }
}

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<Candle> candles = [];
  List<dynamic> newsData = [];
  bool isLoading = true;

  // Nowe zmienne dla interfejsu
  String currentSymbol = 'AAPL';
  String searchQuery = '';

  // Lista popularnych spółek US (darmowy Finnhub)
  final List<Map<String, String>> usStocks = [
    {'symbol': 'AAPL', 'name': 'Apple Inc.'},
    {'symbol': 'MSFT', 'name': 'Microsoft'},
    {'symbol': 'GOOGL', 'name': 'Alphabet (Google)'},
    {'symbol': 'AMZN', 'name': 'Amazon'},
    {'symbol': 'TSLA', 'name': 'Tesla'},
    {'symbol': 'NVDA', 'name': 'NVIDIA'},
    {'symbol': 'META', 'name': 'Meta Platforms'},
    {'symbol': 'NFLX', 'name': 'Netflix'},
    {'symbol': 'AMD', 'name': 'Advanced Micro Devices'},
    {'symbol': 'INTC', 'name': 'Intel'},
  ];

  final String backendUrl = 'http://localhost:5295/api/stock';

  @override
  void initState() {
    super.initState();
    fetchMarketData();
  }

  // Dodano przekazywanie symbolu do API
  Future<void> fetchMarketData() async {
    setState(() => isLoading = true);
    try {
      final chartResponse = await http.get(Uri.parse('$backendUrl/chart?symbol=$currentSymbol'));
      final newsResponse = await http.get(Uri.parse('$backendUrl/news'));

      if (chartResponse.statusCode == 200 && newsResponse.statusCode == 200) {
        final List<dynamic> rawChartData = json.decode(chartResponse.body);
        
        setState(() {
          candles = rawChartData.map((e) => Candle(
            date: DateTime.parse(e['date']),
            high: (e['high'] as num).toDouble(),
            low: (e['low'] as num).toDouble(),
            open: (e['open'] as num).toDouble(),
            close: (e['close'] as num).toDouble(),
            volume: (e['volume'] as num).toDouble(),
          )).toList().reversed.toList();
          
          newsData = json.decode(newsResponse.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Błąd: $e');
      setState(() => isLoading = false);
    }
  }
// ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal Inwestycyjny'),
        backgroundColor: Colors.blueGrey[900], // Bardziej "pro" kolor dla giełdy
        foregroundColor: Colors.white,
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Row(
              children: [
                // ==========================================
                // LEWA KOLUMNA - AI ASYSTENT (Zaślepka)
                // ==========================================
                Container(
                  width: 250, // Stała szerokość panelu bocznego
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(right: BorderSide(color: Colors.grey[300]!))
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.smart_toy, size: 40, color: Colors.blueAccent),
                        SizedBox(height: 16),
                        Text('AI Asystent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Tutaj w przyszłości pojawią się porady strategiczne generowane przez AI...'),
                      ],
                    ),
                  ),
                ),

                // ==========================================
                // ŚRODKOWA KOLUMNA - WYKRES I NEWSY (Expanded)
                // ==========================================
                Expanded(
                  child: Column(
                    children: [
 // GÓRNA CZĘŚĆ ŚRODKA - WYKRES
Expanded(
  flex: 3,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Text(
          'Wykres: $currentSymbol', 
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Candlesticks(candles: candles),
        ),
      ),
    ],
  ),
),
                      
                      const Divider(thickness: 2),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Lista newsów', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      
                      // DOLNA CZĘŚĆ ŚRODKA - NEWSY
                      Expanded(
                        flex: 2, // Mniej miejsca dla newsów
                        child: ListView.builder(
                          itemCount: newsData.length,
                          itemBuilder: (context, index) {
                            final news = newsData[index];
                            final DateTime date = DateTime.parse(news['date']);
                            final String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: Icon(
                                  Icons.article, 
                                  color: news['impact'] == 'Positive' ? Colors.green : Colors.red,
                                ),
                                title: Text(news['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('$formattedDate - Wpływ: ${news['impact']}'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ==========================================
                // PRAWA KOLUMNA - INSTRUMENTY (Zaślepka)
                // ==========================================
Container(
  width: 250,
  decoration: BoxDecoration(
    color: Colors.grey[100],
    border: Border(left: BorderSide(color: Colors.grey[300]!))
  ),
  child: Column(
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text('Instrumenty (USA)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Szukaj...',
            prefixIcon: Icon(Icons.search, size: 20),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) => setState(() => searchQuery = value.toUpperCase()),
        ),
      ),
      Expanded(
        child: ListView(
          children: usStocks
              .where((s) => s['symbol']!.contains(searchQuery) || s['name']!.toUpperCase().contains(searchQuery))
              .map((stock) => ListTile(
                    title: Text(stock['symbol']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(stock['name']!),
                    selected: currentSymbol == stock['symbol'],
                    selectedTileColor: Colors.blue.withOpacity(0.1),
                    onTap: () {
                      setState(() => currentSymbol = stock['symbol']!);
                      fetchMarketData(); // Pobiera dane dla nowego symbolu
                    },
                  ))
              .toList(),
        ),
      ),
    ],
  ),
),
              ],
            ),
    );
  }
}