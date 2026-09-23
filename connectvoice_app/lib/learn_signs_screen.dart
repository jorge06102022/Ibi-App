import 'package:flutter/material.dart';
import 'theme.dart';
import 'sign_emoji.dart';

class LearnSignsScreen extends StatelessWidget {
  const LearnSignsScreen({super.key});

  static const _order = [
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','ñ','o','p','q','r','s','t','u','v','w','x','y','z',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(title: const Text('Aprender Señas')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bg1,
              borderRadius: BorderRadius.circular(AppRadius.r3),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                Text('🤟', style: TextStyle(fontSize: 22)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alfabeto visual de apoyo con emoji. No es una traducción oficial '
                    'ni certificada a Lengua de Señas Colombiana (LSC).',
                    style: TextStyle(color: AppColors.tx2, fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _order.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (ctx, i) {
                final letter = _order[i];
                final emoji = signEmojiMap[letter] ?? '';
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.bg1,
                    borderRadius: BorderRadius.circular(AppRadius.r2),
                    border: Border.all(color: AppColors.border),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 8),
                      Text(letter.toUpperCase(),
                          style: const TextStyle(color: AppColors.tx1, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
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