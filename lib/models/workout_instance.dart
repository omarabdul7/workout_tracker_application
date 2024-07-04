class ExerciseInstance {
  final String name;
  final List<SetDetails> sets;

  ExerciseInstance({required this.name, required this.sets});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }

  factory ExerciseInstance.fromJson(Map<String, dynamic> json) {
    return ExerciseInstance(
      name: json['name'] as String,
      sets: (json['sets'] as List).map((e) => SetDetails.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class SetDetails {
  final int setNumber;
  double weight;
  int reps;

  SetDetails({required this.setNumber, required this.weight, required this.reps});

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
    };
  }

  factory SetDetails.fromJson(Map<String, dynamic> json) {
    return SetDetails(
      setNumber: json['setNumber'],
      weight: json['weight'],
      reps: json['reps'],
    );
  }
}

class WorkoutInstance {
  final String name;
  final List<ExerciseInstance> exercises;
  final DateTime createdAt;

  WorkoutInstance({required this.name, required this.exercises, required this.createdAt});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutInstance.fromJson(Map<String, dynamic> json) {
    return WorkoutInstance(
      name: json['name'] as String,
      exercises: (json['exercises'] as List).map((e) => ExerciseInstance.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
