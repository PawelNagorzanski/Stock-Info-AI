import 'package:flutter/material.dart';
import 'package:interactive_chart/interactive_chart.dart';

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
    );
  }
}
