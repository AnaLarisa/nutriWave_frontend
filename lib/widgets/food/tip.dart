import 'package:flutter/material.dart';

class Tip extends StatelessWidget {
  final String text;

  const Tip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3fc97c),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white70 
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
