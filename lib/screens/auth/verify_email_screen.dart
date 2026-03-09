import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;

  Future<void> _resend() async {
    setState(() => _sending = true);
    final error = await context.read<AuthProvider>().resendVerification();
    setState(() => _sending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Verification email sent!'),
          backgroundColor: error != null ? AppColors.error : AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color:        AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.mark_email_unread_outlined, color: AppColors.gold, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email',
                style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'We sent a verification link to your email address. Please click the link to activate your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey, height: 1.5),
              ),
              const SizedBox(height: 40),
              GoldButton(
                label:     'Resend Email',
                onPressed: _resend,
                isLoading: _sending,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => auth.signOut(),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: AppColors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
