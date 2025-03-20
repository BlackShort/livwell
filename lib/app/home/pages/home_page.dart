import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:livwell/config/theme/app_pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showMyOrgs = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.white,
      appBar: AppBar(
        title: const Text(
          'LivWell',
          style: TextStyle(
            color: AppPallete.primary,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // Implement search functionality
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
              // Implement filter functionality
            },
            icon: SvgPicture.asset(
              'assets/icons/slider_out.svg',
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(
                AppPallete.blackSecondary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildOrgChips(),
          Expanded(child: _buildOpportunitiesList()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [_buildTab('My Orgs', true), _buildTab('Near Me', false)],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMyOrgs = text == 'My Orgs';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color:
                  (_showMyOrgs && isSelected) || (!_showMyOrgs && !isSelected)
                      ? AppPallete.dullprimary
                      : AppPallete.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                (_showMyOrgs && isSelected) || (!_showMyOrgs && !isSelected)
                    ? AppPallete.dullprimary
                    : AppPallete.grey,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Widget _buildOrgChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('organizations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No organizations found'));
          }

          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildAddChip(),
              ...snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                String iconName = data['icon'] ?? 'eco';
                IconData iconData = Icons.eco;

                // Map string icon names to IconData
                switch (iconName) {
                  case 'eco':
                    iconData = Icons.eco;
                    break;
                  case 'pets':
                    iconData = Icons.pets;
                    break;
                  case 'sports':
                    iconData = Icons.sports;
                    break;
                  default:
                    iconData = Icons.eco;
                }

                return _buildOrgChip(
                  data['name'] ?? 'Unknown',
                  Icon(iconData, color: AppPallete.dullprimary),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddChip() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        backgroundColor: Colors.grey[200],
        radius: 20,
        child: const Icon(Icons.add, color: Colors.grey),
      ),
    );
  }

  Widget _buildOrgChip(String name, Icon icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppPallete.white,
            radius: 14,
            child: icon,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunitiesList() {
    Query query = _firestore.collection('volunteer_opportunities');

    // Add filtering based on the selected tab
    if (_showMyOrgs) {
      // In a real app, you would get the current user's registered orgs
      // and filter opportunities based on those organizations
      query = query.where('organizationId', whereIn: ['org1', 'org2']);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No opportunities found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snapshot.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String docId = doc.id;
            return _buildOpportunityCard(data, docId);
          },
        );
      },
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opportunity, String docId) {
    // Extract the Timestamp and convert to DateTime
    Timestamp timestamp = opportunity['date'] ?? Timestamp.now();
    DateTime date = timestamp.toDate();

    return Card(
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
                      // Toggle favorite status in Firestore
                      _firestore
                          .collection('volunteer_opportunities')
                          .doc(docId)
                          .update({
                            'isFavorite': !(opportunity['isFavorite'] ?? false),
                          });
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
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
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
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppPallete.white,
                          radius: 12,
                          child: _getOrgIcon(opportunity['orgIconType']),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          opportunity['organization'] ?? 'Mid-Ohio Foodbank',
                          style: const TextStyle(color: AppPallete.grey),
                        ),
                      ],
                    ),
                    Text(
                      '${opportunity['spotsLeft'] ?? 5} Spots Left',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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