import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_clock/fisrt_page/config_view.dart';
import 'package:table_clock/main_page/main_view.dart';

import 'package:table_clock/utils/config.dart';
import 'package:table_clock/utils/record.dart';
import 'package:wakelock/wakelock.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool isLandscape = false;
  late CountStateHook? countStateHook;

  setOrientation(bool val) async {
    setState(() {
      isLandscape = val;
    });
    if (isLandscape) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive,
          overlays: []);
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      await Wakelock.enable();
    } else {
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
          overlays: SystemUiOverlay.values);
      await Wakelock.disable();
    }
    countStateHook?.call(isLandscape);
  }

  void setCountStateHook(CountStateHook val) {
    countStateHook = val;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.width * size.width / size.height;
    final mainview = MainView(
      setCountStateHook: setCountStateHook,
    );
    final view = switch (isLandscape) {
      false => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            title: const Text('桌面时钟'),
          ),
          body: Column(
            children: <Widget>[
              const ConfigView(),
              ElevatedButton(
                onPressed: () {
                  saveRecord();
                  setOrientation(true);
                },
                child: const Text('进入'),
              ),
              Expanded(
                child: Container(),
              ),
              Row(
                children: [
                  Text("预览:  ",
                      style: TextStyle(
                          fontWeight: textBold,
                          fontSize: textSizeLarge,
                          color: Colors.blue[300]))
                ],
              ),
              const SizedBox(height: textSizeLarge),
              SizedBox(height: height, child: mainview),
            ],
          )),
      true => Scaffold(
          body: PopScope(
            canPop: false,
            onPopInvoked: (bool val) {
              setOrientation(val);
            },
            child: GestureDetector(
              onTap: () => startUpDialog(context),
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: mainview,
              ),
            ),
          ),
        ),
    };

    return view;
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
                countStateHook?.call(true);
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

  saveRecord() {
    configStorage.writeConfigRecord();
  }
}
