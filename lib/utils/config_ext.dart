import 'dart:ui';

import 'package:table_clock/utils/config.dart';
import 'package:table_clock/utils/record.dart';

class Config {
  final config = ConfigRecordType(record: {});
  static final Config _instance = Config._();
  Config._() {
    initConfig();
    configStorage.record.then((record) => record.addListener(refreshConfig));
  }
  factory Config.getConfig() => _instance;

  void initConfig({ConfigRecordType? record}) {
    for (final (_, enumInstance, type, _, _) in configLists) {
      final key = getKeyByEnum(enumInstance);
      final state = record?.record[key] ?? 0;
      config.record[key] = switch (type) {
        ConfigType.silder => state,
        _ => enumInstance.enumByIndex(state)
      };
    }
    config.notify();
  }

  void refreshConfig() async {
    final record = await configStorage.record;
    initConfig(record: record);
  }

  operator [](Object type) {
    final key = getKeyByClass(type);
    return config.record[key];
  }
}

String getKeyByEnum(ConfigEnumType<BaseConfig> enumerate) {
  final instance = enumerate.enumByIndex(0);
  final key = instance.runtimeType.toString();
  return key;
}

String getKeyByClass(Object type) {
  return type.toString();
}

int getCountdownTime() =>
    Config.getConfig()[RelaxCountdownConfig] ?? RelaxCountdownConfig.min;

bool getCountdownSwitch() =>
    Config.getConfig()[RelaxSwitchConfig] == RelaxSwitchConfig.relaxClock;

double getVFillSize(Size size) =>
    Config.getConfig()[VFillSizeConfig] * size.width / 200;
double getHFillSize(Size size) =>
    Config.getConfig()[HFillSizeConfig] * size.height / 200;

int getVibrationTime() =>
    Config.getConfig()[VibrationTimeConfig] ?? VibrationTimeConfig.min;

bool getPrevetBurn() =>
    Config.getConfig()[OLEDPreventBurnConfig] ==
    OLEDPreventBurnConfig.oledPreventBurn;

int getAutoScreenOff() =>
    Config.getConfig()[AutoScreenOffConfig] ?? AutoScreenOffConfig.min;
