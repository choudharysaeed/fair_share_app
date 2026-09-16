import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fair_share_app/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Dark mode abhi local UI state hai.
  // Baad mein isko proper app theme ke saath connect karenge.
  bool isDarkMode = false;

  // Notifications ka switch
  bool notificationsEnabled = true;

  // Selected currency
  String selectedCurrency = 'PKR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF101918) : const Color(0xFFF4F8F7),

      appBar: AppBar(
        backgroundColor:
            isDarkMode ? const Color(0xFF101918) : const Color(0xFFF4F8F7),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode
                ? Colors.white
                : const Color(0xFF172B3A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // =========================
          // PROFILE SECTION
          // =========================

          _sectionTitle(
            'PROFILE',
            isDarkMode,
          ),

          const SizedBox(height: 10),

          _settingsCard(
            isDarkMode: isDarkMode,
            child: ListTile(
              contentPadding: EdgeInsets.zero,

              leading: const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF087F75),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),

              title: Text(
                'Your Profile',
                style: _titleStyle(isDarkMode),
              ),

              subtitle: Text(
                'Manage your profile information',
                style: _subtitleStyle(isDarkMode),
              ),

              trailing: Icon(
                Icons.chevron_right,
                color: isDarkMode
                    ? Colors.white54
                    : const Color(0xFF71807E),
              ),

              onTap: () {
                // Profile screen baad mein connect karenge.
              },
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // PREFERENCES
          // =========================

          _sectionTitle(
            'PREFERENCES',
            isDarkMode,
          ),

          const SizedBox(height: 10),

          _settingsCard(
            isDarkMode: isDarkMode,
            child: Column(
              children: [
                // Currency
                ListTile(
                  contentPadding: EdgeInsets.zero,

                  leading: Icon(
                    Icons.currency_exchange,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF087F75),
                  ),

                  title: Text(
                    'Currency',
                    style: _titleStyle(isDarkMode),
                  ),

                  subtitle: Text(
                    selectedCurrency,
                    style: _subtitleStyle(isDarkMode),
                  ),

                  trailing: DropdownButton<String>(
                    value: selectedCurrency,
                    underline: const SizedBox(),

                    items: const [
                      DropdownMenuItem(
                        value: 'PKR',
                        child: Text('PKR'),
                      ),
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('USD'),
                      ),
                      DropdownMenuItem(
                        value: 'EUR',
                        child: Text('EUR'),
                      ),
                    ],

                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedCurrency = value;
                      });
                    },
                  ),
                ),

                Divider(
                  color: isDarkMode
                      ? Colors.white12
                      : Colors.black12,
                ),

                // Notifications
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,

                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF087F75),
                  ),

                  title: Text(
                    'Notifications',
                    style: _titleStyle(isDarkMode),
                  ),

                  subtitle: Text(
                    'Receive expense and payment updates',
                    style: _subtitleStyle(isDarkMode),
                  ),

                  value: notificationsEnabled,

                  activeTrackColor: const Color(0xFF087F75),

                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),

                Divider(
                  color: isDarkMode
                      ? Colors.white12
                      : Colors.black12,
                ),

                // Dark mode
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,

                  secondary: Icon(
                    Icons.dark_mode_outlined,
                    color: isDarkMode
                        ? Colors.white70
                        : const Color(0xFF087F75),
                  ),

                  title: Text(
                    'Dark mode',
                    style: _titleStyle(isDarkMode),
                  ),

                  subtitle: Text(
                    'Use dark theme',
                    style: _subtitleStyle(isDarkMode),
                  ),

                  value: isDarkMode,

                  activeTrackColor: const Color(0xFF087F75),

                  onChanged: (value) {
                    setState(() {
                      isDarkMode = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // ACCOUNT
          // =========================

          _sectionTitle(
            'ACCOUNT',
            isDarkMode,
          ),

          const SizedBox(height: 10),

          _settingsCard(
            isDarkMode: isDarkMode,
            child: ListTile(
              contentPadding: EdgeInsets.zero,

              leading: const Icon(
                Icons.logout,
                color: Color(0xFFD65A32),
              ),

              title: const Text(
                'Log out',
                style: TextStyle(
                  color: Color(0xFFD65A32),
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                'Sign out of your FairShare account',
                style: _subtitleStyle(isDarkMode),
              ),

              onTap: () {
                // Existing AuthProvider logout method
                Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();
              },
            ),
          ),

          const SizedBox(height: 30),

          // App version
          Center(
            child: Text(
              'FairShare',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white38
                    : const Color(0xFF9AA5A3),
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 5),

          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: isDarkMode
                    ? Colors.white24
                    : const Color(0xFFB0B9B7),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _sectionTitle(
    String title,
    bool darkMode,
  ) {
    return Text(
      title,
      style: TextStyle(
        color: darkMode
            ? Colors.white54
            : const Color(0xFF71807E),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  // =========================
  // SETTINGS CARD
  // =========================

  Widget _settingsCard({
    required bool isDarkMode,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF192321)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  // =========================
  // TITLE STYLE
  // =========================

  TextStyle _titleStyle(bool darkMode) {
    return TextStyle(
      color: darkMode
          ? Colors.white
          : const Color(0xFF172B3A),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }

  // =========================
  // SUBTITLE STYLE
  // =========================

  TextStyle _subtitleStyle(bool darkMode) {
    return TextStyle(
      color: darkMode
          ? Colors.white54
          : const Color(0xFF71807E),
      fontSize: 11,
    );
  }
}