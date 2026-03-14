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
              timestamp: e['timestamp'],
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
      {'symbol': 'F', 'name': 'Ford Motor'},
      {'symbol': 'GE', 'name': 'General Electric'},
      {'symbol': 'KO', 'name': 'Coca-Cola'},
      {'symbol': 'PFE', 'name': 'Pfizer'},
      {'symbol': 'T', 'name': 'AT&T'},
      {'symbol': 'BAC', 'name': 'Bank of America'},
      {'symbol': 'WMT', 'name': 'Walmart'},
      {'symbol': 'JNJ', 'name': 'Johnson & Johnson'},
      {'symbol': 'PG', 'name': 'Procter & Gamble'},
      {'symbol': 'XOM', 'name': 'Exxon Mobil'},
    ];
    return usStocksData.map((data) => Stock(symbol: data['symbol']!, name: data['name']!)).toList();
  }
}
