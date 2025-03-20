import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart' as far;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

/// A service that handles tracking movement metrics like step count, distance, and pace.
/// It uses pedometer for step counting and geolocator for distance tracking.

class MovementTrackingService with ChangeNotifier {
  // MARK: - Streams
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;
  Stream<Position>? _positionStream;
  Stream<far.Activity>? _activityStream;

  // MARK: - Subscriptions
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<far.Activity>? _activitySubscription;

  // MARK: - Activity Recognition
  final far.FlutterActivityRecognition _activityRecognition = far.FlutterActivityRecognition.instance;

  // MARK: - State
  bool _isTracking = false;
  int _steps = 0;
  int _stepsAtStart = 0;
  double _distance = 0.0; // in meters
  double _pace = 0.0; // min/km
  String _activity = 'unknown';
  bool _isMoving = false;
  double _caloriesBurned = 0.0;
  DateTime? _startTime;
  Duration _activeDuration = Duration.zero;
  Timer? _durationTimer;

  // List of positions for more accurate distance calculation
  final List<Position> _positions = [];

  // MARK: - Getters
  bool get isTracking => _isTracking;
  int get steps => _steps;
  double get distance => _distance;
  double get distanceKm => _distance / 1000;
  double get distanceMiles => _distance / 1609.34;
  double get pace => _pace;
  String get paceFormatted => _formatPace();
  String get activity => _activity;
  bool get isMoving => _isMoving;
  double get caloriesBurned => _caloriesBurned;
  String get activeDurationFormatted => _formatDuration(_activeDuration);

  // MARK: - Initialization
  /// Initialize the tracking service and request necessary permissions.
  Future<bool> initialize() async {
    // Request location permissions
    bool locationPermissionGranted = await _requestLocationPermission();
    if (!locationPermissionGranted) {
      return false;
    }

    // Request activity recognition permission if on Android
    if (Platform.isAndroid) {
      bool activityPermissionGranted = await _requestActivityRecognitionPermission();
      if (!activityPermissionGranted) {
        return false;
      }
    }

    // Initialize pedometer streams
    try {
      _stepCountStream = await Pedometer.stepCountStream;
      _pedestrianStatusStream = await Pedometer.pedestrianStatusStream;
    } catch (e) {
      debugPrint('Error initializing pedometer: $e');
    }

    return true;
  }

