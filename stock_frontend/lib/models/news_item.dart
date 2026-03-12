class NewsItem {
  final DateTime date;
  final String title;
  final String impact;

  NewsItem({required this.date, required this.title, required this.impact});

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      impact: json['impact'] as String,
    );
  }

  bool get isPositive => impact == 'Positive';
}
