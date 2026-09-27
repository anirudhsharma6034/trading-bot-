import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Color(0xFF2563EB), child: Icon(Icons.person, size: 40, color: Colors.white)),
            const SizedBox(height: 16),
            const Text('Trader Demo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('trader@example.com', style: TextStyle(color: Colors.grey)),
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
                onPressed: () => context.go('/login'),
                child: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
