import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:udetxen/features/trip.expense/services/expense_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:udetxen/shared/config/theme/colors.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/expense_category.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final Trip trip;
  final bool? isAdding;

  static route(Trip trip, {bool? isAdding}) {
    return MaterialPageRoute<void>(
      builder: (_) => ExpenseDetailScreen(
        trip: trip,
        isAdding: isAdding,
      ),
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
        String expenseName = expense?.name ?? '';
        double budget = expense?.budget ?? 0;
        double expenseAmount = expense?.expense ?? 0;
        List<String> selectedCategoryUids = expense?.categoryUids ?? [];
        List<ExpenseCategory> categories = [];

        return FutureBuilder<List<ExpenseCategory>>(
          future: _expenseService.getExpenseCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              categories = snapshot.data ?? [];
              return AlertDialog(
                title:
                    Text(expense == null ? 'Add New Expense' : 'Edit Expense'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: getInputDecoration(context,
                          labelText: 'Expense Name'),
                      controller: TextEditingController(text: expenseName),
                      onChanged: (value) {
                        expenseName = value;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration:
                          getInputDecoration(context, labelText: 'Budget'),
                      keyboardType: TextInputType.number,
                      controller:
                          TextEditingController(text: budget.toString()),
                      onChanged: (value) {
                        budget = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: getInputDecoration(context,
                          labelText:
                              'Expense Amount ${expense == null ? '(Optional)' : ''}'),
                      keyboardType: TextInputType.number,
                      controller:
                          TextEditingController(text: expenseAmount.toString()),
                      onChanged: (value) {
                        expenseAmount = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    const SizedBox(height: 8),
                    MultiSelectDialogField(
                      items: categories
                          .map((category) =>
                              MultiSelectItem(category.uid, category.name))
                          .toList(),
                      initialValue: selectedCategoryUids,
                      title: const Text("Categories"),
                      itemsTextStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      selectedItemsTextStyle:
                          TextStyle(color: Theme.of(context).focusColor),
                      selectedColor: Theme.of(context).focusColor,
                      onConfirm: (results) {
                        selectedCategoryUids = results.cast<String>();
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (expenseName.isNotEmpty &&
                          budget > 0 &&
                          selectedCategoryUids.isNotEmpty) {
                        if (expense == null) {
                          final newTrip =
                              await _expenseService.createExpenseForTrip(
                            trip.uid!,
                            Expense(
                              name: expenseName,
                              budget: budget,
                              categoryUids: selectedCategoryUids,
                            ),
                          );
                          setState(() {
                            trip = newTrip;
                          });
                        } else {
                          _expenseService.updateExpense(
                            expense.uid!,
                            expense.copyWith(
                              name: expenseName,
                              budget: budget,
                              expense: expenseAmount,
                              categoryUids: selectedCategoryUids,
                            ),
                          );
                        }
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(expense == null ? 'Add' : 'Save'),
                  ),
                ],
              );
            }
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
        title: Text(trip.name),
        backgroundColor: Theme.of(context).hintColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showExpenseFormDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Expense>>(
          stream: _expenseService.getExpenses(trip.expenseUids ?? []),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
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
                  Text(
                    'Budget: \$${budget.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Expense: \$${totalExpense.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remaining Budget: ${remainingBudget < 0.0 ? '-' : ''}\$${remainingBudget.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: remainingBudget < 0
                          ? Colors.red
                          : Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress >= 1.0 ? 1.0 / progress : progress,
                    backgroundColor:
                        progress >= 1.0 ? AppColors.error : Colors.grey[300],
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              expense.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Budget: \$${expense.budget.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Expense: \$${expense.expense?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Categories: ${expense.categories?.map((c) => c.name).join(', ')}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showExpenseFormDialog(expense: expense);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
