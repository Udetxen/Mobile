import 'package:flutter/material.dart';
import 'package:udetxen/features/trip.expense/services/expense_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/trip.dart';

import '../widgets/personal_budget_details.dart';
import '../widgets/personal_budget_form_dialog.dart';
import '../widgets/personal_expense_form_dialog.dart';

class PersonalBudgetScreen extends StatefulWidget {
  final Trip trip;
  final Participant participant;
  final String? action;

  static route(Participant participant, Trip trip, {String? action}) {
    return MaterialPageRoute<void>(
      builder: (_) => PersonalBudgetScreen(
        participant: participant,
        trip: trip,
        action: action,
      ),
    );
  }

  const PersonalBudgetScreen(
      {super.key, required this.participant, required this.trip, this.action});

  @override
  State<PersonalBudgetScreen> createState() => _PersonalBudgetScreenState();
}

class _PersonalBudgetScreenState extends State<PersonalBudgetScreen> {
  late Participant participant;
  late Trip trip;
  final ExpenseService _expenseService = getIt<ExpenseService>();

  void _showBudgetFormDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return PersonalBudgetFormDialog(
          expenseService: _expenseService,
          trip: widget.trip,
          participant: participant,
          onSave: (updatedTrip) {
            setState(() {
              trip = updatedTrip;
              if (trip.participants != null &&
                  trip.participants?.isNotEmpty == true &&
                  trip.creatorUid != null) {
                participant = trip.participants!
                    .firstWhere((p) => p.participantUid == trip.creatorUid);
              }
            });
          },
        );
      },
    );
  }

  void _showExpenseFormDialog({Expense? expense}) {
    showDialog(
      context: context,
      builder: (context) {
        return PersonalExpenseFormDialog(
          expenseService: _expenseService,
          trip: widget.trip,
          expense: expense,
          onSave: (updatedTrip) {
            setState(() {
              trip = updatedTrip;
              if (trip.participants != null &&
                  trip.participants?.isNotEmpty == true &&
                  trip.creatorUid != null) {
                participant = trip.participants!
                    .firstWhere((p) => p.participantUid == trip.creatorUid);
              }
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    participant = widget.participant;
    trip = widget.trip;
    super.initState();
    if (widget.action != null) {
      if (widget.action == 'add') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showExpenseFormDialog();
        });
      } else if (widget.action == 'set') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showBudgetFormDialog();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Personal Budget'),
        backgroundColor: Theme.of(context).hintColor,
      ),
      body: PersonalBudgetDetails(
        participant: participant,
        onAddOrEditExpense: (expense) =>
            _showExpenseFormDialog(expense: expense),
        onSetBudget: () => _showBudgetFormDialog(),
        expenseAction: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _showExpenseFormDialog(),
        ),
      ),
    );
  }
}
