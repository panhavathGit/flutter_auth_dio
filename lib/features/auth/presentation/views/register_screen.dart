import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../../core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController(); // username
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    // Determine if we are on Step 1 or Step 2
    bool isOtpSent = viewModel.state == AuthState.otpSent;

    return Scaffold(
      appBar: AppBar(title: Text(isOtpSent ? 'Verify OTP' : 'Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isOtpSent ? 'Verification' : 'Register',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Text(isOtpSent ? 'Enter the code sent to your phone' : 'Enter your phone to get started',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),

              // STEP 1: Phone Input (Hidden when OTP is sent)
              if (!isOtpSent) ...[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildButton(
                  label: 'Get OTP',
                  isLoading: viewModel.isLoading,
                  onPressed: () => _requestOtp(viewModel),
                ),
              ],

              // STEP 2: OTP & Password (Shown only after OTP is sent)
              if (isOtpSent) ...[
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                    prefixIcon: Icon(Icons.vibration),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildButton(
                  label: 'Complete Registration',
                  isLoading: viewModel.isLoading,
                  onPressed: () => _completeRegister(viewModel),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => viewModel.resetToIdle(),
                    child: const Text('Change Phone Number'),
                  ),
                ),
              ],
              
              if (viewModel.state == AuthState.error)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(viewModel.errorMessage ?? 'Error occurred',
                      style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String label, required bool isLoading, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading ? const CircularProgressIndicator() : Text(label),
      ),
    );
  }

  // Logic for Step 1
  Future<void> _requestOtp(AuthViewModel vm) async {
    await vm.requestOtp(_phoneController.text.trim());
    if (vm.state == AuthState.otpSent && mounted) {
      // THE REALISTIC WAY: Show the OTP in a snackbar so you can type it
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DEBUG MODE OTP: ${vm.generatedOtp}'),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Logic for Step 2
  Future<void> _completeRegister(AuthViewModel vm) async {
    final success = await vm.register(
      username: _phoneController.text.trim(),
      password: _passwordController.text,
      otp: _otpController.text.trim(),
    );

    if (success && mounted) {
      context.goNamed(AppRoutes.main);
    }
  }
}