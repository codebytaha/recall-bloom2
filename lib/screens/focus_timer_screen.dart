import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recall_bloom/utils/constants.dart';
import 'package:recall_bloom/widgets/timer_display.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  Timer? _timer;
  int _totalSeconds = AppConstants.defaultStudyMinutes * 60;
  int _remainingSeconds = AppConstants.defaultStudyMinutes * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedSessions = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() => _isRunning = false);

    if (!_isBreak) {
      setState(() => _completedSessions++);
      _showCompletionDialog();
    } else {
      _showBreakCompleteDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Session Complete!'),
        content: const Text('Great work! Time for a short break?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startBreak();
            },
            child: const Text('Start Break'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            child: const Text('Skip Break'),
          ),
        ],
      ),
    );
  }

  void _showBreakCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Break Complete!'),
        content: const Text('Ready to get back to studying?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endBreak();
            },
            child: const Text('Start Studying'),
          ),
        ],
      ),
    );
  }

  void _startBreak() {
    setState(() {
      _isBreak = true;
      _totalSeconds = AppConstants.defaultBreakMinutes * 60;
      _remainingSeconds = AppConstants.defaultBreakMinutes * 60;
    });
    _startTimer();
  }

  void _endBreak() {
    setState(() {
      _isBreak = false;
      _totalSeconds = AppConstants.defaultStudyMinutes * 60;
      _remainingSeconds = AppConstants.defaultStudyMinutes * 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _isBreak
                      ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isBreak ? 'Break Time' : 'Study Session',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _isBreak
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TimerDisplay(
                totalSeconds: _totalSeconds,
                remainingSeconds: _remainingSeconds,
                isRunning: _isRunning,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isRunning) ...[
                    _TimerButton(
                      icon: Icons.play_arrow,
                      label: 'Start',
                      onPressed: _startTimer,
                      isPrimary: true,
                    ),
                  ] else ...[
                    _TimerButton(
                      icon: Icons.pause,
                      label: 'Pause',
                      onPressed: _pauseTimer,
                      isPrimary: true,
                    ),
                  ],
                  const SizedBox(width: 20),
                  _TimerButton(
                    icon: Icons.refresh,
                    label: 'Reset',
                    onPressed: _resetTimer,
                    isPrimary: false,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completed Sessions',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '$_completedSessions',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _TimerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor: isPrimary
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPrimary
              ? BorderSide.none
              : BorderSide(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
