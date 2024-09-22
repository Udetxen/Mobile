import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/dashboard.trip/services/dashboard_trip_service.dart';
import 'package:udetxen/features/dashboard.user/services/dashboard_user_service.dart';
import 'package:udetxen/features/dashboard.venue/services/dashboard_venue_service.dart';
import 'package:udetxen/features/home/services/home_service.dart';
import 'package:udetxen/features/profile/services/profile_service.dart';
import 'package:udetxen/features/report/services/report_service.dart';
import 'package:udetxen/features/trip.expense/services/expense_service.dart';
import 'package:udetxen/features/trip/services/trip_service.dart';
import 'firebase_options.dart';
import '../utils/connectivity_service.dart';
import '../utils/notification_util.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupLocator() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerSingleton<ConnectivityService>(
      ConnectivityService(Connectivity()));

  getIt.registerSingleton<GoogleSignIn>(GoogleSignIn());

  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  getIt.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);

  getIt.registerFactory<NotificationUtil>(() => NotificationUtil(
      getIt<FlutterLocalNotificationsPlugin>(), getIt<FirebaseMessaging>()));

  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  getIt.registerFactory<AuthService>(() => AuthService(getIt<FirebaseAuth>(),
      getIt<FirebaseFirestore>(), getIt<GoogleSignIn>()));

  getIt.registerFactory<ProfileService>(() => ProfileService(
      getIt<FirebaseAuth>(), getIt<FirebaseFirestore>(), getIt<AuthService>()));

  getIt.registerFactory<DashboardTripService>(
      () => DashboardTripService(getIt<FirebaseFirestore>()));

  getIt.registerFactory<DashboardUserService>(
      () => DashboardUserService(getIt<FirebaseFirestore>()));

  getIt.registerFactory<DashboardVenueService>(
      () => DashboardVenueService(getIt<FirebaseFirestore>()));

  getIt.registerFactory<HomeService>(
      () => HomeService(getIt<FirebaseFirestore>()));

  getIt.registerFactory<TripService>(
      () => TripService(getIt<FirebaseFirestore>(), getIt<AuthService>()));

  getIt.registerFactory<ExpenseService>(
      () => ExpenseService(getIt<FirebaseFirestore>(), getIt<AuthService>()));

  getIt.registerFactory<ReportService>(() => ReportService(
      getIt<FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
      getIt<FirebaseStorage>()));
}
