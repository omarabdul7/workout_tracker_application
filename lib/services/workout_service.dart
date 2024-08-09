import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/workout.dart';

class WorkoutService {
  final CollectionReference workoutsCollection = FirebaseFirestore.instance.collection('workout_templates');

  Future<void> addWorkout(Workout workout) {
    return workoutsCollection.doc(workout.name).set(workout.toJson());
  }

  Stream<List<Workout>> getWorkouts() {
    return workoutsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Workout.fromJson(data);
      }).toList();
    });
  }

  Future<void> deleteWorkout(String workoutName) async {
    QuerySnapshot querySnapshot = await workoutsCollection.where('name', isEqualTo: workoutName).get();

    for (DocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
