import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  bool _isValidName(String name) {
    // Only letters and spaces, minimum 3 characters
    final nameRegex = RegExp(r"^[a-zA-Z\s]{3,}$");
    return nameRegex.hasMatch(name);
  }

  bool _isValidEmail(String email) {
    // Strict lowercase-only email validation with explicit popular valid domains (prevents .con typos)
    final emailRegex = RegExp(r"^[a-z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-z0-9]+\.(com|in|org|net|co|io|edu|gov|dev)$");
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    // Minimum 8 characters, at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character
    final passwordRegex = RegExp(r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,}$");
    return passwordRegex.hasMatch(password);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onRegister() async {
    HapticFeedback.mediumImpact();

    final name = _nameController.text.trim();
    // Enforce logic before submitting
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (!_isValidName(name)) {
      _showError('Name must be at least 3 characters long and contain only letters.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showError('Please enter a valid lowercase email address (e.g. john@gmail.com).');
      return;
    }

    if (!_isValidPassword(password)) {
      _showError('Password must be at least 8 characters with uppercase, lowercase, number, and special character.');
      return;
    }

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProv.register(name, email, password);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login with your credentials.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      context.go('/login');
    } else if (mounted) {
      _showError(authProv.errorMessage ?? 'Registration failed');
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
            const Text('Create Account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Register to create your paper trading account', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            
            // Name Field
            const Text('Full Name', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[a-z0-9@.]")), // Forces user to type lowercase only
              ],
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
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
                onPressed: authProv.isLoading ? null : _onRegister,
                child: authProv.isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Already have an account? Login', style: TextStyle(color: Colors.blueAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