  // MARK: - Permission requests
  Future<bool> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show message or handle
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show message or handle
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return false;
    }

    // Permissions are granted
    return true;
  }

  Future<bool> _requestActivityRecognitionPermission() async {
    // Check if the activity recognition permission is already granted
    far.ActivityPermission permission = await _activityRecognition.checkPermission();
    
    if (permission == far.ActivityPermission.DENIED) {
      // Request permission
      permission = await _activityRecognition.requestPermission();
      return permission == far.ActivityPermission.GRANTED;
    }
    
    return permission == far.ActivityPermission.GRANTED;
  }

  // MARK: - Tracking methods
  /// Start tracking movement.
  Future<void> startTracking() async {
    if (_isTracking) return;

    _isTracking = true;
    _startTime = DateTime.now();
    _activeDuration = Duration.zero;
    _steps = 0;
    _stepsAtStart = 0;
    _distance = 0.0;
    _pace = 0.0;
    _caloriesBurned = 0.0;
    _positions.clear();

    // Start duration timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isMoving) {
        _activeDuration = _activeDuration + const Duration(seconds: 1);
        notifyListeners();
      }
    });

    // Start tracking steps
    _stepCountSubscription = _stepCountStream?.listen(_onStepCount);

    // Start tracking pedestrian status
    _pedestrianStatusSubscription = _pedestrianStatusStream?.listen(
      _onPedestrianStatusChanged,
      onError: _onPedestrianStatusError,
    );

    // Start location tracking with high accuracy
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
      ),
    );
    _positionSubscription = _positionStream?.listen(_onPositionUpdate);

    // Start activity recognition
    try {
      _activityStream = _activityRecognition.activityStream;
      _activitySubscription = _activityStream?.listen(_onActivityRecognized);
    } catch (e) {
      debugPrint('Error starting activity recognition: $e');
    }

    notifyListeners();
  }

  /// Stop tracking movement.
  void stopTracking() {
    if (!_isTracking) return;

    _isTracking = false;
    _durationTimer?.cancel();
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _positionSubscription?.cancel();
    _activitySubscription?.cancel();

    notifyListeners();
  }

  // MARK: - Event handlers
  void _onStepCount(StepCount event) {
    // If this is the first step count event, store the initial step count
    if (_stepsAtStart == 0) {
      _stepsAtStart = event.steps;
    }
    
    // Calculate steps taken since tracking started
    _steps = event.steps - _stepsAtStart;
    
    // Update calories
    _updateCaloriesBurned();
    
    notifyListeners();
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _isMoving = event.status == 'walking';
    notifyListeners();
  }

  void _onPositionUpdate(Position position) {
    if (_positions.isEmpty) {
      _positions.add(position);
      return;
    }

    // Add new position to the list
    final previousPosition = _positions.last;
    _positions.add(position);

    // Calculate distance between this position and the previous one
    final distanceDelta = Geolocator.distanceBetween(
      previousPosition.latitude,
      previousPosition.longitude,
      position.latitude,
      position.longitude,
    );

    // Only add distance if it's reasonable (avoid GPS jumps)
    if (distanceDelta < 100) { // Filter out jumps over 100 meters
      _distance += distanceDelta;
    }

    // Update pace (min/km) if we've moved a significant distance
    if (_distance > 10) {
      // Calculate pace in minutes per kilometer
      final durationMinutes = _activeDuration.inSeconds / 60;
      if (durationMinutes > 0) {
        _pace = durationMinutes / (_distance / 1000);
      }
    }

    notifyListeners();
  }

  void _onActivityRecognized(far.Activity activity) {
    // Map the activity to a simple string
    switch (activity.type) {
      case far.ActivityType.WALKING:
        _activity = 'walking';
        break;
      case far.ActivityType.RUNNING:
        _activity = 'running';
        break;
      case far.ActivityType.STILL:
        _activity = 'still';
        break;
      case far.ActivityType.ON_BICYCLE:
        _activity = 'cycling';
        break;
      case far.ActivityType.IN_VEHICLE:
        _activity = 'in_vehicle';
        break;
      default:
        _activity = 'unknown';
    }
    
    // Update calories and pace based on activity type
    _updateCaloriesBurned();
    
    notifyListeners();
  }

  // MARK: - Error handlers
  void _onPedestrianStatusError(error) {
    debugPrint('Pedestrian status error: $error');
    _isMoving = false;
    notifyListeners();
  }

  // MARK: - Helper methods
  /// Update calories burned based on activity and step count
  void _updateCaloriesBurned() {
    // Very simple calorie estimation - for a more accurate calculation
    // we would need user data like weight, height, age, gender
    
    // MET values (Metabolic Equivalent of Task)
    // walking: ~3-4 METs, running: ~8-10 METs
    double met = 0.0;
    
    switch (_activity) {
      case 'walking':
        met = 3.5;
        break;
      case 'running':
        met = 8.0;
        break;
      case 'still':
        met = 1.0;
        break;
      case 'cycling':
        met = 5.0;
        break;
      default:
        met = 2.0; // unknown activity
    }
    
    // Assuming 70kg weight (can be customized later)
    final weight = 70.0;
    
    // Formula: calories = MET * weight (kg) * time (hours)
    final hours = _activeDuration.inSeconds / 3600;
    _caloriesBurned = met * weight * hours;
    
    notifyListeners();
  }

  String _formatPace() {
    if (_pace.isInfinite || _pace.isNaN || _pace == 0) {
      return '--:--';
    }

    final minutes = _pace.floor();
    final seconds = ((_pace - minutes) * 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  // MARK: - Analytics methods
  /// Calculate approximate stride length based on height
  /// Returns stride length in meters
  double calculateStrideLength({required double height, required String activity}) {
    // Average stride length is approximately 42% of height for walking
    // and 45% of height for running
    if (activity == 'running') {
      return height * 0.45;
    } else {
      return height * 0.42;
    }
  }

  /// Get a summary of the current workout
  Map<String, dynamic> getWorkoutSummary() {
    return {
      'startTime': _startTime,
      'duration': _activeDuration,
      'durationFormatted': activeDurationFormatted,
      'steps': _steps,
      'distance': _distance,
      'distanceKm': distanceKm,
      'distanceMiles': distanceMiles,
      'pace': _pace,
      'paceFormatted': paceFormatted,
      'caloriesBurned': _caloriesBurned,
      'mainActivity': _activity,
    };
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
} 