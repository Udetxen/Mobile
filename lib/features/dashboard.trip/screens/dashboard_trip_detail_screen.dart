import 'package:flutter/material.dart';

class DashboardTripDetailScreen extends StatefulWidget {
  final String tripId;
  static route(String tripId) {
    return MaterialPageRoute<void>(
      builder: (_) => DashboardTripDetailScreen(tripId: tripId),
    );
  }

  const DashboardTripDetailScreen({super.key, required this.tripId});

  @override
  State<DashboardTripDetailScreen> createState() =>
      _DashboardTripDetailScreenState();
}

class _DashboardTripDetailScreenState extends State<DashboardTripDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
