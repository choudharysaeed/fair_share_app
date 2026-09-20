import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fair_share_app/providers/activity_provider.dart';
import 'package:fair_share_app/utils/theme_color.dart';

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
      backgroundColor: AppColors.pageBackground(context),

      appBar: AppBar(
        title: Text(
          'Activity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText(context),
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.pageBackground(context),
        elevation: 0,
      ),

      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.activities.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF087F75)),
            );
          }

          if (provider.errorMessage != null && provider.activities.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (provider.activities.isEmpty) {
            return _buildEmptyActivity();
          }

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

      case 'settlement_paid':
      case 'settlement_received':
        icon = Icons.payments_outlined;
        break;

      default:
        icon = Icons.notifications_none;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.iconChipBackground(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF087F75)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText(context),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText(context),
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
          const Icon(Icons.access_time, size: 65, color: Color(0xFF087F75)),

          const SizedBox(height: 15),

          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText(context),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Your recent expenses and settlements\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}