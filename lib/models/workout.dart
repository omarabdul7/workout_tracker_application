class Workout {
  final String name;
  final List<Exercise> exercises;
  final DateTime createdAt;

  Workout({required this.name, required this.exercises, required this.createdAt});

  // Add these methods for Firebase integration
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      name: json['name'],
      exercises: (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

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
      name: json['name'],
      sets: json['sets'],
    );
  }
}