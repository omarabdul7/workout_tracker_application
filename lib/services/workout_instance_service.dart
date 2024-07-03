import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/workout_instance.dart';

class WorkoutInstanceService {
  final CollectionReference workoutInstancesCollection = FirebaseFirestore.instance.collection('workout_instances');

  Future<void> addWorkoutInstance(WorkoutInstance workoutInstance) {
    return workoutInstancesCollection.add(workoutInstance.toJson());
  }

  Stream<List<WorkoutInstance>> getWorkoutInstances() {
    return workoutInstancesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return WorkoutInstance.fromJson(data);
      }).toList();
    });
  }
}
