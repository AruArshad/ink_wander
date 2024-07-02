class Prompt {
  final String prompt;
  final String category;
  final String userId;
  final DateTime createdAt;
  final bool isFavorite;

  Prompt({
    required this.prompt,
    required this.category,
    required this.userId,
    required this.createdAt,
    this.isFavorite = false
  });

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'category': category,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch, // Store timestamps in milliseconds
      'isFavorite': isFavorite,
    };
  }
}