import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final Duration interval;
  final WidgetBuilder builder;

  const TimerWidget({required this.interval, required this.builder, super.key});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      try {
        setState(() {});
      } catch (_) {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
