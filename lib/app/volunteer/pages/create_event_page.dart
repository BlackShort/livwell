import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:livwell/app/volunteer/controllers/volunteer_controller.dart';
import 'package:livwell/app/volunteer/models/events_model.dart';

class CreateEventPage extends StatefulWidget {
  final VolunteerController controller;

  const CreateEventPage({super.key, required this.controller});

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
