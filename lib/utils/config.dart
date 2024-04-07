import 'package:flutter/material.dart';

extension EnumByBool<DerivedType extends BaseConfig> on List<DerivedType> {
  DerivedType? enumByIndex(int index) {
    if (index < 0 || index >= length) {
      return null;
    }
    return this[index];
  }
}

typedef ConfigEnumType<Type> = List<Type>;
typedef ConfigEnumWithDesc<Type> = (
  String desc,
  ConfigEnumType<Type> enumInstance,
  ConfigType type,
  List<int>? ext,
  BaseConfig? condition
);

class BaseConfig {
  final String text;
  static const defaultConfig = BaseConfig._(text: '');

  const BaseConfig._({required this.text});
}

class BGConfig extends BaseConfig {
  static const blank = BGConfig._(text: '无');
  static const image = BGConfig._(text: '图像');
  static const color = BGConfig._(text: '纯色');
  static const enumInstance = [blank, image, color];

  const BGConfig._({required super.text}) : super._();
}

class RelaxSwitchConfig extends BaseConfig {
  static const relaxClock = RelaxSwitchConfig._(text: '放松提醒');
  static const enumInstance = [relaxClock];

  const RelaxSwitchConfig._({required super.text}) : super._();
}

class HFillSizeConfig extends BaseConfig {
  static const hFillSize = HFillSizeConfig._(text: '水平填充');
  static const enumInstance = [hFillSize];

  const HFillSizeConfig._({required super.text}) : super._();
}

class VFillSizeConfig extends BaseConfig {
  static const vFillSize = VFillSizeConfig._(text: '垂直填充');
  static const enumInstance = [vFillSize];

  const VFillSizeConfig._({required super.text}) : super._();
}

class RelaxCountdownConfig extends BaseConfig {
  static const countdownTime = RelaxCountdownConfig._(text: '倒计时');
  static const enumInstance = [countdownTime];
  static const min = 1;
  static const max = 80;

  const RelaxCountdownConfig._({required super.text}) : super._();
}

class VibratorConfig extends BaseConfig {
  static const vibratorTime = VibratorConfig._(text: '提醒时长');
  static const enumInstance = [vibratorTime];
  static const min = 10;
  static const max = 30;

  const VibratorConfig._({required super.text}) : super._();
}

class OLEDPreventBurnConfig extends BaseConfig {
  static const oledPreventBurn = OLEDPreventBurnConfig._(text: '防烧屏');
  static const enumInstance = [oledPreventBurn];

  const OLEDPreventBurnConfig._({required super.text}) : super._();
}

class AutoScreenOffConfig extends BaseConfig {
  static const autoScreenOff = AutoScreenOffConfig._(text: '自动息屏');
  static const enumInstance = [autoScreenOff];
  static const min = 30;
  static const max = 600;

  const AutoScreenOffConfig._({required super.text}) : super._();
}

enum ConfigType { singleSwitch, dauSwitch, multiCheck, silder }

List<ConfigEnumWithDesc<BaseConfig>> configLists = [
  ('背景设置', BGConfig.enumInstance, ConfigType.multiCheck, null, null),
  (
    RelaxSwitchConfig.relaxClock.text,
    RelaxSwitchConfig.enumInstance,
    ConfigType.singleSwitch,
    null,
    null
  ),
  (
    '${RelaxCountdownConfig.countdownTime.text}(${RelaxCountdownConfig.min}~${RelaxCountdownConfig.max}min)',
    RelaxCountdownConfig.enumInstance,
    ConfigType.silder,
    [RelaxCountdownConfig.min, RelaxCountdownConfig.max],
    RelaxSwitchConfig.relaxClock
  ),
  (
    '${VFillSizeConfig.vFillSize.text}(%)',
    VFillSizeConfig.enumInstance,
    ConfigType.silder,
    null,
    null
  ),
  (
    '${HFillSizeConfig.hFillSize.text}(%)',
    HFillSizeConfig.enumInstance,
    ConfigType.silder,
    null,
    null
  ),
  (
    '${VibratorConfig.vibratorTime.text}(s)',
    VibratorConfig.enumInstance,
    ConfigType.silder,
    [VibratorConfig.min, VibratorConfig.max],
    RelaxSwitchConfig.relaxClock
  ),
  (
    OLEDPreventBurnConfig.oledPreventBurn.text,
    OLEDPreventBurnConfig.enumInstance,
    ConfigType.singleSwitch,
    null,
    null
  ),
  (
    AutoScreenOffConfig.autoScreenOff.text,
    AutoScreenOffConfig.enumInstance,
    ConfigType.silder,
    [AutoScreenOffConfig.min, AutoScreenOffConfig.max],
    OLEDPreventBurnConfig.oledPreventBurn
  ),
];

const textSizeSmall = 12.0;
const textSizeLarge = 16.0;
const textBold = FontWeight.bold;
const textNormal = FontWeight.normal;
