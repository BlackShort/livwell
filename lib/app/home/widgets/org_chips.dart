import 'package:flutter/material.dart';

class OrgChips extends StatelessWidget {
  const OrgChips({super.key});

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
          CircleAvatar(backgroundColor: Colors.white, radius: 14, child: icon),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildAddChip(),
          _buildOrgChip('Mid-Ohio Foodbank', const Icon(Icons.eco, color: Colors.green)),
          _buildOrgChip('Tortoise Conservation', const Icon(Icons.pets, color: Colors.green)),
        ],
      ),
    );
  }
}
