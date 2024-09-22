import 'package:flutter/material.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:udetxen/features/trip.expense/services/expense_service.dart';
import 'package:udetxen/shared/types/models/expense.dart';
import 'package:udetxen/shared/types/models/expense_category.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'package:udetxen/shared/utils/decor/input_decoration.dart';
import 'package:udetxen/shared/widgets/loader.dart';

class ExpenseFormDialog extends StatefulWidget {
  final ExpenseService expenseService;
  final Trip trip;
  final Expense? expense;
  final Function(Trip) onSave;

  const ExpenseFormDialog({
    super.key,
    required this.expenseService,
    required this.trip,
    this.expense,
    required this.onSave,
  });

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  late TextEditingController _expenseNameController;
  late TextEditingController _budgetController;
  late TextEditingController _expenseAmountController;
  late List<String> _selectedCategoryUids;
  late List<ExpenseCategory> _categories;

  @override
  void initState() {
    super.initState();
    _expenseNameController =
        TextEditingController(text: widget.expense?.name ?? '');
    _budgetController =
        TextEditingController(text: widget.expense?.budget.toString() ?? '0');
    _expenseAmountController =
        TextEditingController(text: widget.expense?.expense?.toString() ?? '0');
    _selectedCategoryUids = widget.expense?.categoryUids ?? [];
    _categories = [];
  }

  @override
  void dispose() {
    _expenseNameController.dispose();
    _budgetController.dispose();
    _expenseAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExpenseCategory>>(
      future: widget.expenseService.getExpenseCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading(isFullScreen: false);
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          _categories = snapshot.data ?? [];
          return AlertDialog(
            title: Text(
                widget.expense == null ? 'Add New Expense' : 'Edit Expense'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration:
                      getInputDecoration(context, labelText: 'Expense Name'),
                  controller: _expenseNameController,
                  autofocus: widget.expense == null,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: getInputDecoration(context, labelText: 'Budget'),
                  keyboardType: TextInputType.number,
                  controller: _budgetController,
                ),
                const SizedBox(height: 8),
                if (widget.expense == null)
                  TextField(
                    decoration: getInputDecoration(context,
                        labelText:
                            'Expense Amount ${widget.expense == null ? '(Optional)' : ''}'),
                    keyboardType: TextInputType.number,
                    controller: _expenseAmountController,
                    autofocus: widget.expense != null,
                  ),
                const SizedBox(height: 8),
                MultiSelectDialogField(
                  items: _categories
                      .map((category) =>
                          MultiSelectItem(category.uid, category.name))
                      .toList(),
                  initialValue: _selectedCategoryUids,
                  title: const Text("Categories"),
                  itemsTextStyle:
                      TextStyle(color: Theme.of(context).primaryColor),
                  selectedItemsTextStyle:
                      TextStyle(color: Theme.of(context).focusColor),
                  selectedColor: Theme.of(context).focusColor,
                  onConfirm: (results) {
                    _selectedCategoryUids = results.cast<String>();
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
                  if (_expenseNameController.text.isNotEmpty &&
                      double.tryParse(_budgetController.text) != null &&
                      _selectedCategoryUids.isNotEmpty) {
                    try {
                      if (widget.expense == null) {
                        final newTrip =
                            await widget.expenseService.createExpenseForTrip(
                          widget.trip.uid!,
                          Expense(
                            name: _expenseNameController.text,
                            budget: double.parse(_budgetController.text),
                            categoryUids: _selectedCategoryUids,
                            expense: double.tryParse(
                                        _expenseAmountController.text) !=
                                    0
                                ? double.tryParse(_expenseAmountController.text)
                                : null,
                          ),
                        );
                        widget.onSave(newTrip);
                      } else {
                        await widget.expenseService.updateExpense(
                          widget.trip.uid!,
                          widget.expense!.uid!,
                          widget.expense!.copyWith(
                            name: _expenseNameController.text,
                            budget: double.parse(_budgetController.text),
                            // expense: double.tryParse(
                            //             _expenseAmountController.text) !=
                            //         0
                            //     ? double.tryParse(_expenseAmountController.text)
                            //     : null,
                            categoryUids: _selectedCategoryUids,
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                    } catch (e) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                child: Text(widget.expense == null ? 'Add' : 'Save'),
              ),
            ],
          );
        }
      },
    );
  }
}
