import 'package:flutter/material.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';

class TripListScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout(
      currentIndex: 1,
    );
  }

  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
