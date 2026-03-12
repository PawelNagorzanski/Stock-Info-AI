import 'package:flutter/material.dart';

class Timeframe {
  final String label;
  final String range;
  final String interval;

  const Timeframe(
      {required this.label, required this.range, required this.interval});
}

const List<Timeframe> timeframes = [
  Timeframe(label: '1D', range: '10y', interval: '1d'),
  Timeframe(label: '1W', range: '10y', interval: '1wk'),
  Timeframe(label: '1M', range: '10y', interval: '1mo'),
];

class TimeframeSelector extends StatelessWidget {
  final String currentRange;
  final String currentInterval;
  final Function(String, String) onSelect;

  const TimeframeSelector({
    super.key,
    required this.currentRange,
    required this.currentInterval,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: timeframes.map((timeframe) {
        final isSelected = currentRange == timeframe.range &&
            currentInterval == timeframe.interval;
        return ChoiceChip(
          label: Text(
            timeframe.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          selected: isSelected,
          selectedColor: Colors.blueAccent.withOpacity(0.3),
          backgroundColor: const Color(0xFF2A2A2A),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onSelected: (selected) {
            if (selected) {
              onSelect(timeframe.range, timeframe.interval);
            }
          },
        );
      }).toList(),
    );
  }
}

