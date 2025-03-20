import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/auth/controllers/auth_controller.dart';
import 'package:livwell/app/auth/widgets/custom_text_field.dart';
import 'package:livwell/app/common/widgets/loading_button.dart';
import 'package:livwell/app/common/widgets/secondary_button.dart';
import 'package:livwell/config/constants/app_constants.dart';
import 'package:livwell/config/theme/app_pallete.dart';
import 'package:livwell/core/errors/custom_snackbar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthController controller = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final RxBool _isLoading = false.obs;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  // Regular expressions stored as constants to avoid recreation
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _signUp() async {
    if (!_validateForm()) return;

    _isLoading.value = true;
    try {
      await controller.signUp({
        "email": _emailController.text.trim(),
        'password': _passwordController.text,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(title: 'Error', message: e.toString());
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _signUpWithProvider(Future<void> Function() signInMethod) async {
    if (!_agreeToTerms) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Please agree to the Terms of Use and Privacy Policy',
      );
      return;
    }

    _isLoading.value = true;
    try {
      await signInMethod();
      if (mounted) {
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(title: 'Error', message: e.toString());
      }
    } finally {
      _isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (!_agreeToTerms) {
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Please agree to the Terms of Use and Privacy Policy',
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                color: AppPallete.secondary,
                size: 19,
              ),
              SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                  color: AppPallete.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 19,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSocialButtons(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 24),
              _buildRegistrationForm(),
              const SizedBox(height: 24),
              _buildSignInPrompt(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(child: Image.asset(AppConstants.applogo, height: 80, width: 80)),
        const SizedBox(height: 10),
        const Text(
          'Create your personal account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: AppPallete.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Want to add a nonprofit to LivWell? That step comes later.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: AppPallete.blackSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        SecondaryButton(
          text: 'Continue with Google',
          onPressed: () => _signUpWithProvider(controller.signInWithGoogle),
          icon: AppConstants.google,
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          text: 'Continue with Apple',
          onPressed: () => _signUpWithProvider(controller.signInWithApple),
          icon: AppConstants.apple,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            prefixIcon: Icons.person_rounded,
            labelText: 'First Name',
            hintText: 'First Name',
            controller: _firstNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            prefixIcon: Icons.person_rounded,
            labelText: 'Last Name',
            hintText: 'Last Name',
            controller: _lastNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            prefixIcon: Icons.email_rounded,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            labelText: 'Email',
            hintText: 'Enter your email',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!_emailRegex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            prefixIcon: Icons.lock_rounded,
            labelText: 'Password',
            hintText: 'Enter your password',
            controller: _passwordController,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            prefixIcon: Icons.lock_person_rounded,
            labelText: 'Confirm Password',
            hintText: 'Confirm Password',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: _toggleConfirmPasswordVisibility,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTermsCheckbox(),
          const SizedBox(height: 24),
          Obx(
            () => LoadingButton(
              text: 'Continue',
              isLoading: _isLoading.value,
              onPressed: _signUp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          activeColor: const Color(0xFFF79631),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text.rich(
              TextSpan(
                text:
                    'By continuing, you agree to that you are at least 13 years old. Plus, you agree to all this legal stuff: ',
                children: [
                  TextSpan(
                    text: 'Terms of Use',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFFF79631),
                    ),
                    // recognizer: () {}, // GestureRecognizer for Terms
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'Community Guidelines',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFFF79631),
                    ),
                    // recognizer: () {}, // GestureRecognizer for Guidelines
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFFF79631),
                    ),
                    // recognizer: () {}, // GestureRecognizer for Privacy
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppPallete.dullprimary,
            ),
          ),
        ),
      ],
    );
  }
}
