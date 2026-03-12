import 'package:flutter/material.dart';

class AiAssistantPanel extends StatelessWidget {
  const AiAssistantPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        border: Border(right: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 32,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 20),
          const Text(
            'AI Assistant',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AI-powered strategies and analysis coming soon.',
            style: TextStyle(color: Colors.grey[400], height: 1.5),
          ),
        ],
      ),
    );
  }
}
