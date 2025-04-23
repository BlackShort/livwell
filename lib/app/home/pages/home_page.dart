import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:livwell/app/auth/models/user_model.dart';
import 'package:livwell/app/home/pages/join_org_page.dart';
import 'package:livwell/app/notification/pages/notification_page.dart';
import 'package:livwell/app/search/pages/search_pge.dart';
import 'package:livwell/config/constants/app_constants.dart';
import 'package:livwell/core/services/user_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:livwell/config/theme/app_pallete.dart';
import 'package:livwell/app/home/controllers/home_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());
  final ScrollController _scrollController = ScrollController();
  final UserModel? currentUser = UserPreferences.getUserModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.white,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(
                currentUser?.photoUrl ?? AppConstants.user,
              ),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(width: 10),
            Text(
              'Hi ${currentUser?.firstName ?? 'User'}',
              style: const TextStyle(
                color: AppPallete.primary,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              Get.to((SearchPage()));
            },
            icon: SvgPicture.asset(
              'assets/icons/search_out.svg',
              width: 19,
              height: 19,
              colorFilter: const ColorFilter.mode(
                AppPallete.blackSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Get.to(NotificationPage());
            },
            icon: SvgPicture.asset(
              'assets/icons/bell_out.svg',
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
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppPallete.dullprimary,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // _buildTabBar(),
            // _buildOrgChips(),
            _buildOpportunitiesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunitiesList() {
    return Obx(() {
      // First, check if loading
      if (controller.isLoading) {
        return _buildShimmerOpportunities();
      }

      // Only show empty state if not loading
      if (!controller.isLoading && controller.opportunities.isEmpty) {
        return Container(
          height: 300, // Give enough height for empty state
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.event_busy, size: 60, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                controller.selectedOrgId.isNotEmpty
                    ? 'No opportunities found for this organization'
                    : 'No opportunities found',
                style: const TextStyle(color: Colors.grey),
              ),
              if (controller.selectedOrgId.isNotEmpty)
                TextButton(
                  onPressed:
                      () => controller.filterByOrg(controller.selectedOrgId),
                  child: const Text('Clear filter'),
                ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: controller.opportunities.length,
        itemBuilder: (context, index) {
          DocumentSnapshot doc = controller.opportunities[index];
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String docId = doc.id;
          return _buildOpportunityCard(data, docId);
        },
      );
    });
  }

  Widget _buildShimmerOpportunities() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 150, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: 200, height: 16, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150,
                            height: 16,
                            color: Colors.white,
                          ),
                          Container(width: 80, height: 16, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opportunity, String docId) {
    // Extract the Timestamp and convert to DateTime
    Timestamp timestamp = opportunity['date'] ?? Timestamp.now();
    DateTime date = timestamp.toDate();

    return InkWell(
      onTap: () {
        Get.to(JoinOrgPage(opportunity: opportunity, docId: docId));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    opportunity['imageUrl'] ??
                        'https://via.placeholder.com/400x200',
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.image, size: 50)),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPallete.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
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
                    decoration: const BoxDecoration(
                      color: AppPallete.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        opportunity['isFavorite'] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                            opportunity['isFavorite'] == true
                                ? AppPallete.dullprimary
                                : null,
                      ),
                      onPressed: () {
                        // Use controller to toggle favorite
                        controller.toggleFavorite(
                          docId,
                          opportunity['isFavorite'] ?? false,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        opportunity['time'] ?? '8:00 AM (EDT)',
                        style: const TextStyle(color: AppPallete.grey),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${opportunity['shifts'] ?? 3} Shifts',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppPallete.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          opportunity['location'] ??
                              '3960 Brookham Drive Grove City, OH',
                          style: const TextStyle(color: AppPallete.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    opportunity['title'] ??
                        'Pantry Assistant at The Kroger Community Food Pantry',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Filter by this organization when clicked
                          if (opportunity['organizationId'] != null) {
                            controller.filterByOrg(
                              opportunity['organizationId'],
                            );
                          }
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppPallete.white,
                              radius: 12,
                              child: _getOrgIcon(opportunity['orgIconType']),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              opportunity['organization'] ??
                                  'Mid-Ohio Foodbank',
                              style: const TextStyle(
                                color: AppPallete.grey,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${opportunity['spotsLeft'] ?? 5} Spots Left',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to map string icon types to Icon widgets
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
