import 'package:flutter/material.dart';
import 'package:udetxen/features/home/services/home_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Tours',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              AvailableToursWidget(homeService: _homeService),
              const SizedBox(height: 32),
              const Text(
                'Popular Venues',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              PopularVenuesWidget(homeService: _homeService),
            ],
          ),
        ),
      ),
    );
  }
}
