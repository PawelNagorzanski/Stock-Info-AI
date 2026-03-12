import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:interactive_chart/interactive_chart.dart';
import '../models/news_item.dart';
import '../models/stock.dart';

class MarketService {
  final String _backendUrl = 'http://localhost:5295/api/stock';

  Future<List<CandleData>> fetchChartData({
    required String symbol,
    required String range,
    required String interval,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$_backendUrl/chart?symbol=$symbol&range=$range&interval=$interval',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawChartData = json.decode(response.body);
      final List<CandleData> candles = rawChartData
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
      candles.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return candles;
    } else {
      throw Exception('Failed to load chart data');
    }
  }

  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(Uri.parse('$_backendUrl/news'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NewsItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }

  List<Stock> getUsStocks() {
    const List<Map<String, String>> usStocksData = [
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
    return usStocksData.map((data) => Stock(symbol: data['symbol']!, name: data['name']!)).toList();
  }
}
