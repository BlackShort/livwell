import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/core/utils/firestore_seeder.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          onPressed: () {
            Get.to(SeedDatabaseScreen());
          },
          icon: const Icon(Icons.upload),
          color: Colors.grey,
        ),
      ),
    );
  }
}
