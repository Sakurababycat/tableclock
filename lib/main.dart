import 'package:table_clock/utils/config_ext.dart';
import 'package:flutter/material.dart';

import 'package:table_clock/fisrt_page/first_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Config.getConfig().refreshConfig();
    return const MaterialApp(
      home: FirstPage(),
    );
  }
}
