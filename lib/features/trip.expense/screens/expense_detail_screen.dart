import 'package:flutter/material.dart';
import 'package:udetxen/features/trip.expense/services/expense_service.dart';
import 'package:udetxen/features/trip/screens/trip_detail_screen.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/trip.dart';

import '../widgets/expense_form_dialog.dart';
import '../widgets/trip_expense_details.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Trip trip;
  final bool? isAdding;

  static route(Trip trip, {bool? isAdding, RouteSettings? settings}) {
    return MaterialPageRoute<void>(
      builder: (_) => ExpenseDetailScreen(
        trip: trip,
        isAdding: isAdding,
      ),
      settings: settings,
    );
  }

  const ExpenseDetailScreen({super.key, required this.trip, this.isAdding});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  bool get isAdding => widget.isAdding ?? false;
  final ExpenseService _expenseService = getIt<ExpenseService>();
  late Trip trip;

  @override
  void initState() {
    trip = widget.trip;
    if (isAdding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showExpenseFormDialog();
      });
      super.initState();
    }
  }

  void _showExpenseFormDialog({Expense? expense}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExpenseFormDialog(
          expenseService: _expenseService,
          trip: trip,
          expense: expense,
          onSave: (newTrip) {
            setState(() {
              trip = newTrip;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double budget = trip.budget;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              trip.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (Navigator.canPop(context) &&
                    ModalRoute.of(context)?.settings.arguments != null) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).push(
                    TripDetailScreen.route(trip.uid!),
                  );
                }
              },
              icon: const Icon(Icons.remove_red_eye),
              label: const Text('View Trip'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                textStyle: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).hintColor,
      ),
      body: TripExpenseDetails(
        trip: trip,
        budget: budget,
        onAddOrEditExpense: (expense) {
          _showExpenseFormDialog(expense: expense);
        },
        expenseAction: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showExpenseFormDialog(),
        ),
      ),
    );
  }
}
