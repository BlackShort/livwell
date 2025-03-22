import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:livwell/app/activity/pages/activity_page.dart';
import 'package:livwell/app/home/controllers/home_controller.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class JoinOrgPage extends StatelessWidget {
  final Map opportunity;
  final String docId;

  const JoinOrgPage({
    super.key,
    required this.opportunity,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.white,
      appBar: AppBar(
        backgroundColor: AppPallete.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppPallete.secondary,
            size: 19,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.find<HomeController>().shareOrganization(docId);
            },
            icon: SvgPicture.asset(
              'assets/icons/share_out.svg',
              width: 19,
              height: 19,
              colorFilter: const ColorFilter.mode(
                AppPallete.blackSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Organization logo and name
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            opportunity['logoBackgroundColor'] ??
                            AppPallete.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child:
                            opportunity['logoUrl'] != null
                                ? Image.network(
                                  opportunity['logoUrl'],
                                  width: 50,
                                  height: 50,
                                  errorBuilder:
                                      (context, error, stackTrace) => Icon(
                                        Icons.nature,
                                        color: AppPallete.white,
                                        size: 40,
                                      ),
                                )
                                : Icon(
                                  Icons.nature,
                                  color: AppPallete.white,
                                  size: 40,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      opportunity['organization'] ?? 'Organization Name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Organization description
              Text(
                opportunity['description'] ??
                    'Join this organization in order to see their private events.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppPallete.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Join button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.find<HomeController>().joinOrganization(docId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Join',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Navigation tabs
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      labelColor: AppPallete.primary,
                      unselectedLabelColor: AppPallete.grey,
                      indicatorColor: AppPallete.primary,
                      tabs: const [
                        Tab(text: 'Volunteer'),
                        Tab(text: 'Programs'),
                        Tab(text: 'About'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400, // Adjust height as needed
                      child: TabBarView(
                        children: [
                          // Volunteer Tab
                          _buildVolunteerTab(),

                          // Programs Tab
                          Center(child: Text('Programs Content')),

                          // About Tab
                          Center(child: Text('About Content')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildVolunteerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ways to Volunteer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search, color: AppPallete.blackSecondary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.tune, color: AppPallete.blackSecondary),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      opportunity['imageUrl'] ??
                          'https://via.placeholder.com/400x200',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: 150,
                            color: AppPallete.grey.withOpacity(0.3),
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppPallete.grey,
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Mon',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppPallete.grey,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            '22',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppPallete.blackSecondary,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'Jul',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppPallete.grey,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: AppPallete.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(
                          Radius.circular(12),
                        ),
                      ),
                      child: _getOrgIcon(opportunity['orgIconType']),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Row(
                      spacing: 10,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: AppPallete.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '8:30 AM (EDT)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppPallete.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '3 Shifts',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppPallete.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppPallete.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Columbus, OH, USA',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppPallete.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tortoise Habitat Restoration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppPallete.primary,
                              radius: 12,
                              child: Icon(
                                Icons.nature,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Tortoise Conservancy',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          '3 Spots Left',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppPallete.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppPallete.primary,
      unselectedItemColor: AppPallete.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism),
          label: 'Volunteer',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_number),
          label: 'Registrations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Activity',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
      ],
      currentIndex: 0,
      onTap: (index) {
        if (index == 2) {
          Get.to(() => const ActivityPage());
        }
      },
    );
  }

  Widget _getOrgIcon(String? iconType) {
    switch (iconType) {
      case 'eco':
        return const Icon(Icons.eco, color: AppPallete.dullprimary, size: 16);
      case 'pets':
        return const Icon(Icons.pets, color: AppPallete.dullprimary, size: 16);
      case 'sports':
        return const Icon(
          Icons.sports_basketball,
          color: AppPallete.snackErrorBg,
          size: 16,
        );
      default:
        return const Icon(Icons.eco, color: AppPallete.dullprimary, size: 16);
    }
  }
}
