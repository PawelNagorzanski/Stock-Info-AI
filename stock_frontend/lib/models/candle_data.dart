class CandleData {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final bool hasNews; // Flaga określająca obecność wiadomości

  CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.hasNews = false,
  });

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timestamp);
}
