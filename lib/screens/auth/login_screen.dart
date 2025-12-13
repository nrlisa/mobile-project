import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 0 = Exhibitor, 1 = Organizer, 2 = Admin
  int _selectedRoleIndex = 0; 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Basic Validation (Empty Fields)
    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate Network Delay (Security/Robustness)
    await Future.delayed(const Duration(milliseconds: 800));

    // --- FIX IS HERE: Check if screen is still valid ---
    if (!mounted) return; 
    // --------------------------------------------------

    setState(() => _isLoading = false);

    // 2. ROLE ENFORCEMENT LOGIC
    if (_selectedRoleIndex == 0) {
      // Exhibitor Check
      if (email == "exhibitor@test.com" || email.contains("exhibitor")) {
        context.go('/exhibitor');
      } else {
        _showError("Access Denied: That email is not registered as an Exhibitor.");
      }
    } else if (_selectedRoleIndex == 1) {
      // Organizer Check
      if (email == "organizer@test.com" || email.contains("organizer")) {
        context.go('/organizer');
      } else {
        _showError("Access Denied: That email is not registered as an Organizer.");
      }
    } else {
      // Admin Check
      if (email == "admin@test.com" || email.contains("admin")) {
        context.go('/admin'); 
      } else {
        _showError("Access Denied: You do not have Admin privileges.");
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.lock_person_rounded, 
                  size: 64, 
                  color: AppTheme.primaryBlue
                ),
              ),
              const SizedBox(height: 40),

              // Login Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Secure Login", 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textBlack
                      ),
                    ),
                    const SizedBox(height: 8),
                     const Text(
                      "Select your role to continue", 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    // Role Selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _buildRoleTab("Exhibitor", 0),
                          _buildRoleTab("Organizer", 1),
                          _buildRoleTab("Admin", 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email Input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email Address", 
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: "exhibitor@test.com", 
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    TextField(
                      controller: _passwordController,
                      obscureText: true, 
                      decoration: const InputDecoration(
                        labelText: "Password", 
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)
                        ),
                      ),
                      child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Text("Login"),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      "Test Accounts:\nexhibitor@test.com\norganizer@test.com\nadmin@test.com",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/guest'),
                        child: const Text("Continue as Guest", style: TextStyle(color: AppTheme.textGrey)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String label, int index) {
    final isSelected = _selectedRoleIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _selectedRoleIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected 
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] 
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}