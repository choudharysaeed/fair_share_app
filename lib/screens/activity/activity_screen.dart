import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fair_share_app/providers/activity_provider.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      Future.microtask(() {
        Provider.of<ActivityProvider>(
          context,
          listen: false,
        ).listenToActivities(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F7),

      appBar: AppBar(
        title: const Text(
          'Activity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B3A),
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFF4F8F7),
        elevation: 0,
      ),

      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          // Loading
          if (provider.isLoading && provider.activities.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF087F75),
              ),
            );
          }

          if (provider.errorMessage != null &&
              provider.activities.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          if (provider.activities.isEmpty) {
            return _buildEmptyActivity();
          }

          // Activity list
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            itemCount: provider.activities.length,
            itemBuilder: (context, index) {
              final activity = provider.activities[index];

              return _buildActivityCard(activity);
            },
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(dynamic activity) {
    IconData icon;

    // Select icon according to activity type
    switch (activity.type) {
      case 'expense_added':
        icon = Icons.receipt_long_outlined;
        break;

      case 'expense_updated':
        icon = Icons.edit_outlined;
        break;

      case 'expense_deleted':
        icon = Icons.delete_outline;
        break;

      case 'settlement':
        icon = Icons.payments_outlined;
        break;

      default:
        icon = Icons.notifications_none;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F2EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF087F75),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B3A),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF71807E),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  activity.groupName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF087F75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          if (activity.amount != null)
            Text(
              'Rs ${activity.amount!.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF087F75),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivity() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.access_time,
            size: 65,
            color: Color(0xFF087F75),
          ),

          const SizedBox(height: 15),

          const Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B3A),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your recent expenses and settlements\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF71807E),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}