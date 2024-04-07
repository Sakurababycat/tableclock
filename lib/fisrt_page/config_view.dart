import 'package:flutter/material.dart';
import 'package:table_clock/fisrt_page/config_switcher.dart';
import 'package:table_clock/utils/config.dart';
import 'package:table_clock/utils/config_ext.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  Map<String, bool> visibility = {};
  Map<String, Widget> widgets = {};

  @override
  void initState() {
    Config.getConfig().config.addListener(freshVisibility);
    iniSwitcher();
    freshVisibility();
    super.initState();
  }

  @override
  void dispose() {
    Config.getConfig().config.removeListener(freshVisibility);
    super.dispose();
  }

  iniSwitcher() {
    for (final (desc, enumInstance, type, ext, _) in configLists) {
      final widget = ConfigSwitcher(
        enumInstances: enumInstance,
        description: desc,
        type: type,
        ext: ext,
      );
      widgets[getKeyByEnum(enumInstance)] = widget;
    }
  }

  freshVisibility() {
    for (final (_, enumInstance, _, _, condition) in configLists) {
      final val = condition == null ||
          condition == Config.getConfig()[condition.runtimeType];

      final key = getKeyByEnum(enumInstance);
      visibility[key] = val;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in visibility.entries)
          Visibility(
            visible: item.value,
            child: widgets[item.key]!,
          ),
      ],
    );
  }
}
