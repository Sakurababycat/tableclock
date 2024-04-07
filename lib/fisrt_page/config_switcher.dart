import 'package:table_clock/utils/config_ext.dart';
import 'package:table_clock/utils/record.dart';
import 'package:flutter/material.dart';

import 'package:table_clock/utils/config.dart';

typedef CallBackType = void Function(bool);

class ConfigSwitcher<DerivedType extends BaseConfig> extends StatefulWidget {
  final ConfigEnumType<DerivedType> enumInstances;
  final String description;
  final ConfigType type;
  final List<num>? ext;

  const ConfigSwitcher({
    super.key,
    required this.enumInstances,
    required this.description,
    required this.type,
    this.ext,
  });

  @override
  State<StatefulWidget> createState() => _ConfigSwitcher<DerivedType>();
}

class _ConfigSwitcher<DerivedType extends BaseConfig>
    extends State<ConfigSwitcher<DerivedType>> {
  int switchState = 0;
  List<num>? defaultState;

  void changeStateMulti(int? state) {
    final state_ = state ?? 0;
    changeState(state_);
    saveConfig(state_);
  }

  void changeState(int state) {
    setState(() {
      switchState = state;
    });
  }

  void saveConfig(int state) {
    final key = getKeyByEnum(widget.enumInstances);
    configStorage[key] = state;
  }

  void changeStateDau(bool state) {
    final state_ = state ? 1 : 0;
    changeState(state_);
    saveConfig(state_);
  }

  void changeStateSingle(bool state) {
    final state_ = state ? 0 : -1;
    changeState(state_);
    saveConfig(state_);
  }

  @override
  void initState() {
    super.initState();

    if (widget.ext != null) {
      for (final ext in widget.ext!) {
        defaultState ??= [];
        defaultState!.add(ext);
      }
    }
    getRecord();
  }

  getRecord() async {
    final record = await configStorage.record;
    final initState_ = defaultState?[0] ?? 0;
    final state =
        record.record[getKeyByEnum(widget.enumInstances)] ?? initState_;
    changeState(state);
    saveConfig(state);
  }

  DerivedType state2ViewMode(int state) {
    return widget.enumInstances.enumByIndex(state)!;
  }

  getStyle(bool state) {
    return TextStyle(
        fontWeight: state ? textBold : textNormal,
        fontSize: state ? textSizeLarge : textSizeSmall);
  }

  dauLeftStyle() {
    return getStyle(!state2BoolDau);
  }

  dauRightStyle() {
    return getStyle(state2BoolDau);
  }

  get state2BoolDau => switchState != 0 ? true : false;
  get state2BoolSingle => switchState == 0 ? true : false;

  @override
  Widget build(BuildContext context) {
    return switch (widget.type) {
      ConfigType.singleSwitch => singleSwitch(),
      ConfigType.dauSwitch => dauSwitch(),
      ConfigType.multiCheck => multiConfig(),
      ConfigType.silder => singleSlider(),
    };
  }

  Widget singleSlider() {
    final double min = defaultState?[0].toDouble() ?? 0;
    final double max = defaultState?[1].toDouble() ?? 100;
    final val = switchState.toDouble();
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      titleText(),
      Expanded(
        child: Slider(
          value: val >= min
              ? val <= max
                  ? val
                  : max
              : min,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: switchState.toString(),
          onChanged: (double value) {
            changeState(value.toInt());
            saveConfig(value.toInt());
          },
        ),
      ),
      Text(switchState.toString(), style: getStyle(false)),
      const SizedBox(width: 10.0)
    ]);
  }

  Text titleText() {
    return Text("${widget.description}:  ",
        style: TextStyle(
            fontWeight: textBold,
            fontSize: textSizeLarge,
            color: Colors.blue[300]));
  }

  Widget multiConfig() {
    const numRow = 3;
    final sublists =
        List.generate(widget.enumInstances.length ~/ numRow + 1, (index) {
      final start = index * numRow;
      var end = (index + 1) * numRow;
      end = end > widget.enumInstances.length
          ? widget.enumInstances.length
          : (index + 1) * numRow;
      return widget.enumInstances.sublist(start, end);
    });
    return Column(children: <Widget>[
      Row(children: [titleText()]),
      Column(children: [
        for (final sublist in sublists.asMap().entries)
          Row(children: [
            for (final enumItem in sublist.value.asMap().entries)
              Flexible(
                child: RadioListTile<int>(
                  value: enumItem.key + sublist.key * numRow,
                  title: Text(enumItem.value.text),
                  groupValue: switchState,
                  onChanged: changeStateMulti,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              )
          ])
      ])
    ]);
  }

  Widget singleSwitch() {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      titleText(),
      Text('关', style: getStyle(!state2BoolSingle)),
      Switch(value: state2BoolSingle, onChanged: changeStateSingle),
      Text('开', style: getStyle(state2BoolSingle))
    ]);
  }

  Widget dauSwitch() {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      titleText(),
      Text(state2ViewMode(0).text, style: dauLeftStyle()),
      Switch(value: state2BoolDau, onChanged: changeStateDau),
      Text(state2ViewMode(1).text, style: dauRightStyle())
    ]);
  }
}
