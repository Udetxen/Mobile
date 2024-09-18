import 'package:flutter/material.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';

class DashboardTripListScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout(
      isAdmin: true,
      currentIndex: 2,
    );
  }

  const DashboardTripListScreen({super.key});

  @override
  State<DashboardTripListScreen> createState() =>
      _DashboardTripListScreenState();
}

class _DashboardTripListScreenState extends State<DashboardTripListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
