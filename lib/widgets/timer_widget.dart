import 'package:flutter/material.dart';
import '/services/timer_service.dart';

class TimerWidget extends StatefulWidget {
  final int currentExerciseRestPeriod;

  const TimerWidget({
    super.key,
    required this.currentExerciseRestPeriod,
  });

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  final TimerService _timerService = TimerService();

  @override
  void initState() {
    super.initState();
    // We don't need to start the timer here as it's handled by the parent page
  }

  @override
  void dispose() {
    // We don't need to dispose the timer here as it's handled by the parent page
    super.dispose();
  }

  void resetTimer() {
    _timerService.resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: _timerService.timerStream,
      builder: (context, snapshot) {
        final seconds = _timerService.currentSeconds;
        final milliseconds = (_timerService.currentMilliseconds / 100).floor(); 
        final minutes = seconds ~/ 60;
        final remainingSeconds = seconds % 60;
        final isRestPeriodExceeded = seconds >= widget.currentExerciseRestPeriod;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Timer: ${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(1, '0')}', // Modify this line
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isRestPeriodExceeded ? Colors.red : null,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
