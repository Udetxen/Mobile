import 'package:flutter/material.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';

class ExpenseListScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout(
      currentIndex: 2,
    );
  }

  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
