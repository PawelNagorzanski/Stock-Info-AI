import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/candle_data.dart';

class ChartPanel extends StatelessWidget {
  final List<CandleData> candles;

  const ChartPanel({super.key, required this.candles});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
            ? SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: DateTimeAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  minimum: _getMin(),
                  maximum: _getMax(),
                ),
                series: <CartesianSeries>[
                  // Główna warstwa: świece
                  CandleSeries<CandleData, DateTime>(
                    dataSource: candles,
                    xValueMapper: (data, _) => data.date,
                    lowValueMapper: (data, _) => data.low,
                    highValueMapper: (data, _) => data.high,
                    openValueMapper: (data, _) => data.open,
                    closeValueMapper: (data, _) => data.close,
                    bullColor: Colors.greenAccent,
                    bearColor: Colors.redAccent,
                  ),
                  // Druga warstwa: markery wiadomości
                  ScatterSeries<CandleData, DateTime>(
                    dataSource: candles.where((c) => c.hasNews).toList(),
                    xValueMapper: (data, _) => data.date,
                    // Wyświetla punkt nad świecą
                    yValueMapper: (data, _) =>
                        data.high + (_getMax() - _getMin()) * 0.05,
                    color: Colors.blueAccent,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                    ),
                    onPointTap: (ChartPointDetails details) {
                      // Akcja po kliknięciu znacznika
                    },
                  ),
                ],
              )
            : const Center(
                child: Text('No data', style: TextStyle(color: Colors.grey)),
              ),
      ),
    );
  }

  double _getMin() => candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
  double _getMax() =>
      candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
}
