import 'package:flutter/material.dart';

class HighlightCard extends StatelessWidget {
  const HighlightCard({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFF7A2EFF),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(height: 1.5, color: Color(0xFF5F5873)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
