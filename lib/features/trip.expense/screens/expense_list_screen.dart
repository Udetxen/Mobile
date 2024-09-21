import 'package:flutter/material.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';
import 'package:udetxen/shared/widgets/loader.dart';

import '../services/expense_service.dart';
import '../widgets/trip_card.dart';

class ExpenseListScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout(
      currentIndex: 2,
    );
  }

  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _expenseService = getIt<ExpenseService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Trip>>(
      stream: _expenseService.getUserTrips(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading trips'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No trips available'));
        }

        final trips = snapshot.data!;

        return ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return TripCard(trip: trips[index]);
          },
        );
      },
    );
  }
}
