import 'dart:async';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  Timer? _timer;
  int _timerSeconds = 0;
  int _timerMilliseconds = 0;
  final _controller = StreamController<void>.broadcast();

  Stream<void> get timerStream => _controller.stream;

  void startTimer() {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _timerMilliseconds += 10;
      if (_timerMilliseconds >= 1000) {
        _timerSeconds++;
        _timerMilliseconds -= 1000;
      }
      _controller.add(null);
    });
  }

  void resetTimer() {
    _timerSeconds = 0;
    _timerMilliseconds = 0;
    _controller.add(null);
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }

  int get currentSeconds => _timerSeconds;
  int get currentMilliseconds => _timerMilliseconds;
}