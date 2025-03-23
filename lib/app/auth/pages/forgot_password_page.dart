import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/auth/controllers/auth_controller.dart';
import 'package:livwell/app/auth/widgets/custom_text_field.dart';
import 'package:livwell/app/common/widgets/loading_button.dart';
import 'package:livwell/config/constants/app_constants.dart';
import 'package:livwell/config/theme/app_pallete.dart';
import 'package:form_validator/form_validator.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final AuthController controller = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  // Regular expressions stored as constants to avoid recreation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Cache validators to avoid rebuilding them
  late final emailValidator =
      ValidationBuilder()
          .required('Email is required')
          .regExp(_emailRegex, 'Please enter a valid email address')
          .build();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      await controller.resetPassword(emailController.text.trim());
    }
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildResetForm(),
                      const SizedBox(height: 24),
                      _buildSignInPrompt(),
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
          'Forgot Password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: AppPallete.secondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildResetForm() {
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
          const SizedBox(height: 32),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: LoadingButton(
                text: 'Reset Password',
                isLoading: controller.isLoading.value,
                onPressed: _handleResetPassword,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Remember your password?",
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