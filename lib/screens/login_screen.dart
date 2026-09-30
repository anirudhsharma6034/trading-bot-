import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool _isValidEmail(String email) {
    // Strict lowercase-only email validation with specific valid domains (prevents .con typos)
    final emailRegex = RegExp(r"^[a-z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-z0-9]+\.(com|in|org|net|co|io|edu|gov)$");
    return emailRegex.hasMatch(email);
  }

  void _onLogin() async {
    HapticFeedback.mediumImpact(); 

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid lowercase email address', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.login(email, password);

    if (success && mounted) {
      context.go('/main');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1), 
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProv.errorMessage ?? 'Invalid email or password', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome Back', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Sign in with your registered account', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            
            const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-z0-9@.]")), // Forces lowercase only at typing level
              ],
              decoration: InputDecoration(
                hintText: 'enter your email',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                onPressed: authProv.isLoading ? null : _onLogin,
                child: authProv.isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Login', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Don\'t have an account? Register', style: TextStyle(color: Colors.blueAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
