import 'package:fair_share_app/providers/group_provider.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _currencyController = TextEditingController(text: "PKR");
  final _emailController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  String _currentUserName = '';
  String _currentUserEmail = '';

  final List<Map<String, String>> _invitedMembers = [];

  bool _isInviting = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final user = await _firestoreService.getUserById(userId);

    if (user != null && mounted) {
      setState(() {
        final firstName = user['firstName'] ?? '';
        final lastName = user['lastName'] ?? '';
        _currentUserName = '$firstName $lastName'.trim();
        _currentUserEmail = user['email'] ?? '';
      });
    }
  }

  Future<void> _inviteMember() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      return;
    }

    if (email == _currentUserEmail) {
      _showError("That's your own email.");
      return;
    }

    final alreadyInvited = _invitedMembers.any(
      (member) => member['email'] == email,
    );

    if (alreadyInvited) {
      _showError('This member is already invited.');
      return;
    }

    setState(() {
      _isInviting = true;
    });

    final user = await _firestoreService.getUserByEmail(email);

    if (!mounted) return;

    setState(() {
      _isInviting = false;
    });

    if (user == null) {
      _showError('No registered user found with this email.');
      return;
    }

    final firstName = user['firstName'] ?? '';
    final lastName = user['lastName'] ?? '';
    final name = '$firstName $lastName'.trim();

    setState(() {
      _invitedMembers.add({
        'uid': user['uid'] ?? user['id'] ?? '',
        'name': name.isEmpty ? email : name,
        'email': email,
      });
      _emailController.clear();
    });
  }

  void _removeInvite(String email) {
    setState(() {
      _invitedMembers.removeWhere((member) => member['email'] == email);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    final currency = _currencyController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter group name');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    final groupId = await groupProvider.createGroup(
      name: name,
      userId: userId,
      currency: currency,
    );

    for (final member in _invitedMembers) {
      final uid = member['uid'];
      if (uid != null && uid.isNotEmpty) {
        await groupProvider.addMemberToGroup(groupId: groupId, userId: uid);
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Group created successfully')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New group'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'GROUP NAME',
                hintText: 'e.g. Hunza Trip',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _currencyController,
              decoration: const InputDecoration(
                labelText: 'CURRENCY',
                hintText: 'e.g. PKR',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'MEMBERS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),

            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  _currentUserName.isEmpty ? 'You' : '$_currentUserName (You)',
                ),
                subtitle: const Text('Owner'),
              ),
            ),

            ..._invitedMembers.map((member) {
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(member['name'] ?? ''),
                  subtitle: const Text(
                    'invite sent',
                    style: TextStyle(color: Colors.orange),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeInvite(member['email']!),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Add member by email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isInviting ? null : _inviteMember,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087F75),
                    foregroundColor: Colors.white,
                  ),
                  child: _isInviting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Invite'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF087F75),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}