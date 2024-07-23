import 'package:flutter/material.dart';
import 'dart:async';

class TimerWidget extends StatefulWidget {
  final int currentExerciseRestPeriod;

  const TimerWidget({Key? key, required this.currentExerciseRestPeriod}) : super(key: key);

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  int _timerSeconds = 0;
  int _timerMilliseconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _timerMilliseconds += 100;
        if (_timerMilliseconds >= 1000) {
          _timerSeconds++;
          _timerMilliseconds = 0;
        }
      });
    });
  }





  void resetTimer() {
    setState(() {
      _timerSeconds = 0;
      _timerMilliseconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _timerSeconds ~/ 60;
    final seconds = _timerSeconds % 60;
    final milliseconds = _timerMilliseconds ~/ 100;

    final timerColor = _timerSeconds >= widget.currentExerciseRestPeriod ? Colors.red : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Timer: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(1, '0')}',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: timerColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}