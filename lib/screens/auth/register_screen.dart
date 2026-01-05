import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/db_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyDescController = TextEditingController();
  
  // Default role is set to exhibitor [Inference]
  String _selectedRole = 'exhibitor'; 
  final DbService _dbService = DbService();
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

    if (_selectedRole == 'exhibitor' && 
       (_companyNameController.text.isEmpty || _companyDescController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Company details are required for exhibitors"))
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(_nameController.text.trim());
        
        await _dbService.createUserProfile(
          userCredential.user!,
          role: _selectedRole,
          name: _nameController.text.trim(),
          companyName: _selectedRole == 'exhibitor' ? _companyNameController.text.trim() : '',
          companyDescription: _selectedRole == 'exhibitor' ? _companyDescController.text.trim() : '',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account Created! Please Login."))
          );
          context.pop(); // Returns to Login Screen [Inference]
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Registration Failed"), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            
            if (_selectedRole == 'exhibitor') ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Company Details (Auto-filled for bookings)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(labelText: "Company Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _companyDescController,
                      decoration: const InputDecoration(labelText: "Company Description", border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ],

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