import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/movement_tracking_service.dart';

class MovementTrackingPage extends StatefulWidget {
  const MovementTrackingPage({super.key});

  @override
  State<MovementTrackingPage> createState() => _MovementTrackingPageState();
}

class _MovementTrackingPageState extends State<MovementTrackingPage> with WidgetsBindingObserver {
  bool _isInitialized = false;
  String _statusMessage = 'Initializing...';
  final MovementTrackingService _trackingService = MovementTrackingService();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeTracking();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trackingService.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop tracking when app goes to background
    if (state == AppLifecycleState.paused && _trackingService.isTracking) {
      _trackingService.stopTracking();
    }
  }
  
  Future<void> _initializeTracking() async {
    try {
      bool success = await _trackingService.initialize();
      setState(() {
        _isInitialized = success;
        _statusMessage = success 
            ? 'Ready to track movement' 
            : 'Failed to initialize tracking. Please check permissions.';
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _statusMessage = 'Error: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ChangeNotifierProvider.value(
      value: _trackingService,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movement Tracking'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: _isInitialized 
            ? const _TrackingView() 
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_statusMessage),
                    const SizedBox(height: 24),
                    if (!_isInitialized)
                      ElevatedButton(
                        onPressed: _initializeTracking,
                        child: const Text('Retry'),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _TrackingView extends StatelessWidget {
  const _TrackingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackingService = Provider.of<MovementTrackingService>(context);
    
    return SafeArea(
      child: Column(
        children: [
          // Stats dashboard
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity status card
                  _buildActivityCard(context, trackingService),
                  const SizedBox(height: 16),
                  
                  // Stats cards
                  GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard(
                        context,
                        'Steps',
                        '${trackingService.steps}',
                        Icons.directions_walk,
                      ),
                      _buildStatCard(
                        context,
                        'Distance',
                        '${trackingService.distanceKm.toStringAsFixed(2)} km',
                        Icons.straighten,
                      ),
                      _buildStatCard(
                        context,
                        'Pace',
                        trackingService.paceFormatted,
                        Icons.speed,
                      ),
                      _buildStatCard(
                        context,
                        'Calories',
                        '${trackingService.caloriesBurned.toStringAsFixed(0)} kcal',
                        Icons.local_fire_department,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Active Time',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            trackingService.activeDurationFormatted,
                            style: theme.textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Explanation text
                  Text(
                    'How it works',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This feature uses your device\'s sensors to track movement. '
                    'It can detect if you\'re walking or running, and calculate '
                    'distance, pace, and estimated calories burned. The tracking '
                    'works best when you keep your phone with you.'
                  ),
                ],
              ),
            ),
          ),
          
          // Start/Stop button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (trackingService.isTracking) {
                    trackingService.stopTracking();
                  } else {
                    trackingService.startTracking();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: trackingService.isTracking
                      ? Colors.red
                      : theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: Text(
                  trackingService.isTracking ? 'STOP TRACKING' : 'START TRACKING',
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityCard(BuildContext context, MovementTrackingService service) {
    final theme = Theme.of(context);
    
    // Map activity to more user-friendly text and icon
    String activityText;
    IconData activityIcon;
    
    switch (service.activity) {
      case 'walking':
        activityText = 'Walking';
        activityIcon = Icons.directions_walk;
        break;
      case 'running':
        activityText = 'Running';
        activityIcon = Icons.directions_run;
        break;
      case 'still':
        activityText = 'Standing Still';
        activityIcon = Icons.accessibility_new;
        break;
      case 'cycling':
        activityText = 'Cycling';
        activityIcon = Icons.directions_bike;
        break;
      case 'in_vehicle':
        activityText = 'In Vehicle';
        activityIcon = Icons.directions_car;
        break;
      default:
        activityText = 'Unknown Activity';
        activityIcon = Icons.help_outline;
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Current Activity',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  activityIcon,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  activityText,
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service.isTracking 
                  ? 'Activity tracking is active' 
                  : 'Activity tracking is paused',
              style: TextStyle(
                color: service.isTracking ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall,
                ),
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
} 