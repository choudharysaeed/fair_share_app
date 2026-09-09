import 'package:fair_share_app/providers/group_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final nameController = TextEditingController();

  final currencyController = TextEditingController(text: "PKR");

  void createGroup() async {
    final name = nameController.text.trim();

    final currency = currencyController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter group name")));

      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;

    await Provider.of<GroupProvider>(
      context,
      listen: false,
    ).createGroup(name: name, userId: userId, currency: currency);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Group created successfully")));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                hintText: "e.g. Trip to Lahore",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: currencyController,
              decoration: const InputDecoration(
                labelText: "Currency",
                hintText: "e.g. PKR",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: createGroup,
              child: const Text("Create Group"),
            ),
          ],
        ),
      ),
    );
  }
}
