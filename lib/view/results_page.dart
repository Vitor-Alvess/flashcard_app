import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int percentage;

  const ResultsPage({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.percentage,
  });

  ResultData _getResultData() {
    if (percentage >= 81) {
      return ResultData(
        title: "Miau!",
        message: "Você acertou todas as perguntas!! Sensacional!",
        stars: 5,
        imagePath: "assets/images/results/perfect.png",
      );
    } else if (percentage >= 61) {
      return ResultData(
        title: "Parabéns!",
        message:
            "Você acertou $correctAnswers/$totalQuestions, um resultado incrível! Continue assim!",
        stars: 4,
        imagePath: "assets/images/results/high.png",
      );
    } else if (percentage >= 41) {
      return ResultData(
        title: "Quase lá!",
        message:
            "Você acertou $correctAnswers/$totalQuestions, um resultado ótimo! Continue assim!",
        stars: 3,
        imagePath: "assets/images/results/medium.png",
      );
    } else if (percentage >= 21) {
      return ResultData(
        title: "Dá pra melhorar!",
        message:
            "Você acertou $correctAnswers/$totalQuestions, um bom começo, mas dá pra ficar melhor!",
        stars: 2,
        imagePath: "assets/images/results/low.png",
      );
    } else {
      return ResultData(
        title: "Puts!",
        message:
            "Você acertou $correctAnswers/$totalQuestions, mas não desista!",
        stars: 1,
        imagePath: "assets/images/results/zero.png",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultData = _getResultData();

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("Grupo A", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(221, 90, 90, 90),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < resultData.stars ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                resultData.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                resultData.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Image.asset(
                resultData.imagePath,
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Fechar",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultData {
  final String title;
  final String message;
  final int stars;
  final String imagePath;

  ResultData({
    required this.title,
    required this.message,
    required this.stars,
    required this.imagePath,
  });
}
