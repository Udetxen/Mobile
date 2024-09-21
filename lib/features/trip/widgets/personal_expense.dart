import 'package:flutter/material.dart';
import 'package:udetxen/features/trip.expense/screens/personal_budget_screen.dart';
import 'package:udetxen/shared/config/theme/colors.dart';
import 'package:udetxen/shared/types/models/trip.dart';

class PersonalExpense extends StatelessWidget {
  final Participant participant;
  final Trip trip;

  const PersonalExpense({
    super.key,
    required this.participant,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    if (participant.personalBudget == null) {
      return Card(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No Personal Budget Set',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    PersonalBudgetScreen.route(participant, trip,
                        action: 'set'),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Set Personal Budget'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    double totalExpense = participant.expenses?.fold(
            0.0, (sum, expense) => (sum ?? 0) + (expense.expense ?? 0)) ??
        0.0;
    double remainingBudget = (participant.personalBudget ?? 0.0) - totalExpense;
    double progress = totalExpense / (participant.personalBudget ?? 1.0);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Personal Budget: \$${participant.personalBudget?.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Total Expense: \$${totalExpense.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                totalExpense == 0.0
                    ? ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            PersonalBudgetScreen.route(participant, trip,
                                action: 'add'),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label:
                            const Text('Add', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          backgroundColor: AppColors.success,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            PersonalBudgetScreen.route(participant, trip),
                          );
                        },
                        icon: const Icon(Icons.remove_red_eye),
                        label: const Text('Details',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          backgroundColor: AppColors.secondary,
                        ),
                      )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Remaining Budget: ${remainingBudget < 0 ? '-' : ''}\$${remainingBudget.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: remainingBudget < 0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress >= 1.0 ? (1.0 / progress) : progress,
              backgroundColor:
                  progress >= 1.0 ? AppColors.error : AppColors.hint,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
