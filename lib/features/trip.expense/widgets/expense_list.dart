import 'package:flutter/material.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/widgets/loader.dart';

import '../services/expense_service.dart';
import 'budget_summary.dart';
import 'expense_item.dart';

class ExpenseList extends StatelessWidget {
  final Trip trip;
  final _expenseService = getIt<ExpenseService>();

  ExpenseList({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: _expenseService.getExpenses(trip.expenseUids ?? []),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading(isFullScreen: false);
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading expenses'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No expenses available'));
        }

        final expenses = snapshot.data!;
        double totalExpense =
            expenses.fold(0, (sum, expense) => sum + (expense.expense ?? 0));
        double remainingBudget = trip.budget - totalExpense;
        double progress = totalExpense / trip.budget;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BudgetSummary(
              budget: trip.budget,
              totalExpense: totalExpense,
              remainingBudget: remainingBudget,
              progress: progress,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return ExpenseItem(expense: expenses[index]);
              },
            ),
            if (expenses.isEmpty)
              const Center(child: Text('No expenses have set yet.')),
          ],
        );
      },
    );
  }
}
