import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:livwell/app/volunteer/controllers/volunteer_controller.dart';
import 'package:livwell/app/volunteer/models/events_model.dart';

// Main Volunteer Page with Tabs
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
            // Registered Events Tab
            _buildRegisteredEventsTab(),

            // Your Events Tab
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
        return _buildEmptyState(
          'You haven\'t registered for any events yet',
          'Explore events and start volunteering to make a difference!',
        );
      }

      return ListView.builder(
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
      );
    });
  }

  Widget _buildMyEventsTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.myEvents.isEmpty) {
        return _buildEmptyState(
          'You haven\'t created any events yet',
          'Create an event to start recruiting volunteers!',
        );
      }

      return ListView.builder(
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

// Create Event Page
class CreateEventPage extends StatefulWidget {
  final VolunteerController controller;

  const CreateEventPage({Key? key, required this.controller}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageUrlController = TextEditingController();
  final locationController = TextEditingController();
  final spotsController = TextEditingController(text: '10');
  final durationController = TextEditingController(text: '2');

  final List<String> categories = [
    'Education',
    'Environment',
    'Health',
    'Animals',
    'Community Service',
    'Disaster Relief',
    'Elderly Care',
    'Food Bank',
    'Homeless',
    'Youth',
  ];

  String selectedCategory = 'Community Service';
  bool isVirtual = false;
  DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay selectedTime = TimeOfDay.now();
  List<String> selectedSkills = [];

  final List<String> skillOptions = [
    'Teaching',
    'Communication',
    'Leadership',
    'Administration',
    'Social Media',
    'First Aid',
    'Cooking',
    'Driving',
    'Counseling',
    'Photography',
    'Programming',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Event Title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event title';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Event Description
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Event Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Image URL
            TextFormField(
              controller: imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an image URL';
                }
                if (!Uri.tryParse(value)!.isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items:
                  categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Is Virtual Switch
            SwitchListTile(
              title: const Text('Virtual Event'),
              value: isVirtual,
              onChanged: (value) {
                setState(() {
                  isVirtual = value;
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: Colors.orange,
            ),

            const SizedBox(height: 16),

            // Location
            if (!isVirtual)
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (!isVirtual && (value == null || value.isEmpty)) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),

            if (!isVirtual) const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('EEEE, MMMM d, y').format(selectedDate)),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Time Picker
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(selectedTime.format(context)),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Duration
            TextFormField(
              controller: durationController,
              decoration: InputDecoration(
                labelText: 'Duration (hours)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter duration';
                }
                final duration = int.tryParse(value);
                if (duration == null || duration <= 0) {
                  return 'Please enter a valid duration';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Available Spots
            TextFormField(
              controller: spotsController,
              decoration: InputDecoration(
                labelText: 'Available Spots',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter available spots';
                }
                final spots = int.tryParse(value);
                if (spots == null || spots <= 0) {
                  return 'Please enter a valid number of spots';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Skills
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Required Skills',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      skillOptions.map((skill) {
                        final isSelected = selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedSkills.add(skill);
                              } else {
                                selectedSkills.remove(skill);
                              }
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: Colors.orange,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Create Event',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime.now().add(const Duration(days: 365)),
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(
  //           colorScheme: const ColorScheme.light(
  //             primary: Colors.orange,
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  // }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.orange),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.orange),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _createEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          Get.snackbar('Error', 'You must be logged in to create an event');
          return;
        }

        // Create a DateTime that combines the selected date and time
        final eventTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        // Create unique ID for the event
        final eventId =
            FirebaseFirestore.instance.collection('events').doc().id;

        // Create the event model
        final newEvent = EventModel(
          id: eventId,
          title: titleController.text,
          description: descriptionController.text,
          imageUrl: imageUrlController.text,
          category: selectedCategory,
          location: isVirtual ? 'Virtual' : locationController.text,
          date: selectedDate,
          time: eventTime,
          duration: int.parse(durationController.text),
          spots: int.parse(spotsController.text),
          registeredCount: 0,
          organizerId: user.uid,
          organizerName: user.displayName ?? 'Anonymous',
          skills: selectedSkills,
          isVirtual: isVirtual,
        );

        // Save the event using the controller
        await widget.controller.createEvent(newEvent);
      } catch (e) {
        Get.snackbar('Error', 'Failed to create event: $e');
      }
    }
  }
}
