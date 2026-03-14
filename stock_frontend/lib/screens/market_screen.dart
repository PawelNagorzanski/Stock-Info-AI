import 'package:flutter/material.dart';
import '../models/candle_data.dart';
import '../models/news_item.dart';
import '../models/stock.dart';
import '../services/market_service.dart';
import '../widgets/ai_assistant_panel.dart';
import '../widgets/chart_panel.dart';
import '../widgets/instrument_list.dart';
import '../widgets/news_list.dart';
import '../widgets/timeframe_selector.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _marketService = MarketService();

  List<CandleData> _candles = [];
  List<NewsItem> _news = [];
  late List<Stock> _stocks;
  bool _isLoading = true;

  String _currentSymbol = 'AAPL';
  String _searchQuery = '';
  String _currentRange = '10y';
  String _currentInterval = '1wk';

  @override
  void initState() {
    super.initState();
    _stocks = _marketService.getUsStocks();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final newsFuture = _marketService.fetchNews();
      final candlesFuture = _marketService.fetchChartData(
        symbol: _currentSymbol,
        range: _currentRange,
        interval: _currentInterval,
      );

      final results = await Future.wait([candlesFuture, newsFuture]);

      final candles = results[0] as List<CandleData>;
      final news = results[1] as List<NewsItem>;

      // Mark candles that have news on the same day
      final markedCandles = _marketService.markCandlesWithNews(candles, news);

      setState(() {
        _candles = markedCandles;
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      // Prosta obsługa błędów, można rozbudować o pokazywanie komunikatu
      setState(() => _isLoading = false);
      // ignore: avoid_print
      print('Error fetching data: $e');
    }
  }

  void _onTimeframeSelected(String newRange, String newInterval) {
    setState(() {
      _currentRange = newRange;
      _currentInterval = newInterval;
    });
    _fetchData();
  }

  void _onSymbolSelected(String newSymbol) {
    setState(() {
      _currentSymbol = newSymbol;
    });
    _fetchData();
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : Row(
              children: [
                const AiAssistantPanel(),
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
                              _currentSymbol,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            TimeframeSelector(
                              currentRange: _currentRange,
                              currentInterval: _currentInterval,
                              onSelect: _onTimeframeSelected,
                            ),
                          ],
                        ),
                      ),
                      ChartPanel(candles: _candles),
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
                      NewsList(newsData: _news),
                    ],
                  ),
                ),
                InstrumentList(
                  stocks: _stocks,
                  searchQuery: _searchQuery,
                  currentSymbol: _currentSymbol,
                  onSearchChanged: (value) =>
                      setState(() => _searchQuery = value.toUpperCase()),
                  onSymbolSelected: _onSymbolSelected,
                  onSearchSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _onSymbolSelected(value.trim().toUpperCase());
                    }
                  },
                ),
              ],
            ),
    );
  }
}
