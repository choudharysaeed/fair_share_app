import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fair_share_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String _email = '';
  String _memberSince = '';

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final user = await _firestoreService.getUserById(userId);

    if (mounted) {
      setState(() {
        if (user != null) {
          _firstNameController.text = user['firstName'] ?? '';
          _lastNameController.text = user['lastName'] ?? '';
          _email = user['email'] ?? '';

          final createdAt = user['createdAt'];
          if (createdAt is Timestamp) {
            final date = createdAt.toDate();
            _memberSince = '${date.day}/${date.month}/${date.year}';
          }
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name cannot be empty')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;

    await _firestoreService.updateUserName(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF087F75),
                      child: Text(
                        _firstNameController.text.isNotEmpty
                            ? _firstNameController.text[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: _firstNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'First name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _lastNameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Last name',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(_email),
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Member since'),
                    subtitle: Text(_memberSince),
                  ),

                  if (_isEditing) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF087F75),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save changes'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}