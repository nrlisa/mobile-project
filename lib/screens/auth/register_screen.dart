import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  // Default role is set to exhibitor [Inference]
  String _selectedRole = 'exhibitor'; 
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    // Basic validation to ensure no empty strings are sent to Firebase [Inference]
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields"))
      );
      return;
    }

    setState(() => _isLoading = true);

    // This call triggers the logic to create the User Auth and the Firestore document [Inference]
    String? error = await _authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      role: _selectedRole, // Passes 'organizer', 'exhibitor', or 'admin' [Inference]
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created! Please Login."))
        );
        context.pop(); // Returns to Login Screen [Inference]
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red)
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Visual branding or instruction can go here [Speculation]
            const Text(
              "Join the Exhibition Management System",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            TextField(
              controller: _nameController, 
              decoration: const InputDecoration(
                labelText: "Full Name", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              )
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _emailController, 
              decoration: const InputDecoration(
                labelText: "Email", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              )
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _passwordController, 
              obscureText: true, 
              decoration: const InputDecoration(
                labelText: "Password", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              )
            ),
            const SizedBox(height: 16),
            
            // Dropdown to select the specific user role [Inference]
            DropdownButtonFormField<String>(
              initialValue: _selectedRole, 
              decoration: const InputDecoration(
                labelText: "I am a...",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'exhibitor', child: Text("Exhibitor (Book Booths)")),
                DropdownMenuItem(value: 'organizer', child: Text("Organizer (Create Events)")),
                DropdownMenuItem(value: 'admin', child: Text("Admin (System Manager)")),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            
            const SizedBox(height: 32),
            
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Register Account", style: TextStyle(fontSize: 16)),
                  ),
          ],
        ),
      ),
    );
  }
}