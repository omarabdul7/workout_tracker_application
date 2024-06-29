import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/workout.dart';

class WorkoutService {
  final CollectionReference workoutsCollection = FirebaseFirestore.instance.collection('workouts');

  Future<void> addWorkout(Workout workout) {
    return workoutsCollection.add(workout.toJson());
  }

  Stream<List<Workout>> getWorkouts() {
    return workoutsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Workout.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}