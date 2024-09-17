import 'package:udetxen/shared/config/service_locator.dart';

import '../utils/connectivity_service.dart';
import '../utils/notification_util.dart';

Future<void> initialize() async {
  await getIt<ConnectivityService>().initialize();

  await getIt<NotificationUtil>().initialize();
}
