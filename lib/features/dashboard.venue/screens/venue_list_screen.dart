import 'package:flutter/material.dart';
import 'package:udetxen/shared/widgets/layouts/authenticated_layout.dart';

class VenueListScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => getInstance(),
    );
  }

  static Widget getInstance() {
    return const AuthenticatedLayout(
      isAdmin: true,
      currentIndex: 1,
    );
  }

  const VenueListScreen({super.key});

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
