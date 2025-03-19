import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'opportunity_card.dart';

class OpportunitiesList extends StatelessWidget {
  final FirebaseFirestore firestore;

  const OpportunitiesList({super.key, required this.firestore});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('volunteer_opportunities').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('No opportunities found'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data()! as Map<String, dynamic>;
            return OpportunityCard(opportunity: data);
          },
        );
      },
    );
  }
}
