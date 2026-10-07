import 'package:fair_share_app/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fair_share_app/providers/group_provider.dart';

import 'package:fair_share_app/screens/groups/group_details_screen.dart';
import 'package:fair_share_app/screens/groups/create_group_screen.dart';

import 'package:fair_share_app/screens/activity/activity_screen.dart';
import 'package:fair_share_app/screens/settings/settings_screen.dart';
import 'package:fair_share_app/utils/theme_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final GroupProvider _groupProvider;
  List<dynamic> _lastGroups = const [];

  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser!.uid;
    _groupProvider = context.read<GroupProvider>();

    Future.microtask(() {
      _groupProvider.listenToGroups(userId);
      context.read<HomeProvider>().loadUserInitials();
    });
  }

  void _onNavigationChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildGroupsHome(),
      const ActivityScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.pageBackground(context),

      body: screens[_selectedIndex],

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF087F75),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateGroupScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavigationChanged,

        backgroundColor: AppColors.surface(context),

        selectedItemColor: const Color(0xFF087F75),
        unselectedItemColor: AppColors.secondaryText(context),

        selectedFontSize: 11,
        unselectedFontSize: 11,

        type: BottomNavigationBarType.fixed,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            activeIcon: Icon(Icons.access_time_filled),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsHome() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Your groups',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText(context),
                    ),
                  ),
                ),

                Consumer<HomeProvider>(
                  builder: (context, home, child) {
                    return CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF087F75),
                      child: Text(
                        home.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<GroupProvider>(
              builder: (context, groupProvider, child) {
                final groups = groupProvider.groups;

                if (!identical(groups, _lastGroups)) {
                  _lastGroups = groups;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      context.read<HomeProvider>().loadBalances(groups);
                    }
                  });
                }

                if (groups.isEmpty) {
                  return _buildEmptyGroups();
                }

                return Column(
                  children: [
                    Consumer<HomeProvider>(
                      builder: (context, home, child) {
                        final amount = home.overallOwed;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF087F75),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "OVERALL YOU'RE OWED",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.7,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Rs ${amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'across ${groups.length} '
                                '${groups.length == 1 ? 'group' : 'groups'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    Consumer<HomeProvider>(
                      builder: (context, home, child) {
                        final amount = home.overallOwe;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD65A32),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "OVERALL YOU OWE",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.7,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                'Rs ${amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'across ${groups.length} '
                                '${groups.length == 1 ? 'group' : 'groups'}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'GROUPS',
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];

                          return _buildGroupCard(group);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(dynamic group) {
    return Consumer<HomeProvider>(
      builder: (context, home, child) {
        final balance = home.balanceFor(group.id);

        final bool positive = balance > 0;
        final bool negative = balance < 0;

        String balanceText;

        if (balance == 0) {
          balanceText = 'settled';
        } else if (positive) {
          balanceText = '+${group.currency} ${balance.toStringAsFixed(0)}';
        } else {
          balanceText =
              '-${group.currency} ${balance.abs().toStringAsFixed(0)}';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          color: AppColors.surface(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailsScreen(group: group),
                ),
              );

              if (!mounted) return;
              context.read<HomeProvider>().loadBalances(_groupProvider.groups);
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.iconChipBackground(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.diamond_outlined,
                      color: Color(0xFF087F75),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText(context),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'You, ${group.memberIds.length > 1 ? '${group.memberIds.length - 1} others' : 'only member'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText(context),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '${group.memberIds.length} members',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.tertiaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: positive
                          ? const Color(0xFFE3F3E9)
                          : negative
                          ? const Color(0xFFFDE9E1)
                          : const Color(0xFFE9EEEE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      balanceText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: positive
                            ? const Color(0xFF268A4B)
                            : negative
                            ? const Color(0xFFD65A32)
                            : const Color(0xFF647270),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyGroups() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.groups_outlined,
            size: 70,
            color: Color(0xFF087F75),
          ),

          const SizedBox(height: 15),

          Text(
            'No groups yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Create a group to start sharing expenses.',
            style: TextStyle(color: AppColors.secondaryText(context)),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGroupScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF087F75),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create group'),
          ),
        ],
      ),
    );
  }
}