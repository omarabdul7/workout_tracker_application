
class Workout {
  final List<Exercise> exercises;

  Workout({required this.exercises});
}

class Exercise {
  final String name;
  final int sets;

  Exercise({required this.name, required this.sets});
}
