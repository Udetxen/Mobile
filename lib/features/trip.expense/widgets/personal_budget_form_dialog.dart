import 'package:flutter/material.dart';
import 'package:udetxen/features/trip.expense/services/expense_service.dart';
import 'package:udetxen/shared/types/models/trip.dart';

class PersonalBudgetFormDialog extends StatefulWidget {
  final ExpenseService expenseService;
  final Trip trip;
  final Participant participant;
  final Function(Trip) onSave;

  const PersonalBudgetFormDialog({
    super.key,
    required this.expenseService,
    required this.trip,
    required this.participant,
    required this.onSave,
  });

  @override
  State<PersonalBudgetFormDialog> createState() =>
      _PersonalBudgetFormDialogState();
}

class _PersonalBudgetFormDialogState extends State<PersonalBudgetFormDialog> {
  late TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: widget.participant.personalBudget?.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Personal Budget'),
      content: TextField(
        decoration: const InputDecoration(
          labelText: 'Budget',
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        controller: _budgetController,
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
            if (double.tryParse(_budgetController.text) != null) {
              try {
                final newBudget = double.parse(_budgetController.text);

                final newTrip = await widget.expenseService.setPersonalBudget(
                  widget.trip.uid!,
                  newBudget,
                );

                widget.onSave(newTrip);
                Navigator.of(context).pop();
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid budget value')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
