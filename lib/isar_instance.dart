import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'notificationSwitch.dart';

Isar? _isarInstance;

/// isarInstance를 반환하는 함수
Future<Isar> get isarInstance async {
  if (_isarInstance == null) {
    final dir = await getApplicationDocumentsDirectory();
    _isarInstance =
        await Isar.open([NotificationSwitchSchema], directory: dir.path);
  }
  return _isarInstance!;
}
