import 'package:flutter/material.dart';
import 'package:udetxen/features/auth/services/auth_service.dart';
import 'package:udetxen/features/trip.expense/screens/expense_detail_screen.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/widgets/loader.dart';

import '../services/expense_service.dart';
import 'budget_summary.dart';
import 'expense_item.dart';
import 'expense_list.dart';

class TripCard extends StatelessWidget {
  final Trip trip;

  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();
    final expenseService = getIt<ExpenseService>();
    final currentUserId = authService.currentUserUid;

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

    return GestureDetector(
      onTap: () => Navigator.of(context).push(ExpenseDetailScreen.route(trip)),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trip.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ExpenseList(trip: trip),
              if (isGroupTrip && currentUserParticipant != null) ...[
                Divider(
                  color: Theme.of(context).primaryColor,
                  thickness: 5,
                  height: 48,
                ),
                const Center(
                  child: Text(
                    'Personal Budget',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StreamBuilder<List<Expense>>(
                  stream: expenseService
                      .getExpenses(currentUserParticipant.expenseUids ?? []),
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
                          (currentUserParticipant?.personalBudget ?? 0.0) -
                              totalExpense;
                      double progress = totalExpense /
                          (currentUserParticipant?.personalBudget ?? 1.0);

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BudgetSummary(
                              budget:
                                  currentUserParticipant?.personalBudget ?? 0.0,
                              totalExpense: totalExpense,
                              remainingBudget: remainingBudget,
                              progress: progress,
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: expenses.length,
                              itemBuilder: (context, index) {
                                return ExpenseItem(
                                  expense: expenses[index],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
