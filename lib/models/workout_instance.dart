class ExerciseInstance {
  final String name;
  final List<SetDetails> sets;

  ExerciseInstance({required this.name, required this.sets});

  static final List<String> muscleGroups = [
    'tricep', 'chest', 'quadriceps', 'bicep', 'back', 'shoulders',
    'hamstrings', 'calves', 'glutes', 'core'
  ];

  static final Map<String, String> exerciseToMuscleGroup = {
    'bench press': 'chest',
    'benchpress': 'chest',
    'bench-press': 'chest',
    'push-up': 'chest',
    'pushup': 'chest',
    'push up': 'chest',
    'dumbell press': 'chest',
    'incline bench press': 'chest',
    'incline benchpress': 'chest',
    'incline bench-press': 'chest',
    'decline bench press': 'chest',
    'decline benchpress': 'chest',
    'decline bench-press': 'chest',
    'flat dumbell press': 'chest',
    'incline dumbell press': 'chest',
    'cable flies': 'chest',
    'tricep dip': 'tricep',
    'tricep dips': 'tricep',
    'dips': 'tricep',
    'dip': 'tricep',
    'shoulder press': 'shoulders',
    'overhead press': 'shoulders',
    'military press': 'shoulders',
    'shoulder presses': 'shoulders',
    'overhead presses': 'shoulders',
    'military presses': 'shoulders',
    'lateral raise': 'shoulders',
    'side raise': 'shoulders',
    'lateral raises': 'shoulders',
    'side raises': 'shoulders',
    'front raise': 'shoulders',
    'front raises': 'shoulders',
    'reverse fly': 'shoulders',
    'reverse flies': 'shoulders',
    'reverse flyes': 'shoulders',
    'rear delt fly': 'shoulders',
    'rear delt flies': 'shoulders',
    'bicep curl': 'bicep',
    'bicep curls': 'bicep',
    'curl': 'bicep',
    'curls': 'bicep',
    'hammer curl': 'bicep',
    'hammer curls': 'bicep',
    'pull-up': 'back',
    'pullup': 'back',
    'pull up': 'back',
    'pull ups': 'back',
    'chin-up': 'back',
    'chinup': 'back',
    'chin up': 'back',
    'lat pulldown': 'back',
    'lat pull down': 'back',
    'lat pulldowns': 'back',
    'pulldown': 'back',
    'pulldowns': 'back',
    'seated row': 'back',
    'seated rows': 'back',
    'row': 'back',
    'machine rows': 'back',
    'cable rows': 'back',
    'rows': 'back',
    'bent-over row': 'back',
    'bent over row': 'back',
    'bent-over rows': 'back',
    'bent over rows': 'back',
    'deadlift': 'hamstrings',
    'deadlifts': 'hamstrings',
    'romanian deadlift': 'hamstrings',
    'romanian deadlifts': 'hamstrings',
    'rdl': 'hamstrings',
    'leg curl': 'hamstrings',
    'leg curls': 'hamstrings',
    'leg-curl': 'hamstrings',
    'leg-curls': 'hamstrings',
    'squat': 'quadriceps',
    'squats': 'quadriceps',
    'leg press': 'quadriceps',
    'leg presses': 'quadriceps',
    'leg-press': 'quadriceps',
    'leg-presses': 'quadriceps',
    'lunge': 'quadriceps',
    'lunges': 'quadriceps',
    'step-up': 'quadriceps',
    'step up': 'quadriceps',
    'step-ups': 'quadriceps',
    'step ups': 'quadriceps',
    'calf raise': 'calves',
    'calf raises': 'calves',
    'calf-raise': 'calves',
    'calf-raises': 'calves',
    'seated calf raise': 'calves',
    'seated calf raises': 'calves',
    'seated-calf raise': 'calves',
    'seated-calf raises': 'calves',
    'glute bridge': 'glutes',
    'glute bridges': 'glutes',
    'hip thrust': 'glutes',
    'hip thrusts': 'glutes',
    'sumo deadlift': 'glutes',
    'sumo deadlifts': 'glutes',
    'leg abduction': 'glutes',
    'leg abductions': 'glutes',
    'plank': 'core',
    'planks': 'core',
    'sit-up': 'core',
    'situp': 'core',
    'sit up': 'core',
    'sit-ups': 'core',
    'situps': 'core',
    'sit ups': 'core',
    'crunch': 'core',
    'crunches': 'core',
    'leg raise': 'core',
    'leg raises': 'core',
    'leg-raise': 'core',
    'leg-raises': 'core',
    'russian twist': 'core',
    'russian twists': 'core',
    'russian-twist': 'core',
    'russian-twists': 'core',
    'bicycle crunch': 'core',
    'bicycle crunches': 'core',
    'bicycle-crunch': 'core',
    'bicycle-crunches': 'core',
  };

  String get muscleGroup {
    for (var group in muscleGroups) {
      if (name.toLowerCase().contains(group)) {
        return group;
      }
    }
    
    return exerciseToMuscleGroup[name.toLowerCase()] ?? 'unknown';
  }

  double get totalVolume {
    return sets.fold(0.0, (total, set) => total + (set.weight * set.reps));
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets.map((e) => e.toJson()).toList(),
      'muscleGroup': muscleGroup,
      'totalVolume': totalVolume,
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