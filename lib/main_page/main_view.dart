import 'dart:async';

import 'package:table_clock/fisrt_page/config_view.dart';
import 'package:table_clock/main_page/fill_content.dart';
import 'package:flutter/material.dart';
import 'package:table_clock/utils/config_ext.dart';
import 'package:vibration/vibration.dart';

class MainView extends StatefulWidget {
  final bool isOnMainPage;
  const MainView({super.key, this.isOnMainPage = false});

  @override
  State<StatefulWidget> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  String time = '';
  late Timer timer;
  String countdownTimeStr = '00:00';
  Timer? countdownTimer;
  Timer? preventBurnTimer;

  bool isblackScreen = false;

  @override
  void initState() {
    super.initState();

    updateTime();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTime();
    });
    Config.getConfig().config.addListener(setCountDown);
    handleConfig(widget.isOnMainPage);
  }

  void handleConfig(bool startCountDown) {
    handlePreventBurn();
    countDown(startCountDown);
  }

  @override
  void dispose() {
    timer.cancel();
    Config.getConfig().config.removeListener(setCountDown);
    countdownTimer?.cancel();
    countdownTimer = null;
    preventBurnTimer?.cancel();
    preventBurnTimer = null;

    super.dispose();
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
    if (!widget.isOnMainPage) {
      final countdown = getCountdownTime();
      setCountDownTimeStr(countdown, 0);
    }
  }

  void setCountDownTimeStr(int min, int sec) {
    countdownTimeStr =
        "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
    setState_();
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
        setCountDownTimeStr(downCountNumInSec ~/ 60, downCountNumInSec % 60);

        setState_();
        if (downCountNumInSec == 0) {
          countdownEndedAlert();
          countdownTimer?.cancel();
          countdownTimer = null;
        }
      });
    } else {
      countdownTimer?.cancel();
      countdownTimer = null;
      setCountDownTimeStr(countdown, 0);
      setState_();
    }
  }

  void countdownEndedAlert() async {
    final canVibrate = await Vibration.hasVibrator();
    if (canVibrate != null && canVibrate) {
      final time = getVibrationTime();
      Vibration.vibrate(
        duration: time * 1000,
      );
    }
  }

  void handlePreventBurn() {
    if (getPrevetBurn()) {
      int countdown = getAutoScreenOff();
      closeSleepTimer();
      preventBurnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        countdown--;
        if (countdown == 0) {
          isblackScreen = true;
          closeSleepTimer();
          setState_();
        }
      });
    } else {
      closeSleepTimer();
    }
  }

  closeSleepTimer() {
    preventBurnTimer?.cancel();
    preventBurnTimer = null;
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
    final content = switch ((getCountdownSwitch(), isblackScreen)) {
      (true, false) => Column(children: [
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
      (false, false) => timeText,
      (_, true) => Container(
          color: Colors.black,
        )
    };

    return GestureDetector(
      onTap: handleTap,
      child: FilledViewBuilder(
        child: content,
      ),
    );
  }

  Future<void> startUpDialog(BuildContext context) async {
    Widget builder(BuildContext context) {
      return AlertDialog(
        title: const Text("设置"),
        content: const SingleChildScrollView(
          child: ConfigView(),
        ),
        actions: [
          TextButton(
              onPressed: () {
                countDown(true);
                Navigator.pop(context);
              },
              child: const Text("重置")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("返回"))
        ],
      );
    }

    return showDialog(context: context, builder: builder);
  }

  void handleTap() {
    if (isblackScreen) {
      isblackScreen = false;
      setState_();
    } else {
      startUpDialog(context);
    }
    handlePreventBurn();
  }
}
