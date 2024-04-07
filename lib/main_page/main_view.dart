import 'dart:async';

import 'package:table_clock/main_page/fill_content.dart';
import 'package:flutter/material.dart';
import 'package:table_clock/utils/config_ext.dart';
import 'package:table_clock/utils/record.dart';

typedef CountStateHook = void Function(bool);

class BlankView extends StatefulWidget {
  final void Function(CountStateHook) setCountStateHook;
  const BlankView({super.key, required this.setCountStateHook});

  @override
  State<StatefulWidget> createState() => _BlankViewState();
}

class _BlankViewState extends State<BlankView> {
  String time = '';
  late Timer timer;
  String countdownTimeStr = '00:00';
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    widget.setCountStateHook(countDown);
    updateTime();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTime();
    });
    configStorage.record.then((value) => value.addListener(setCountDown));
    countDown(false);
  }

  updateTime() {
    final now = DateTime.now();
    final timeNow =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    if (timeNow != time) {
      time = timeNow;
      setState_();
    }
  }

  void setState_() {
    setState(() {});
  }

  void setCountDown() {
    final countdown = getCountdownTime();
    countdownTimeStr = '$countdown:00';
    setState_();
  }

  @override
  void dispose() {
    timer.cancel();
    configStorage.record.then((value) => value.removeListener(setCountDown));
    super.dispose();
  }

  void countDown(bool state) {
    final countdown = getCountdownTime();
    if (state) {
      int downCountNumInSec = countdown * 60;
      if (countdownTimer != null) {
        countdownTimer!.cancel();
      }
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        downCountNumInSec--;
        countdownTimeStr =
            "${(downCountNumInSec ~/ 60).toString().padLeft(2, '0')}:${(downCountNumInSec % 60).toString().padLeft(2, '0')}";
        setState_();
        if (downCountNumInSec == 0) {
          countdownTimer?.cancel();
          countdownTimer = null;
        }
      });
    } else {
      countdownTimer?.cancel();
      countdownTimer = null;
      countdownTimeStr = '$countdown:00';
      setState_();
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeText = FittedBox(
      fit: BoxFit.contain,
      child: Text(
        time,
        style: const TextStyle(color: Colors.white),
      ),
    );

    final content = switch (getCountdownSwitch()) {
      true => Column(children: [
          Expanded(flex: 3, child: timeText),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                countdownTimeStr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        ]),
      false => timeText,
    };

    return FilledViewBuilder(
      child: content,
    );
  }
}
