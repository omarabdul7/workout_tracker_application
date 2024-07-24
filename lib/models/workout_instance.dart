class ExerciseInstance {
  final String name;
  final List<SetDetails> sets;

  ExerciseInstance({required this.name, required this.sets});

  static final List<String> muscleGroups = [
    'tricep', 'chest', 'quadriceps', 'bicep', 'back', 'shoulders',
    'hamstrings', 'calves', 'glutes', 'core'
  ];

  static final Map<String, Map<String, dynamic>> exerciseDetails = {
    'bench press': {'muscleGroup': 'chest', 'isUnilateral': false},
    'benchpress': {'muscleGroup': 'chest', 'isUnilateral': false},
    'bench-press': {'muscleGroup': 'chest', 'isUnilateral': false},
    'push-up': {'muscleGroup': 'chest', 'isUnilateral': false},
    'pushup': {'muscleGroup': 'chest', 'isUnilateral': false},
    'push up': {'muscleGroup': 'chest', 'isUnilateral': false},
    'dumbell press': {'muscleGroup': 'chest', 'isUnilateral': true},
    'incline bench press': {'muscleGroup': 'chest', 'isUnilateral': false},
    'incline benchpress': {'muscleGroup': 'chest', 'isUnilateral': false},
    'incline bench-press': {'muscleGroup': 'chest', 'isUnilateral': false},
    'decline bench press': {'muscleGroup': 'chest', 'isUnilateral': false},
    'decline benchpress': {'muscleGroup': 'chest', 'isUnilateral': false},
    'decline bench-press': {'muscleGroup': 'chest', 'isUnilateral': false},
    'flat dumbell press': {'muscleGroup': 'chest', 'isUnilateral': true},
    'incline dumbell press': {'muscleGroup': 'chest', 'isUnilateral': true},
    'cable flies': {'muscleGroup': 'chest', 'isUnilateral': true},
    'tricep dip': {'muscleGroup': 'tricep', 'isUnilateral': false},
    'tricep dips': {'muscleGroup': 'tricep', 'isUnilateral': false},
    'dips': {'muscleGroup': 'tricep', 'isUnilateral': false},
    'dip': {'muscleGroup': 'tricep', 'isUnilateral': false},
    'shoulder press': {'muscleGroup': 'shoulders', 'isUnilateral': false},
    'overhead press': {'muscleGroup': 'shoulders', 'isUnilateral': false},
    'military press': {'muscleGroup': 'shoulders', 'isUnilateral': false},
    'shoulder presses': {'muscleGroup': 'shoulders', 'isUnilateral': false},
    'overhead presses': {'muscleGroup': 'shoulders', 'isUnilateral': false},
    'military presses': {'muscleGroup': 'shoulders', 'isUnilateral': false},
    'lateral raise': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'side raise': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'lateral raises': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'side raises': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'front raise': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'front raises': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'reverse fly': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'reverse flies': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'reverse flyes': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'rear delt fly': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'rear delt flies': {'muscleGroup': 'shoulders', 'isUnilateral': true},
    'bicep curl': {'muscleGroup': 'bicep', 'isUnilateral': true},
    'bicep curls': {'muscleGroup': 'bicep', 'isUnilateral': true},
    'curl': {'muscleGroup': 'bicep', 'isUnilateral': true},
    'curls': {'muscleGroup': 'bicep', 'isUnilateral': true},
    'hammer curl': {'muscleGroup': 'bicep', 'isUnilateral': true},
    'hammer curls': {'muscleGroup': 'bicep', 'isUnilateral': true},
    'pull-up': {'muscleGroup': 'back', 'isUnilateral': false},
    'pullup': {'muscleGroup': 'back', 'isUnilateral': false},
    'pull up': {'muscleGroup': 'back', 'isUnilateral': false},
    'pull ups': {'muscleGroup': 'back', 'isUnilateral': false},
    'chin-up': {'muscleGroup': 'back', 'isUnilateral': false},
    'chinup': {'muscleGroup': 'back', 'isUnilateral': false},
    'chin up': {'muscleGroup': 'back', 'isUnilateral': false},
    'lat pulldown': {'muscleGroup': 'back', 'isUnilateral': false},
    'lat pull down': {'muscleGroup': 'back', 'isUnilateral': false},
    'lat pulldowns': {'muscleGroup': 'back', 'isUnilateral': false},
    'pulldown': {'muscleGroup': 'back', 'isUnilateral': false},
    'pulldowns': {'muscleGroup': 'back', 'isUnilateral': false},
    'seated row': {'muscleGroup': 'back', 'isUnilateral': false},
    'seated rows': {'muscleGroup': 'back', 'isUnilateral': false},
    'row': {'muscleGroup': 'back', 'isUnilateral': true},
    'machine rows': {'muscleGroup': 'back', 'isUnilateral': false},
    'cable rows': {'muscleGroup': 'back', 'isUnilateral': false},
    'rows': {'muscleGroup': 'back', 'isUnilateral': false},
    'bent-over row': {'muscleGroup': 'back', 'isUnilateral': true},
    'bent over row': {'muscleGroup': 'back', 'isUnilateral': true},
    'bent-over rows': {'muscleGroup': 'back', 'isUnilateral': true},
    'bent over rows': {'muscleGroup': 'back', 'isUnilateral': true},
    'deadlift': {'muscleGroup': 'hamstrings', 'isUnilateral': false},
    'deadlifts': {'muscleGroup': 'hamstrings', 'isUnilateral': false},
    'romanian deadlift': {'muscleGroup': 'hamstrings', 'isUnilateral': false},
    'romanian deadlifts': {'muscleGroup': 'hamstrings', 'isUnilateral': false},
    'rdl': {'muscleGroup': 'hamstrings', 'isUnilateral': false},
    'leg curl': {'muscleGroup': 'hamstrings', 'isUnilateral': true},
    'leg curls': {'muscleGroup': 'hamstrings', 'isUnilateral': true},
    'leg-curl': {'muscleGroup': 'hamstrings', 'isUnilateral': true},
    'leg-curls': {'muscleGroup': 'hamstrings', 'isUnilateral': true},
    'squat': {'muscleGroup': 'quadriceps', 'isUnilateral': false},
    'squats': {'muscleGroup': 'quadriceps', 'isUnilateral': false},
    'leg press': {'muscleGroup': 'quadriceps', 'isUnilateral': false},
    'leg presses': {'muscleGroup': 'quadriceps', 'isUnilateral': false},
    'leg-press': {'muscleGroup': 'quadriceps', 'isUnilateral': false},
    'leg-presses': {'muscleGroup': 'quadriceps', 'isUnilateral': false},
    'lunge': {'muscleGroup': 'quadriceps', 'isUnilateral': true},
    'lunges': {'muscleGroup': 'quadriceps', 'isUnilateral': true},
    'step-up': {'muscleGroup': 'quadriceps', 'isUnilateral': true},
    'step up': {'muscleGroup': 'quadriceps', 'isUnilateral': true},
    'step-ups': {'muscleGroup': 'quadriceps', 'isUnilateral': true},
    'step ups': {'muscleGroup': 'quadriceps', 'isUnilateral': true},
    'calf raise': {'muscleGroup': 'calves', 'isUnilateral': true},
    'calf raises': {'muscleGroup': 'calves', 'isUnilateral': true},
    'calf-raise': {'muscleGroup': 'calves', 'isUnilateral': true},
    'calf-raises': {'muscleGroup': 'calves', 'isUnilateral': true},
    'seated calf raise': {'muscleGroup': 'calves', 'isUnilateral': false},
    'seated calf raises': {'muscleGroup': 'calves', 'isUnilateral': false},
    'seated-calf raise': {'muscleGroup': 'calves', 'isUnilateral': false},
    'seated-calf raises': {'muscleGroup': 'calves', 'isUnilateral': false},
    'glute bridge': {'muscleGroup': 'glutes', 'isUnilateral': false},
    'glute bridges': {'muscleGroup': 'glutes', 'isUnilateral': false},
    'hip thrust': {'muscleGroup': 'glutes', 'isUnilateral': false},
    'hip thrusts': {'muscleGroup': 'glutes', 'isUnilateral': false},
    'sumo deadlift': {'muscleGroup': 'glutes', 'isUnilateral': false},
    'sumo deadlifts': {'muscleGroup': 'glutes', 'isUnilateral': false},
    'leg abduction': {'muscleGroup': 'glutes', 'isUnilateral': true},
    'leg abductions': {'muscleGroup': 'glutes', 'isUnilateral': true},
    'plank': {'muscleGroup': 'core', 'isUnilateral': false},
    'planks': {'muscleGroup': 'core', 'isUnilateral': false},
    'sit-up': {'muscleGroup': 'core', 'isUnilateral': false},
    'situp': {'muscleGroup': 'core', 'isUnilateral': false},
    'sit up': {'muscleGroup': 'core', 'isUnilateral': false},
    'sit-ups': {'muscleGroup': 'core', 'isUnilateral': false},
    'situps': {'muscleGroup': 'core', 'isUnilateral': false},
    'sit ups': {'muscleGroup': 'core', 'isUnilateral': false},
    'crunch': {'muscleGroup': 'core', 'isUnilateral': false},
    'crunches': {'muscleGroup': 'core', 'isUnilateral': false},
    'leg raise': {'muscleGroup': 'core', 'isUnilateral': false},
    'leg raises': {'muscleGroup': 'core', 'isUnilateral': false},
    'leg-raise': {'muscleGroup': 'core', 'isUnilateral': false},
    'leg-raises': {'muscleGroup': 'core', 'isUnilateral': false},
    'russian twist': {'muscleGroup': 'core', 'isUnilateral': false},
    'russian twists': {'muscleGroup': 'core', 'isUnilateral': false},
    'russian-twist': {'muscleGroup': 'core', 'isUnilateral': false},
    'russian-twists': {'muscleGroup': 'core', 'isUnilateral': false},
    'bicycle crunch': {'muscleGroup': 'core', 'isUnilateral': false},
    'bicycle crunches': {'muscleGroup': 'core', 'isUnilateral': false},
    'bicycle-crunch': {'muscleGroup': 'core', 'isUnilateral': false},
    'bicycle-crunches': {'muscleGroup': 'core', 'isUnilateral': false},
  };

  String get muscleGroup {
    return exerciseDetails[name.toLowerCase()]?['muscleGroup'] ?? 'unknown';
  }

  bool get isUnilateral {
    return exerciseDetails[name.toLowerCase()]?['isUnilateral'] ?? false;
  }

  double get totalVolume {
    double volume = sets.fold(0.0, (total, set) => total + (set.weight * set.reps));
    return isUnilateral ? volume * 2 : volume;
  }

  double calculateOneRepMax(double weight, int reps) {
    return weight / (1.0278 - 0.0278 * reps);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((e) => e.toJson()).toList(),
      'muscleGroup': muscleGroup,
      'totalVolume': totalVolume,
      'isUnilateral': isUnilateral,
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
  int setNumber;
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