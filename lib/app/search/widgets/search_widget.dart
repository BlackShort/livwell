import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:livwell/app/search/controllers/search_controller.dart';
import 'package:livwell/config/theme/app_pallete.dart';
import 'package:shimmer/shimmer.dart';

class SearchWidget extends StatelessWidget {
  final Function(DocumentSnapshot)? onOrganizationTap;
  final Function(DocumentSnapshot)? onOpportunityTap;
  
  SearchWidget({
    super.key,
    this.onOrganizationTap,
    this.onOpportunityTap,
  });
  
  final SearchControl controller = Get.put(SearchControl());
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.isSearchActive
        ? _buildSearchScreen()
        : _buildSearchIcon());
  }
  
  Widget _buildSearchIcon() {
    return IconButton(
      onPressed: controller.activateSearch,
      icon: SvgPicture.asset(
        'assets/icons/search_out.svg',
        width: 19,
        height: 19,
        colorFilter: const ColorFilter.mode(
          AppPallete.blackSecondary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
  
  Widget _buildSearchScreen() {
    return WillPopScope(
      onWillPop: () async {
        controller.deactivateSearch();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppPallete.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppPallete.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppPallete.black),
            onPressed: controller.deactivateSearch,
          ),
          title: _buildSearchField(),
          titleSpacing: 0,
          actions: [
            if (controller.searchQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: AppPallete.black),
                onPressed: controller.clearSearchQuery,
              ),
          ],
        ),
        body: _buildSearchBody(),
      ),
    );
  }
  
  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search organizations & opportunities',
        hintStyle: TextStyle(color: Colors.grey[400], fontFamily: 'Poppins'),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
      style: const TextStyle(
        color: AppPallete.black,
        fontFamily: 'Poppins',
      ),
      onChanged: controller.updateSearchQuery,
    );
  }
  
  Widget _buildSearchBody() {
    if (controller.searchQuery.isEmpty) {
      return _buildInitialSearchState();
    }
    
    if (controller.isLoading) {
      return _buildLoadingState();
    }
    
    if (controller.searchResults.isEmpty) {
      return _buildNoResultsState();
    }
    
    return _buildSearchResults();
  }
  
  Widget _buildInitialSearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Search for organizations or opportunities',
            style: TextStyle(color: Colors.grey[500], fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Searching...',
              style: TextStyle(
                color: AppPallete.grey,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ...List.generate(3, (index) => _buildShimmerItem()),
        ],
      ),
    );
  }
  
  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No results found for "${controller.searchQuery}"',
            style: const TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResults.length,
      itemBuilder: (context, index) {
        DocumentSnapshot doc = controller.searchResults[index];
        bool isOrg = controller.isOrganization(doc);
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        return isOrg
            ? _buildOrganizationItem(data, doc)
            : _buildOpportunityItem(data, doc);
      },
    );
  }
  
  Widget _buildOrganizationItem(Map<String, dynamic> org, DocumentSnapshot doc) {
    String iconName = org['icon'] ?? 'eco';
    IconData iconData = _getIconData(iconName);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (onOrganizationTap != null) {
            onOrganizationTap!(doc);
            controller.deactivateSearch();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppPallete.lightprimary,
                radius: 24,
                child: Icon(
                  iconData,
                  color: AppPallete.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            org['name'] ?? 'Unknown Organization',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppPallete.lightprimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Organization',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppPallete.dullprimary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      org['description'] ?? 'No description available',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppPallete.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildOpportunityItem(Map<String, dynamic> opportunity, DocumentSnapshot doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          if (onOpportunityTap != null) {
            onOpportunityTap!(doc);
            controller.deactivateSearch();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      opportunity['imageUrl'] ?? 'https://via.placeholder.com/48',
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: opportunity['imageUrl'] == null
                    ? const Center(child: Icon(Icons.event, color: AppPallete.white))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            opportunity['title'] ?? 'Unknown Opportunity',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Opportunity',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${opportunity['organization'] ?? 'Unknown'} • ${opportunity['location'] ?? 'No location'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppPallete.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'eco':
        return Icons.eco;
      case 'pets':
        return Icons.pets;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.eco;
    }
  }
}