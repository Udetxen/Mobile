import 'package:flutter/material.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/widgets/loader.dart';

import '../services/expense_service.dart';
import 'budget_summary.dart';
import 'expense_item.dart';

class PersonalBudgetDetails extends StatelessWidget {
  final ExpenseService _expenseService = getIt<ExpenseService>();
  final Participant participant;
  final Function(Expense?) onAddOrEditExpense;
  final Function() onSetBudget;
  final Widget? expenseAction;

  PersonalBudgetDetails({
    super.key,
    required this.participant,
    required this.onAddOrEditExpense,
    required this.onSetBudget,
    this.expenseAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Expense>>(
        stream: _expenseService.getExpenses(participant.expenseUids ?? []),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Loading(isFullScreen: false);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final expenses = snapshot.data ?? [];
            double totalExpense = expenses.fold(
                0, (sum, expense) => sum + (expense.expense ?? 0));
            double remainingBudget =
                (participant.personalBudget ?? 0.0) - totalExpense;
            double progress =
                totalExpense / (participant.personalBudget ?? 1.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BudgetSummary(
                  budget: participant.personalBudget ?? 0.0,
                  totalExpense: totalExpense,
                  remainingBudget: remainingBudget,
                  progress: progress,
                  budgetAction: ElevatedButton(
                    onPressed: () => onSetBudget(),
                    child: Text(participant.personalBudget == null
                        ? 'Set Personal Budget'
                        : 'Edit Personal Budget'),
                  ),
                  expenseAction: expenseAction,
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    return ExpenseItem(
                      expense: expenses[index],
                      action: onAddOrEditExpense,
                    );
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
