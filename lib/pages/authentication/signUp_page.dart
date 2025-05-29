import 'package:flutter/material.dart';
import '../../services/authentication_client.dart';
import '../../services/validation_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _birthDateError;
  String? _sexError;

  bool _isPasswordVisible = false;
  bool _isFormSubmitted = false;
  bool _isLoading = false;
  String _selectedSex = 'Male'; // Default value

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  void _signup() async {
    setState(() {
      _isFormSubmitted = true;
      _firstNameError = _firstNameController.text.trim().isEmpty ? 'Prenumele este necesar' : null;
      _lastNameError = _lastNameController.text.trim().isEmpty ? 'Numele este necesar' : null;
      _emailError = ValidationService.validateEmail(_emailController.text.trim());
      _passwordError = ValidationService.validatePassword(_passwordController.text.trim());
      _birthDateError = _selectedDate == null ? 'Data nașterii este necesară' : null;
      _sexError = _selectedSex.isEmpty ? 'Sexul este necesar' : null;
    });

    if (_firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _birthDateError == null &&
        _sexError == null) {
      
      setState(() {
        _isLoading = true;
      });

      try {
        final authClient = AuthenticationClient();
        final result = await authClient.createAccount(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          birthDate: _selectedDate!,
          sex: _selectedSex,
        );

        final snackBar = SnackBar(
          content: Text(result.isSuccess ? 'Registration successful' : result.error ?? 'Registration failed'),
          backgroundColor: result.isSuccess ? Colors.green : Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        if (result.isSuccess) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                errorText: _isFormSubmitted ? _firstNameError : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                errorText: _isFormSubmitted ? _lastNameError : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                errorText: _isFormSubmitted ? _emailError : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                errorText: _isFormSubmitted ? _passwordError : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthDateController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                labelText: 'Birth Date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                errorText: _isFormSubmitted ? _birthDateError : null,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSex,
              decoration: InputDecoration(
                labelText: 'Sex',
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                errorText: _isFormSubmitted ? _sexError : null,
              ),
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(value: 'Female', child: Text('Female')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSex = value ?? 'Male';
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _signup,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Register'),
                          ),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}