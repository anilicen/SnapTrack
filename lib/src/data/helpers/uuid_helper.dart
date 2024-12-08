import 'package:uuid/uuid.dart';

class UuidHelper {
  static String getUniqueId() {
    return Uuid().v1();
  }
}
