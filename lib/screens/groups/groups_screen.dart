import 'package:fair_share_app/providers/group_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();

    final userId = FirebaseAuth.instance.currentUser!.uid;

    Future.microtask(() {
      Provider.of<GroupProvider>(context, listen: false).listenToGroups(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Groups"), centerTitle: true),

      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.groups.isEmpty){
            return const Center(
              child: Text("No groups found", style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            itemCount: groupProvider.groups.length,
            itemBuilder: (context, index) {
              final group = groupProvider.groups[index];

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.group)),

                title: Text(group.name),

                subtitle: Text(group.currency),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
