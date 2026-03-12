import 'package:flutter/material.dart';

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

  static const Map<String, Map<String, String>> timeframes = {
    '1D': {'range': '10y', 'interval': '1d'},
    '1W': {'range': '10y', 'interval': '1wk'},
    '1M': {'range': '10y', 'interval': '1mo'},
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: timeframes.entries.map((e) {
        final isSelected =
            currentRange == e.value['range'] && currentInterval == e.value['interval'];
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
              onSelect(e.value['range']!, e.value['interval']!);
            }
          },
        );
      }).toList(),
    );
  }
}

