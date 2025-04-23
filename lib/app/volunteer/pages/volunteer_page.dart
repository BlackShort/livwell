import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:livwell/app/volunteer/controllers/volunteer_controller.dart';
import 'package:livwell/app/volunteer/models/events_model.dart';
import 'package:livwell/app/volunteer/pages/create_event_page.dart';

class VolunteerPage extends StatelessWidget {
  VolunteerPage({super.key});

  final VolunteerController controller = Get.put(VolunteerController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Volunteer'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: [Tab(text: 'REGISTERED'), Tab(text: 'YOUR EVENTS')],
          ),
        ),
        body: TabBarView(
          children: [
            // Registered Events Tab with Pull-to-Refresh
            _buildRegisteredEventsTab(),

            // Your Events Tab with Pull-to-Refresh
            _buildMyEventsTab(),
          ],
        ),
        floatingActionButton: Obx(
          () =>
              controller.isLoading.value
                  ? const SizedBox.shrink()
                  : FloatingActionButton(
                    onPressed:
                        () => Get.to(
                          () => CreateEventPage(controller: controller),
                        ),
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.add),
                  ),
        ),
      ),
    );
  }

  Widget _buildRegisteredEventsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.registeredEvents.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshRegisteredEvents,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: Get.height * 0.8,
                child: _buildEmptyState(
                  'You haven\'t registered for any events yet',
                  'Explore events and start volunteering to make a difference!',
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRegisteredEvents,
        color: Colors.orange,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.registeredEvents.length,
          itemBuilder: (context, index) {
            final event = controller.registeredEvents[index];
            return _buildEventCard(
              event: event,
              isRegistered: true,
              onPressed: () => controller.cancelRegistration(event.id),
              buttonText: 'Cancel Registration',
              buttonColor: Colors.red,
            );
          },
        ),
      );
    });
  }

  Widget _buildMyEventsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.myEvents.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshMyEvents,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: Get.height * 0.8,
                child: _buildEmptyState(
                  'You haven\'t created any events yet',
                  'Create an event to start recruiting volunteers!',
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshMyEvents,
        color: Colors.orange,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myEvents.length,
          itemBuilder: (context, index) {
            final event = controller.myEvents[index];
            return _buildEventCard(
              event: event,
              isOwner: true,
              onPressed: () => _showDeleteConfirmation(event),
              buttonText: 'Delete Event',
              buttonColor: Colors.red,
            );
          },
        ),
      );
    });
  }

  Widget _buildEventCard({
    required EventModel event,
    bool isRegistered = false,
    bool isOwner = false,
    required VoidCallback onPressed,
    required String buttonText,
    required Color buttonColor,
  }) {
    final dateFormat = DateFormat('E, MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              event.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (ctx, err, _) => Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        event.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description
                Text(
                  event.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 16),

                // Date & Time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(event.date),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeFormat.format(event.time),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      event.isVirtual ? Icons.computer : Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.isVirtual ? 'Virtual Event' : event.location,
                        style: TextStyle(color: Colors.grey.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Spots
                Row(
                  children: [
                    Text(
                      '${event.registeredCount}/${event.spots} volunteers',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value:
                              event.spots > 0
                                  ? event.registeredCount / event.spots
                                  : 0,
                          backgroundColor: Colors.grey.shade200,
                          color: Colors.orange,
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Skills
                if (event.skills.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        event.skills.take(3).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(EventModel event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone and will remove all registrations.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteEvent(event.id);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
