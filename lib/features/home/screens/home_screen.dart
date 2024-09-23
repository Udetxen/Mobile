import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/home/services/home_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/user.dart';

import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';

import '../widgets/available_tours.dart';
import '../widgets/popular_venues.dart';

class HomeScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout();
  }

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = getIt<HomeService>();
  final authService = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: authService.userStream,
        builder: (context, snapshot) {
          final user = snapshot.data;

          return Scaffold(
            appBar: AppBar(
              title: const Text('UDetxen'),
              leading: const Padding(
                padding: EdgeInsets.only(left: 12.0, bottom: 5),
                child: CircleAvatar(
                  backgroundImage: AssetImage('assets/images/logo.jpg'),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      Text(
                        user?.displayName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (user?.photoURL != null)
                        CircleAvatar(
                          backgroundImage: NetworkImage(user!.photoURL!),
                        ),
                    ],
                  ),
                ),
              ],
              backgroundColor: Theme.of(context).hintColor,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Trips',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    AvailableToursWidget(homeService: _homeService),
                    const SizedBox(height: 32),
                    const Text(
                      'Popular Venues',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    PopularVenuesWidget(homeService: _homeService),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
