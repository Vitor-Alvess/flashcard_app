import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Text(
              "Nenhum histórico ainda",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Seus resultados de estudo aparecerão aqui",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

