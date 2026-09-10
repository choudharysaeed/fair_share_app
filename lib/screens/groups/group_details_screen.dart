import 'package:fair_share_app/models/group_model.dart';
import 'package:fair_share_app/screens/groups/add_member_screen.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatelessWidget {
  final GroupModel group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: Text(group.name), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Text(
              "Currency: ${group.currency}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 15),

            Text(
              "Members: ${group.memberIds.length}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            const Text(
              "Members",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: group.memberIds.length,

                itemBuilder: (context, index) {
                  final memberId = group.memberIds[index];

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: firestoreService.getUserById(memberId),

                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text("Loading..."),
                        );
                      }

                      if (!snapshot.hasData) {
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(memberId),
                        );
                      }

                      final user = snapshot.data!;

                      final firstName = user['firstName'] ?? '';
                      final lastName = user['lastName'] ?? '';
                      final email = user['email'] ?? '';

                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),

                        title: Text("$firstName $lastName"),

                        subtitle: Text(email),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMemberScreen(group: group),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
