import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/trip.expense/screens/expense_detail_screen.dart';
import 'package:udetxen/features/trip.expense/widgets/budget_summary.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/config/theme/colors.dart';
import 'package:udetxen/shared/types/models/trip.dart';

import 'personal_expense.dart';

class TripDetailBudgetCard extends StatelessWidget {
  final Trip trip;
  final double? totalExpense;

  const TripDetailBudgetCard({
    super.key,
    required this.trip,
    this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    final currentUserId = authService.currentUserUid;

    double remainingBudget = trip.budget - (totalExpense ?? 0.0);
    double progress = ((totalExpense ?? 0.0) / trip.budget);

    final isGroupTrip = trip.type == 'group';
    Participant? currentUserParticipant;
    if (isGroupTrip) {
      currentUserParticipant = trip.participants != null &&
              trip.participants?.isNotEmpty == true &&
              trip.creatorUid != null
          ? trip.participants
              ?.firstWhere((p) => p.participantUid == currentUserId)
          : null;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BudgetSummary(
                budget: trip.budget,
                totalExpense: totalExpense,
                remainingBudget: remainingBudget,
                progress: progress,
                expenseAction: totalExpense == null || totalExpense == 0.0
                    ? ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            ExpenseDetailScreen.route(trip,
                                isAdding: true,
                                settings: const RouteSettings(
                                    arguments: 'TripDetailBudgetCard')),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Expense'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          backgroundColor: AppColors.success,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            ExpenseDetailScreen.route(trip,
                                settings: const RouteSettings(
                                    arguments: 'TripDetailBudgetCard')),
                          );
                        },
                        icon: const Icon(Icons.remove_red_eye),
                        label: const Text('Details'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          backgroundColor: AppColors.secondary,
                        ),
                      )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start Date:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  trip.startDate?.toLocal().toString().split(' ')[0] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Duration:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${trip.duration} days',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trip Type:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: isGroupTrip ? Colors.blue : Colors.green,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    isGroupTrip ? 'Group Trip' : 'Solo Trip',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isGroupTrip && currentUserParticipant != null) ...[
              const SizedBox(height: 16),
              const Divider(
                thickness: 3.0,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              const Text(
                'Personal Budget & Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              PersonalExpense(
                participant: currentUserParticipant,
                trip: trip,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
