import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

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
  List<dynamic> chartData = [];
  List<dynamic> newsData = [];
  bool isLoading = true;

  final String backendUrl = 'http://localhost:5295/api/stock'; 

  @override
  void initState() {
    super.initState();
    fetchMarketData();
  }

  Future<void> fetchMarketData() async {
    try {
      final chartResponse = await http.get(Uri.parse('$backendUrl/chart'));
      final newsResponse = await http.get(Uri.parse('$backendUrl/news'));

      if (chartResponse.statusCode == 200 && newsResponse.statusCode == 200) {
        setState(() {
          chartData = json.decode(chartResponse.body);
          newsData = json.decode(newsResponse.body);
          isLoading = false; 
        });
      }
    } catch (e) {
      print('Błąd pobierania danych: $e');
    }
  }

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
                        flex: 3, // Flex 3 oznacza, że wykres zajmie więcej miejsca niż newsy
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true),
                              titlesData: const FlTitlesData(
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), 
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: chartData.asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), (e.value['price'] as num).toDouble());
                                  }).toList(),
                                  isCurved: true,
                                  color: Colors.blueAccent,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          ),
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
                  child: ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Instrumenty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ListTile(title: Text('USD/PLN'), leading: Icon(Icons.show_chart)),
                      ListTile(title: Text('EUR/USD'), leading: Icon(Icons.show_chart)),
                      ListTile(title: Text('S&P 500'), leading: Icon(Icons.show_chart)),
                      ListTile(title: Text('WIG20'), leading: Icon(Icons.show_chart)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}