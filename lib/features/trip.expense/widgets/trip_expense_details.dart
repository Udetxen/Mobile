import 'package:flutter/material.dart';
import 'package:udetxen/features/trip.expense/services/expense_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/widgets/loader.dart';

import 'budget_summary.dart';
import 'expense_item.dart';

class TripExpenseDetails extends StatelessWidget {
  final ExpenseService _expenseService = getIt<ExpenseService>();
  final Trip trip;
  final double budget;
  final Function(Expense?) onAddOrEditExpense;
  final Widget? expenseAction;

  TripExpenseDetails({
    super.key,
    required this.trip,
    required this.budget,
    required this.onAddOrEditExpense,
    this.expenseAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(trip.expenseUids ?? []),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading(isFullScreen: false);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final expenses = snapshot.data ?? [];
            double totalExpense = expenses.fold(
                0, (sum, expense) => sum + (expense.expense ?? 0));
            double remainingBudget = budget - totalExpense;
            double progress = (totalExpense / budget);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BudgetSummary(
                  budget: trip.budget,
                  totalExpense: totalExpense,
                  remainingBudget: remainingBudget,
                  progress: progress,
                  expenseAction: expenseAction,
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    return ExpenseItem(
                        expense: expenses[index], action: onAddOrEditExpense);
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
