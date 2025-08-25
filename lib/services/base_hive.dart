import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static String nameBox = "NextEnergy";
  static void put(String key, dynamic value) {
    var box = Hive.box(nameBox);
    box.put(key, value);
  }

  static dynamic get(String key, {dynamic defaultvalue}) {
    var box = Hive.box(nameBox);
    return box.get(key, defaultValue: defaultvalue);
  }

  static void remove(String key) {
    var box = Hive.box(nameBox);
    box.delete(key);
  }
}
