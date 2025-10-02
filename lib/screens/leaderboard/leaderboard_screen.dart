import 'package:flutter/material.dart';

// A data model for the user leaderboard entry
class UserLeaderboardEntry {
  final String name;
  final int xp;
  final String avatarUrl;

  UserLeaderboardEntry(
      {required this.name, required this.xp, required this.avatarUrl});
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data
  final List<UserLeaderboardEntry> _weeklyLeaderboard = [
    UserLeaderboardEntry(
        name: 'Ali', xp: 1500, avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d'),
    UserLeaderboardEntry(
        name: 'Aisyah', xp: 1200, avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704e'),
    UserLeaderboardEntry(
        name: 'Umar', xp: 1000, avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704f'),
  ];

  final List<UserLeaderboardEntry> _allTimeLeaderboard = [
    UserLeaderboardEntry(
        name: 'Khadijah', xp: 25000, avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704a'),
    UserLeaderboardEntry(
        name: 'Abu Bakar', xp: 22000, avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704b'),
    UserLeaderboardEntry(
        name: 'Usman', xp: 20000, avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704c'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardList(_weeklyLeaderboard),
          _buildLeaderboardList(_allTimeLeaderboard),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<UserLeaderboardEntry> leaderboard) {
    return ListView.builder(
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final user = leaderboard[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          title: Text(user.name),
          trailing: Text('${user.xp} XP'),
        );
      },
    );
  }
}
