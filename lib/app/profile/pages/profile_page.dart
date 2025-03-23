import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/profile/controllers/profile_controller.dart';
import 'package:livwell/app/auth/widgets/custom_text_field.dart';
import 'package:livwell/app/common/widgets/loading_button.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(
        firstNameController: firstNameController,
        lastNameController: lastNameController,
        emailController: emailController,
        phoneController: phoneController,
      ),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: AppPallete.secondary,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              Obx(
                () =>
                    controller.isEditing.value
                        ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppPallete.secondary,
                          ),
                          onPressed: controller.toggleEditMode,
                        )
                        : IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppPallete.secondary,
                          ),
                          onPressed: controller.toggleEditMode,
                        ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: AppPallete.secondary),
                onPressed: () => _showLogoutConfirmation(context, controller),
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.userModel.value == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Could not load profile data',
                      style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.loadUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primary,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(controller),
                    const SizedBox(height: 30),
                    _buildProfileForm(controller),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    final user = controller.userModel.value!;
    final fullName = '${user.firstName} ${user.lastName}'.trim();

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppPallete.dullprimary.withOpacity(0.2),
          backgroundImage:
              user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
          child:
              user.photoUrl == null || user.photoUrl!.isEmpty
                  ? Text(
                    _getInitials(fullName),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.dullprimary,
                    ),
                  )
                  : null,
        ),
        const SizedBox(height: 12),
        Text(
          fullName.isEmpty ? 'User' : fullName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppPallete.secondary,
          ),
        ),
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm(ProfileController controller) {
    return Obx(() {
      final isEditing = controller.isEditing.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // First Name
          CustomTextField(
            prefixIcon: Icons.person,
            controller: controller.firstNameController,
            labelText: 'First Name',
            hintText: 'Enter your first name',
            readOnly: !isEditing,
          ),
          const SizedBox(height: 16),

          // Last Name
          CustomTextField(
            prefixIcon: Icons.person,
            controller: controller.lastNameController,
            labelText: 'Last Name',
            hintText: 'Enter your last name',
            readOnly: !isEditing,
          ),
          const SizedBox(height: 16),

          // Email
          CustomTextField(
            prefixIcon: Icons.email,
            controller: controller.emailController,
            labelText: 'Email',
            hintText: 'Enter your email',
            readOnly: true, // Email should not be editable
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Phone
          CustomTextField(
            prefixIcon: Icons.phone,
            controller: controller.phoneController,
            labelText: 'Phone',
            hintText: 'Enter your phone number',
            readOnly: !isEditing,
            keyboardType: TextInputType.phone,
          ),

          if (isEditing) ...[
            const SizedBox(height: 32),
            LoadingButton(
              text: 'Save Changes',
              isLoading: controller.isLoading.value,
              onPressed: controller.updateProfile,
            ),
          ],
        ],
      );
    });
  }

  void _showLogoutConfirmation(
    BuildContext context,
    ProfileController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.logout();
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    String initials = '';

    if (nameParts.isNotEmpty) {
      if (nameParts[0].isNotEmpty) {
        initials += nameParts[0][0].toUpperCase();
      }

      if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
        initials += nameParts[1][0].toUpperCase();
      }
    }

    return initials;
  }
}
