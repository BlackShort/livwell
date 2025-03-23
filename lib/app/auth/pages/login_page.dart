import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/auth/controllers/auth_controller.dart';
import 'package:livwell/app/auth/pages/forgot_password_page.dart';
import 'package:livwell/app/auth/pages/signup_page.dart';
import 'package:livwell/app/auth/widgets/custom_text_field.dart';
import 'package:livwell/app/common/widgets/loading_button.dart';
import 'package:livwell/app/common/widgets/secondary_button.dart';
import 'package:livwell/config/constants/app_constants.dart';
import 'package:livwell/config/theme/app_pallete.dart';
import 'package:form_validator/form_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController controller = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Regular expressions stored as constants to avoid recreation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
  );

  // Cache validators to avoid rebuilding them
  late final emailValidator =
      ValidationBuilder()
          .required('Email is required')
          .regExp(_emailRegex, 'Please enter a valid email address')
          .build();

  late final passwordValidator =
      ValidationBuilder()
          .required('Password is required')
          .regExp(
            _passwordRegex,
            'Password must be at least 8 characters long and include:\n• 1 uppercase letter\n• 1 lowercase letter\n• 1 number\n• 1 special character (!@#\$&*~)',
          )
          .build();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      await controller.signIn({
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildSocialLoginButtons(),
                      const SizedBox(height: 24),
                      _buildSignUpPrompt(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(child: Image.asset(AppConstants.applogo, height: 80, width: 80)),
        const SizedBox(height: 10),
        const Text(
          'Welcome back!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: AppPallete.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            prefixIcon: Icons.email_rounded,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            labelText: 'Email',
            hintText: 'Enter your email',
            validator: emailValidator,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            prefixIcon: Icons.lock_rounded,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: _togglePasswordVisibility,
            ),
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            labelText: 'Password',
            hintText: 'Enter your password',
            obscureText: _obscurePassword,
            validator: passwordValidator,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Get.to(ForgotPasswordPage());
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppPallete.primary,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: LoadingButton(
                text: 'Sign In',
                isLoading: controller.isLoading.value,
                onPressed: _handleSignIn,
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        SecondaryButton(
          text: 'Continue with Google',
          onPressed: controller.signInWithGoogle,
          icon: AppConstants.google,
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          text: 'Continue with Apple',
          onPressed: controller.signInWithApple,
          icon: AppConstants.apple,
        ),
      ],
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        TextButton(
          onPressed: () => Get.to(const SignupPage()),
          child: const Text(
            'Sign Up',
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
