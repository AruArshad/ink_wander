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

  factory Prompt.fromMap(Map<String, dynamic> data) => Prompt(
        prompt: data['prompt'] as String,
        category: data['category'] as String,
        userId: data['userId'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
        isFavorite: data['isFavorite'] as bool,
      );

  Map<String, dynamic> toMap() {
    return {
      'prompt': prompt,
      'category': category,
      'userId': userId,
      'createdAt': createdAt.millisecondsSinceEpoch, // Store timestamps in milliseconds
      'isFavorite': isFavorite,
    };
  }

  Prompt copyWith({
    String? prompt, // Make prompt optional
    String? category, // Make category optional
    String? userId, // Make userId optional
    DateTime? createdAt, // Make createdAt optional
    bool? isFavorite,
  }) {
    return Prompt(
      prompt: prompt ?? this.prompt, // Use provided prompt if available, otherwise use existing value
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite
    );
  }

}