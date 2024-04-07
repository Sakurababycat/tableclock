import 'package:flutter/material.dart';
import 'package:table_clock/fisrt_page/config_switcher.dart';
import 'package:table_clock/utils/config.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (desc, enumInstance, type, ext) in configLists)
          ConfigSwitcher(
              enumInstances: enumInstance,
              description: desc,
              type: type,
              ext: ext),
      ],
    );
  }
}
