import 'package:fair_share_app/models/group_model.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class AddMemberScreen extends StatefulWidget {
  final GroupModel group;

  const AddMemberScreen({super.key, required this.group});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final emailController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic>? foundUser;

  bool isSearching = false;
  bool isAdding = false;

  Future<void> searchUser() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter email")));
      return;
    }

    setState(() {
      isSearching = true;
      foundUser = null;
    });

    final user = await _firestoreService.getUserByEmail(email);

    setState(() {
      foundUser = user;
      isSearching = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User not found")));
    }
  }

  Future<void> addMember() async {
    if (foundUser == null) {
      return;
    }

    final userId = foundUser!['id'];

    setState(() {
      isAdding = true;
    });

    await _firestoreService.addMemberToGroup(
      groupId: widget.group.id,
      userId: userId,
    );

    setState(() {
      isAdding = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Member added successfully")));

    Navigator.pop(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Member"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "User Email",
                hintText: "Enter registered user's email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSearching ? null : searchUser,
                child: isSearching
                    ? const CircularProgressIndicator()
                    : const Text("Search User"),
              ),
            ),

            const SizedBox(height: 30),

            if (foundUser != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person, size: 30),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "${foundUser!['firstName'] ?? ''} "
                        "${foundUser!['lastName'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        foundUser!['email'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isAdding ? null : addMember,
                          child: isAdding
                              ? const CircularProgressIndicator()
                              : const Text("Add Member"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
