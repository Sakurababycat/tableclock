import 'package:flutter/material.dart';
import 'package:table_clock/fisrt_page/config_view.dart';
import 'package:table_clock/main_page/main_page.dart';
import 'package:table_clock/main_page/main_view.dart';

import 'package:table_clock/utils/config.dart';
import 'package:table_clock/utils/record.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.width * size.width / size.height;
    const mainview = MainView();
    final view = Scaffold(
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MainPage()));
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
      ),
    );

    return view;
  }

  saveRecord() {
    configStorage.writeConfigRecord();
  }
}
