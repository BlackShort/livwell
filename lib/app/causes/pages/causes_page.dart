import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livwell/app/causes/controllers/causes_controller.dart';

class CausesPage extends StatefulWidget {
  const CausesPage({super.key});

  @override
  State<CausesPage> createState() => _CausesPageState();
}

class _CausesPageState extends State<CausesPage> {
  final CauseController _controller = Get.put(CauseController());
  
  // For handling refresh
  Future<void> _refreshCauses() async {
    await _controller.loadUserInterests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Causes'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(
        () => _controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshCauses,
                color: Colors.orange,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _controller.causes.length,
                  itemBuilder: (context, index) {
                    final cause = _controller.causes[index];
                    return GestureDetector(
                      onTap: () => _controller.toggleCause(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cause.isSelected
                              ? cause.selectedColor
                              : cause.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    cause.icon,
                                    size: 28,
                                    color: cause.isSelected
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cause.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: cause.isSelected
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (cause.isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}