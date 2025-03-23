import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/profile/controllers/profile_controller.dart';
import 'package:livwell/app/common/widgets/loading_button.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(
                color: AppPallete.primary,
              ));
            }

            if (controller.userModel.value == null) {
              return _buildErrorState(controller);
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(context, controller),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildProfileHeader(controller),
                        const SizedBox(height: 30),
                        _buildProfileForm(controller),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, ProfileController controller) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppPallete.secondary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppPallete.dullprimary.withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              controller.isEditing.value ? Icons.close : Icons.edit,
              color: AppPallete.primary,
            ),
            onPressed: controller.toggleEditMode,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppPallete.primary),
          onPressed: () => _showLogoutConfirmation(context, controller),
        ),
      ],
    );
  }

  Widget _buildErrorState(ProfileController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: AppPallete.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Could not load profile data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.loadUserProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ProfileController controller) {
    final user = controller.userModel.value!;
    final fullName = '${user.firstName} ${user.lastName}'.trim();

    return Column(
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppPallete.dullprimary.withOpacity(0.2),
              backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null || user.photoUrl!.isEmpty
                  ? Text(
                      _getInitials(fullName),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.primary,
                      ),
                    )
                  : null,
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppPallete.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          fullName.isEmpty ? 'User' : fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppPallete.secondary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 5),
        if (user.phone != null && user.phone!.isNotEmpty)
          Text(
            user.phone!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontFamily: 'Poppins',
            ),
          ),
      ],
    );
  }

  Widget _buildProfileForm(ProfileController controller) {
    final isEditing = controller.isEditing.value;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppPallete.secondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            
            // First Name
            _buildFormField(
              controller: controller.firstNameController,
              icon: Icons.person,
              label: 'First Name',
              hint: 'Enter your first name',
              readOnly: !isEditing,
            ),
            const SizedBox(height: 16),

            // Last Name
            _buildFormField(
              controller: controller.lastNameController,
              icon: Icons.person_outline,
              label: 'Last Name',
              hint: 'Enter your last name',
              readOnly: !isEditing,
            ),
            const SizedBox(height: 16),

            // Email
            _buildFormField(
              controller: controller.emailController,
              icon: Icons.email,
              label: 'Email',
              hint: 'Enter your email',
              readOnly: true, // Email should not be editable
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Phone
            _buildFormField(
              controller: controller.phoneController,
              icon: Icons.phone,
              label: 'Phone',
              hint: 'Enter your phone number',
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
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    required bool readOnly,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: AppPallete.primary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(
    BuildContext context,
    ProfileController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppPallete.secondary,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
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