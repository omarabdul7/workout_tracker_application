import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/workout_instance.dart';

class WorkoutInstanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addWorkoutInstance(WorkoutInstance workoutInstance) {
    final collectionName = workoutInstance.name.replaceAll(' ', '_').toLowerCase();
    final workoutInstancesCollection = _firestore.collection(collectionName);

    return workoutInstancesCollection.add(workoutInstance.toJson());
  }

  Future<WorkoutInstance?> getLastWorkoutInstance(String workoutName) async {
    try {
      final collectionName = workoutName.replaceAll(' ', '_').toLowerCase();
      final workoutInstancesCollection = _firestore.collection(collectionName);

      final querySnapshot = await workoutInstancesCollection
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return WorkoutInstance.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching last workout instance: $e');
      return null;
    }
  }
}
