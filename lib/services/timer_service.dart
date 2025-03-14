import 'dart:async';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  Timer? _timer;
  int _timerSeconds = 0;
  int _timerMilliseconds = 0;
  StreamController<void>? _controller = StreamController<void>.broadcast();
  bool _isDisposed = false;

  Stream<void> get timerStream {
    // If the controller was disposed, create a new one
    if (_isDisposed || _controller == null || _controller!.isClosed) {
      _controller = StreamController<void>.broadcast();
      _isDisposed = false;
    }
    return _controller!.stream;
  }

  void startTimer() {
    // If the controller was disposed, create a new one
    if (_isDisposed || _controller == null || _controller!.isClosed) {
      _controller = StreamController<void>.broadcast();
      _isDisposed = false;
    }
    
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      _timerMilliseconds += 10;
      if (_timerMilliseconds >= 1000) {
        _timerSeconds++;
        _timerMilliseconds -= 1000;
      }
      if (!_isDisposed && _controller != null && !_controller!.isClosed) {
        _controller!.add(null);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void resetTimer() {
    _timerSeconds = 0;
    _timerMilliseconds = 0;
    if (!_isDisposed && _controller != null && !_controller!.isClosed) {
      _controller!.add(null);
    }
  }

  void dispose() {
    stopTimer();
    if (_controller != null && !_controller!.isClosed) {
      _controller!.close();
    }
    _isDisposed = true;
  }

  int get currentSeconds => _timerSeconds;
  int get currentMilliseconds => _timerMilliseconds;
}