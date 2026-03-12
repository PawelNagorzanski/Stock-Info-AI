import 'package:flutter/material.dart';
import '../models/stock.dart';

class InstrumentList extends StatelessWidget {
  final List<Stock> stocks;
  final String searchQuery;
  final String currentSymbol;
  final Function(String) onSearchChanged;
  final Function(String) onSymbolSelected;
  final Function(String) onSearchSubmitted;

  const InstrumentList({
    super.key,
    required this.stocks,
    required this.searchQuery,
    required this.currentSymbol,
    required this.onSearchChanged,
    required this.onSymbolSelected,
    required this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final filteredStocks = stocks
        .where(
          (s) =>
              s.symbol.toUpperCase().contains(searchQuery) ||
              s.name.toUpperCase().contains(searchQuery),
        )
        .toList();

    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(left: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'Instruments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search symbol...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.grey[400],
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                ),
              ),
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: filteredStocks.length,
              itemBuilder: (context, index) {
                final stock = filteredStocks[index];
                final isSelected = currentSymbol == stock.symbol;
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? Colors.blueAccent.withOpacity(0.15)
                        : Colors.transparent,
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(
                      stock.symbol,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blueAccent : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      stock.name,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                    onTap: () => onSymbolSelected(stock.symbol),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
