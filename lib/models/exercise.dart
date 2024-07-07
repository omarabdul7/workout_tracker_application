class Exercise {
  final String name;
  final int sets;
  final int restPeriod; 

  Exercise({required this.name, required this.sets, required this.restPeriod});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'restPeriod': restPeriod,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      sets: json['sets'] as int? ?? 0,
      restPeriod: json['restPeriod'] as int? ?? 0,
    );
  }
}
