import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_clock/main_page/main_view.dart';
import 'package:wakelock/wakelock.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    Wakelock.enable();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values);
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: MainView(
      isOnMainPage: true,
    ));
  }
}
