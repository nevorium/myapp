import 'package:flutter/material.dart';
import 'package:myapp/models/user_profile.dart';
import 'package:myapp/screens/profile/profile_screen.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:provider/provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

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
      body: StreamProvider<List<UserProfile>>.value(
        value: _firestoreService.getAllUserProfiles(),
        initialData: const [],
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLeaderboardList(isWeekly: true),
            _buildLeaderboardList(isWeekly: false),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList({required bool isWeekly}) {
    return Consumer<List<UserProfile>>(
      builder: (context, userProfiles, child) {
        if (userProfiles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Sort users by XP
        userProfiles.sort((a, b) => b.xp.compareTo(a.xp));

        return ListView.builder(
          itemCount: userProfiles.length,
          itemBuilder: (context, index) {
            final user = userProfiles[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.avatarUrlSmall != null
                    ? NetworkImage(user.avatarUrlSmall!)
                    : null,
                child: user.avatarUrlSmall == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user.name ?? 'Anonymous'),
              subtitle: Text('${user.xp} XP'),
              trailing: Text(
                '#${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(), // TODO: Pass user id to view other profiles
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
