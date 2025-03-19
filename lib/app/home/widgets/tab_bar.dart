import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final bool showMyOrgs;
  final Function(bool) onTabSelected;

  const CustomTabBar({
    super.key,
    required this.showMyOrgs,
    required this.onTabSelected,
  });

  Widget _buildTab(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => onTabSelected(text == 'My Orgs'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: (text == 'My Orgs') == isSelected ? const Color(0xFFFFA500) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: (text == 'My Orgs') == isSelected ? const Color(0xFFFFA500) : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
      ),
      child: Row(
        children: [
          _buildTab('My Orgs', showMyOrgs),
          _buildTab('Near Me', !showMyOrgs),
        ],
      ),
    );
  }
}
