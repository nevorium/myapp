import 'package:flutter/material.dart';
import 'package:myapp/screens/ai/ai_screen.dart';
import 'package:myapp/screens/analysis/analysis_screen.dart';
import 'package:myapp/screens/dashboard/dashboard_screen.dart';
import 'package:myapp/screens/journal/journal_screen.dart';
import 'package:myapp/screens/leaderboard/leaderboard_screen.dart';

/// # Main Screen
/// This is the main stateful widget that acts as the root of the application
/// after the user logs in. It hosts the `BottomNavigationBar` and manages the
/// currently displayed page.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // The index of the currently selected tab.
  int _selectedIndex = 0;

  // A list of the pages that will be displayed for each tab.
  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    AnalysisScreen(),
    LeaderboardScreen(),
    AiScreen(),
    JournalScreen(),
  ];

  /// ## _onItemTapped
  /// This function is called when a tab in the BottomNavigationBar is tapped.
  /// It updates the state with the new selected index.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_rounded),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar_rounded),
            label: 'Jurnal',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
