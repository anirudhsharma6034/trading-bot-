import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, AuthProvider authProv) {
    final nameController = TextEditingController(text: authProv.currentUser?.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                authProv.updateProfileName(nameController.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final user = authProv.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context, authProv),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Color(0xFF2563EB), child: Icon(Icons.person, size: 40, color: Colors.white)),
            const SizedBox(height: 16),
            Text(user?.name ?? 'Trader Demo', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user?.email ?? 'trader@example.com', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Advanced Analytics'),
              onTap: () => context.push('/analytics'),
            ),
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text('Backtesting Engine'),
              onTap: () => context.push('/backtest'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Strategy Builder'),
              onTap: () => context.push('/strategy-builder'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                onPressed: () {
                  authProv.logout();
                  context.go('/login');
                },
                child: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
