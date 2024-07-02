class Exercise {
  final String name;
  final int sets;

  Exercise({required this.name, required this.sets});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: json['sets'] as int,
    );
  }
}
