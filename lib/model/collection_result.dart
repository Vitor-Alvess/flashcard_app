class CollectionResult {
  String collectionTitle;
  int rightAnswers;
  int wrongAnswers;
  double percentage;
  DateTime resolvedAt;

  CollectionResult({
    required this.collectionTitle,
    required this.rightAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.resolvedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'collectionTitle': collectionTitle,
      'rightAnswers': rightAnswers,
      'wrongAnswers': wrongAnswers,
      'percentage': percentage,
      'resolvedAt': resolvedAt,
    };
  }

  factory CollectionResult.fromMap(Map<String, dynamic> map) {
    return CollectionResult(
      collectionTitle: map['collectionTitle'],
      rightAnswers: map['rightAnswers'],
      wrongAnswers: map['wrongAnswers'],
      percentage: map['percentages'],
      resolvedAt: map['resolvedAt'],
    );
  }
}
