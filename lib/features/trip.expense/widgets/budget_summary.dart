import 'package:flutter/material.dart';
import 'package:udetxen/shared/config/theme/colors.dart';

class BudgetSummary extends StatelessWidget {
  final double budget;
  final double? totalExpense;
  final double remainingBudget;
  final double progress;
  final Widget? budgetAction;
  final Widget? expenseAction;

  const BudgetSummary({
    super.key,
    required this.budget,
    this.totalExpense = 0.0,
    required this.remainingBudget,
    required this.progress,
    this.budgetAction,
    this.expenseAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget: \$${budget.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (budgetAction != null) budgetAction!,
          ],
        ),
        const SizedBox(height: 8),
        if (totalExpense != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Expense: \$${totalExpense!.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (expenseAction != null) expenseAction!,
            ],
          ),
        const SizedBox(height: 8),
        Text(
          'Remaining Budget: ${remainingBudget < 0.0 ? '-' : ''}\$${remainingBudget.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: remainingBudget < 0
                ? AppColors.error
                : Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: progress >= 1.0 ? (1.0 / progress) : progress,
          backgroundColor: progress >= 1.0 ? AppColors.error : AppColors.hint,
          color: AppColors.success,
        ),
      ],
    );
  }
}
