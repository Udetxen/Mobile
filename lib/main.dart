import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared/config/routes.dart';
import 'shared/config/theme/app_theme.dart';
import 'shared/config/initializer.dart';
import 'shared/utils/notification_util.dart';
import 'shared/config/service_locator.dart';
import 'shared/utils/theme_service.dart';
import 'shared/utils/connectivity_service.dart';
import 'shared/widgets/auth_wrapper.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupLocator();

  await initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = getIt<ConnectivityService>();
    final notificationUtil = getIt<NotificationUtil>();

    return MultiProvider(
      providers: [
        Provider<NotificationUtil>(
          create: (_) => notificationUtil,
        ),
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(),
        ),
        ChangeNotifierProvider<ConnectivityService>(
          create: (_) => connectivityService,
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: themeService.isDarkMode
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
            home: const AuthWrapper(),
            routes: Routes.getAppRoutes(),
          );
        },
      ),
    );
  }
}
