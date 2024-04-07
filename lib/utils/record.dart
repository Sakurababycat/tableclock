import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

typedef ConfigRecordKeyType = String;
typedef ConfigRecordTypeRaw = Map<ConfigRecordKeyType, dynamic>;

class ConfigRecordType extends ChangeNotifier {
  ConfigRecordTypeRaw record;

  ConfigRecordType({required this.record});

  void notify() {
    notifyListeners();
  }
}

class ConfigStorage {
  late final Future<ConfigRecordType> _record;
  final String fileName;

  ConfigStorage({required this.fileName}) {
    _record = readConfigRecord();
  }

  Future<ConfigRecordType> get record async => _record;

  Future<String> get _localPath async {
    final dir = await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    final file = File('$path/$fileName');
    if (!await file.exists()) {
      await file.create();
    }
    return file;
  }

  Future<ConfigRecordType> readConfigRecord() async {
    try {
      final file = await _localFile;
      final content = await file.readAsString();
      if (content.isNotEmpty) {
        final ConfigRecordType configRecord =
            ConfigRecordType(record: json.decode(content));
        return configRecord;
      }
      return nullRecord;
    } catch (e) {
      if (kDebugMode) {
        print("读取$fileName记录出错:$e");
      }
      return nullRecord;
    }
  }

  Future<void> writeConfigRecord() async {
    try {
      final file = await _localFile;
      final content = await record;
      final jsonString = json.encode(content.record);
      await file.writeAsString(jsonString);
    } catch (e) {
      if (kDebugMode) {
        print("写入$fileName记录出错:$e");
      }
    }
  }

  Future<void> addConfigRecord(ConfigRecordKeyType key, dynamic val) async {
    final ipRecord = await _record;
    ipRecord.record[key] = val;
    await writeConfigRecord();
    ipRecord.notify();
  }

  Future<void> deleteIpRecord(ConfigRecordKeyType key) async {
    final ipRecord = await record;
    ipRecord.record.remove(key);
    await writeConfigRecord();
    ipRecord.notify();
  }

  ConfigRecordType get nullRecord =>
      ConfigRecordType(record: ConfigRecordTypeRaw());

  operator []=(String key, dynamic val) {
    addConfigRecord(key, val);
  }

  Future operator [](String key) async {
    final record = await _record;
    return record.record[key];
  }
}

ConfigStorage configStorage = ConfigStorage(fileName: "config-record.json");
