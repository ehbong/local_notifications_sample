import 'package:isar/isar.dart';

part 'notificationSwitch.g.dart';

@collection
class NotificationSwitch {
  Id id = Isar.autoIncrement;
  bool isOn = false;
}
