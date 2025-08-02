import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/widgets/gradient_background.dart';
import '../../common/widgets/app_logo.dart';
import '../../common/widgets/form_card.dart';
import '../../common/widgets/custom_text_field.dart';
import '../../common/widgets/primary_button.dart';
import '../../common/widgets/divider_with_text.dart';
import '../../common/widgets/back_button.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      try {
        await ref
            .read(authNotifierProvider.notifier)
            .signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              userData: {'full_name': _nameController.text.trim()},
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created successfully! Please check your email to verify your account.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Signup failed: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        useSafeArea: false,
        // padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Back Button
              const CustomBackButton(),
              const SizedBox(height: 20),
              // App Logo
              const AppLogo(size: 80, iconSize: 40, borderRadius: 20),
              const SizedBox(height: 20),
              // Title
              Text(
                'Join GeoMentor!',
                style: AppTextStyles.headline.copyWith(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account to start learning',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Signup Form
              FormCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign Up',
                        style: AppTextStyles.subhead.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Name Field
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.person_outlined,
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 20),
                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outlined,
                        isPassword: true,
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 20),
                      // Confirm Password Field
                      CustomTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        icon: Icons.lock_outlined,
                        isPassword: true,
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                      ),
                      const SizedBox(height: 20),
                      // Terms and Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (value) {},
                            activeColor: AppColors.secondary,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Signup Button
                      Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(authNotifierProvider);
                          return PrimaryButton(
                            text: 'Create Account',
                            onPressed: _handleSignup,
                            isLoading: authState.isLoading,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Divider
                      const DividerWithText(text: 'OR'),
                      const SizedBox(height: 24),
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
