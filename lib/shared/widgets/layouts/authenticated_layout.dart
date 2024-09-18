import 'package:flutter/material.dart';
import 'package:udetxen/features/dashboard.trip/screens/dashboard_trip_list_screen.dart';
import 'package:udetxen/features/dashboard.user/screens/user_management_screen.dart';
import 'package:udetxen/features/dashboard.venue/screens/venue_list_screen.dart';
import 'package:udetxen/features/home/screens/home_screen.dart';
import 'package:udetxen/features/profile/screens/profile_screen.dart';
import 'package:udetxen/features/trip.expense/screens/expense_list_screen.dart';
import 'package:udetxen/features/trip/screens/trip_list_screen.dart';
import 'package:udetxen/shared/utils/theme_service.dart';
import 'package:provider/provider.dart';

class AuthenticatedLayout extends StatefulWidget {
  final int currentIndex;
  final bool isAdmin;

  const AuthenticatedLayout(
      {super.key, this.currentIndex = 0, this.isAdmin = false});

  @override
  State<AuthenticatedLayout> createState() => _AuthenticatedLayoutState();
}

class _AuthenticatedLayoutState extends State<AuthenticatedLayout> {
  late int _selectedIndex;

  final List<Widget> _userScreens = [
    const HomeScreen(),
    const TripListScreen(),
    const ExpenseListScreen(),
    const ProfileScreen(),
  ];

  final List<Widget> _adminScreens = [
    const UserManagementScreen(),
    const VenueListScreen(),
    const DashboardTripListScreen()
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: theme.toggleThemeMode,
          ),
        ],
        backgroundColor: Theme.of(context).hintColor,
      ),
      body: widget.isAdmin
          ? _adminScreens[_selectedIndex]
          : _userScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: widget.isAdmin
            ? [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Manage Users',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.location_city),
                  label: 'Venues',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.tour),
                  label: 'Tours',
                ),
              ]
            : [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.airplanemode_active),
                  label: 'Trips',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.attach_money),
                  label: 'Expenses',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
        onTap: _onItemTapped,
      ),
    );
  }
}
