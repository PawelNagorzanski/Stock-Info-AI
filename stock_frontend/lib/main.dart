import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:interactive_chart/interactive_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
      ),
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
  List<CandleData> candles = []; // Klasa CandleData pochodzi z pakietu
  List<dynamic> newsData = [];
  bool isLoading = true;

  String currentSymbol = 'AAPL';
  String searchQuery = '';
  String currentRange = '1mo';
  String currentInterval = '1d';

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

  Future<void> fetchMarketData() async {
    setState(() {
      isLoading = true;
      candles = [];
    });
    try {
      final chartResponse = await http.get(
        Uri.parse(
          '$backendUrl/chart?symbol=$currentSymbol&range=$currentRange&interval=$currentInterval',
        ),
      );
      final newsResponse = await http.get(Uri.parse('$backendUrl/news'));

      if (chartResponse.statusCode == 200 && newsResponse.statusCode == 200) {
        final List<dynamic> rawChartData = json.decode(chartResponse.body);
        final List<CandleData> newCandles = rawChartData
            .map(
              (e) => CandleData(
                timestamp: DateTime.parse(e['date']).millisecondsSinceEpoch,
                high: (e['high'] as num).toDouble(),
                low: (e['low'] as num).toDouble(),
                open: (e['open'] as num).toDouble(),
                close: (e['close'] as num).toDouble(),
                volume: (e['volume'] as num).toDouble(),
              ),
            )
            .toList();

        newCandles.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        setState(() {
          candles = newCandles;
          newsData = json.decode(newsResponse.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTimeframeSelector() {
    final timeframes = {
      '1D': {'range': '10y', 'interval': '1d'},
      '1W': {'range': '10y', 'interval': '1wk'},
      '1M': {'range': '10y', 'interval': '1mo'},
    };

    return Wrap(
      spacing: 8.0,
      children: timeframes.entries.map((e) {
        final isSelected =
            currentRange == e.value['range'] &&
            currentInterval == e.value['interval'];
        return ChoiceChip(
          label: Text(
            e.key,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          selected: isSelected,
          selectedColor: Colors.blueAccent.withOpacity(0.3),
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (selected) {
            if (selected) {
              setState(() {
                currentRange = e.value['range']!;
                currentInterval = e.value['interval']!;
              });
              fetchMarketData();
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TRADING TERMINAL',
          style: TextStyle(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : Row(
              children: [
                // LEWA KOLUMNA
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    border: Border(right: BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 32,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'AI Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AI-powered strategies and analysis coming soon.',
                        style: TextStyle(color: Colors.grey[400], height: 1.5),
                      ),
                    ],
                  ),
                ),

                // ŚRODKOWA KOLUMNA
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentSymbol,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            _buildTimeframeSelector(),
                          ],
                        ),
                      ),

                      // CANDLESTICK CHART
                      Expanded(
                        flex: 3,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2A2A2A)),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: candles.isNotEmpty
                              ? InteractiveChart(
                                  candles: candles,
                                  style: const ChartStyle(
                                    priceGainColor: Colors.greenAccent,
                                    priceLossColor: Colors.redAccent,
                                    volumeColor: Color(0xFF2A2A2A),
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    'No data',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Text(
                          'News',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // NEWSY
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: newsData.length,
                          itemBuilder: (context, index) {
                            final news = newsData[index];
                            final DateTime date = DateTime.parse(news['date']);
                            final bool isPositive =
                                news['impact'] == 'Positive';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF2A2A2A),
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: isPositive
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  child: Icon(
                                    isPositive
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: isPositive
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                  ),
                                ),
                                title: Text(
                                  news['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // PRAWA KOLUMNA
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    border: Border(left: BorderSide(color: Color(0xFF2A2A2A))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Text(
                          'Instruments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search symbol...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2A2A2A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => searchQuery = value.toUpperCase()),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(
                                () =>
                                    currentSymbol = value.trim().toUpperCase(),
                              );
                              fetchMarketData();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: usStocks
                              .where(
                                (s) =>
                                    s['symbol']!.contains(searchQuery) ||
                                    s['name']!.toUpperCase().contains(
                                      searchQuery,
                                    ),
                              )
                              .map((stock) {
                                final isSelected =
                                    currentSymbol == stock['symbol'];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: isSelected
                                        ? Colors.blueAccent.withOpacity(0.15)
                                        : Colors.transparent,
                                  ),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    title: Text(
                                      stock['symbol']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.blueAccent
                                            : Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      stock['name']!,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(
                                        () => currentSymbol = stock['symbol']!,
                                      );
                                      fetchMarketData();
                                    },
                                  ),
                                );
                              })
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
