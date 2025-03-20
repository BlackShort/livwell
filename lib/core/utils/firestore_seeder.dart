import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// A utility class for seeding Firestore with initial data.
/// This can be used to populate your database with sample volunteer opportunities,
/// organizations, users, and registrations.
class FirestoreSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize Firestore with sample data.
  /// Call this method once during development to seed your database.
  Future<void> seedDatabase() async {
    await _seedOrganizations();
    await _seedOpportunities();
    await _seedUsers();
    await _seedRegistrations();
  }

  /// Seed the organizations collection.
  Future<void> _seedOrganizations() async {
    final organizations = [
      {
        'id': 'org1',
        'name': 'Mid-Ohio Foodbank',
        'icon': 'eco',
        'iconColor': 'green',
        'description': 'Fighting hunger in central Ohio',
        'website': 'https://midohiofoodbank.org'
      },
      {
        'id': 'org2',
        'name': 'Tortoise Conservation',
        'icon': 'pets',
        'iconColor': 'green',
        'description': 'Protecting endangered tortoise species',
        'website': 'https://tortoiseconservation.org'
      }
    ];

    for (var org in organizations) {
      await _firestore
          .collection('organizations')
          .doc(org['id'] as String)
          .set(org);
    }
    print('Organizations seeded successfully!');
  }

  /// Seed the volunteer_opportunities collection.
  Future<void> _seedOpportunities() async {
    final opportunities = [
      {
        'id': 'opportunity1',
        'title': 'Pantry Assistant at The Kroger Community Food Pantry',
        'organization': 'Mid-Ohio Foodbank',
        'organizationId': 'org1',
        'location': '3960 Brookham Drive Grove City, OH',
        'date': Timestamp.fromDate(DateTime(2025, 7, 29)),
        'time': '8:00 AM (EDT)',
        'shifts': 3,
        'spotsLeft': 5,
        'imageUrl': 'https://your-storage-url.com/foodbank-image.jpg',
        'isFavorite': false,
        'orgIconType': 'eco',
        'description': 'Help sort and distribute food to community members in need.'
      },
      {
        'id': 'opportunity2',
        'title': 'Basketball Event Assistant',
        'organization': 'Local Sports Association',
        'organizationId': 'org2',
        'location': '123 Sports Ave, Columbus, OH',
        'date': Timestamp.fromDate(DateTime(2025, 8, 16)),
        'time': '9:00 AM (EDT)',
        'shifts': 2,
        'spotsLeft': 3,
        'imageUrl': 'https://your-storage-url.com/basketball-image.jpg',
        'isFavorite': true,
        'orgIconType': 'sports',
        'description': 'Assist with organizing a youth basketball tournament.'
      }
    ];

    for (var opportunity in opportunities) {
      await _firestore
          .collection('volunteer_opportunities')
          .doc(opportunity['id'] as String)
          .set(opportunity);
    }
    print('Volunteer opportunities seeded successfully!');
  }

  /// Seed the users collection.
  Future<void> _seedUsers() async {
    final users = [
      {
        'id': 'user1',
        'displayName': 'Jane Doe',
        'email': 'jane@example.com',
        'registeredOrgs': ['org1', 'org2'],
        'favoriteOpportunities': ['opportunity2']
      }
    ];

    for (var user in users) {
      await _firestore.collection('users').doc(user['id'] as String).set(user);
    }
    print('Users seeded successfully!');
  }

  /// Seed the registrations collection.
  Future<void> _seedRegistrations() async {
    final registrations = [
      {
        'id': 'registration1',
        'opportunityId': 'opportunity1',
        'userId': 'user1',
        'registeredAt': Timestamp.fromDate(DateTime(2025, 7, 25)),
        'status': 'confirmed'
      }
    ];

    for (var registration in registrations) {
      await _firestore
          .collection('registrations')
          .doc(registration['id'] as String)
          .set(registration);
    }
    print('Registrations seeded successfully!');
  }
}

/// A widget that demonstrates how to use the FirestoreSeeder.
class SeedDatabaseScreen extends StatelessWidget {
  const SeedDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seed Database'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final seeder = FirestoreSeeder();
                try {
                  await seeder.seedDatabase();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database seeded successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error seeding database: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Seed Database'),
            ),
          ],
        ),
      ),
    );
  }
}