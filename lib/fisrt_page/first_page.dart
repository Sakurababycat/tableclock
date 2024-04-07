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

class _FirstPageState extends State<FirstPage>
    with SingleTickerProviderStateMixin {
  bool isLandscape = false;
  late CountStateHook? countStateHook;

  late Animation<double> animation;
  late AnimationController controller;

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
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    animation = Tween<double>(begin: 0.3, end: 1).animate(controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.width * size.width / size.height;
    final mainview = BlankView(
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
                  setOrientation(true).then((_) => controller.forward());
                },
                child: const Text('进入'),
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
              void anim_() {
                if (controller.status == AnimationStatus.dismissed) {
                  controller.removeListener(anim_);
                  controller.reset();
                  setOrientation(val);
                }
              }

              controller.addListener(anim_);
              controller.reverse();
            },
            child: GestureDetector(
                onTap: () => startUpDialog(context),
                child: Row(
                  children: [
                    SizedBox(
                      width: size.width * (1 - animation.value) / 2,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: size.height * (1 - animation.value) / 2,
                        ),
                        SizedBox(
                          height: size.height * animation.value,
                          width: size.width * animation.value,
                          child: mainview,
                        ),
                      ],
                    )
                  ],
                )),
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
