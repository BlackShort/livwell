import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/activity/controllers/activity_controller.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});
  
  @override
  State createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize the controller if not already done
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final activityController = Get.find<ActivityController>();
    
    return Scaffold(
      backgroundColor: AppPallete.white,
      appBar: AppBar(
        backgroundColor: AppPallete.white,
        elevation: 0,
        title: const Text(
          'My Activity',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              activityController.openAddHours();
            },
            child: Text(
              '+ Add Hours',
              style: TextStyle(
                color: AppPallete.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppPallete.primary,
            unselectedLabelColor: AppPallete.grey,
            indicatorColor: AppPallete.primary,
            tabs: const [
              Tab(text: 'Hours'),
              Tab(text: 'Opportunities'),
            ],
          ),
          
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Hours Tab
                _buildHoursTab(activityController),
                
                // Opportunities Tab
                const Center(child: Text('Opportunities will appear here')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
  
  Widget _buildHoursTab(ActivityController controller) {
    return Obx(() {
      return controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total approved hours',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.tune, color: AppPallete.grey),
                        onPressed: () {
                          controller.openFilterOptions();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${controller.totalHours.value}h ${controller.totalMinutes.value}m',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  
                  // Activity Items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.activities.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final activity = controller.activities[index];
                      return _buildActivityItem(activity);
                    },
                  ),
                ],
              ),
            );
    });
  }
  
  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final Color statusColor = activity['status'] == 'Approved' 
        ? Colors.green 
        : Colors.orange;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock, size: 14, color: AppPallete.grey),
              const SizedBox(width: 4),
              Text(
                '${activity['hours']}h',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                activity['status'],
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (activity['status'] == 'Pending')
                IconButton(
                  icon: Icon(Icons.edit, size: 16, color: AppPallete.grey),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Get.find<ActivityController>().editActivity(activity['id']);
                  },
                ),
              Text(
                activity['date'],
                style: TextStyle(
                  color: AppPallete.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity['type'],
            style: TextStyle(
              color: AppPallete.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            activity['title'],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: activity['organizationColor'] ?? AppPallete.primary,
                radius: 12,
                child: activity['organizationIcon'] != null
                    ? Image.asset(
                        activity['organizationIcon'],
                        width: 16,
                        height: 16,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 12,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                activity['organization'],
                style: TextStyle(
                  color: AppPallete.blackSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
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
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
      currentIndex: 2,
      onTap: (index) {
        if (index != 2) {
          // Handle navigation to other tabs
        }
      },
    );
  }
}