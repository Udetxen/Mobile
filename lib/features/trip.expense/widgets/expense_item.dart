import 'package:flutter/material.dart';
import 'package:udetxen/shared/types/models/expense.dart';

class ExpenseItem extends StatelessWidget {
  final Function(Expense?)? action;
  final Expense expense;

  const ExpenseItem({super.key, required this.expense, this.action});

  @override
  Widget build(BuildContext context) {
    // double totalExpense =
    //     expenses.fold(0, (sum, expense) => sum + (expense.expense ?? 0));
    // double remainingBudget = trip.budget - totalExpense;
    // double progress = totalExpense / trip.budget;

    return GestureDetector(
      onTap: () => action != null ? action!(expense) : null,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budget: \$${expense.budget.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          expense.expense != null
                              ? 'Expense: \$${expense.expense!.toStringAsFixed(2)}'
                              : 'Expense: Not Set',
                          style: TextStyle(
                            fontSize: 14,
                            color: expense.expense != null
                                ? Theme.of(context).primaryColor
                                : Colors.orangeAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
