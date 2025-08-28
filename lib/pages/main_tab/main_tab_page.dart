import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/pages/home/home_page.dart';
import 'package:v2/pages/home/home_controller.dart';
import 'package:v2/pages/qr_code/scan_qr_code_page.dart';
import 'package:v2/pages/booking/booking_page.dart';
import 'package:v2/pages/booking/booking_controller.dart';
import 'package:v2/pages/profile/profile_page.dart';
import 'package:v2/services/localization_service.dart';

class MainTabController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    tabController.addListener(() {
      currentIndex.value = tabController.index;
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void changePage(int index) {
    currentIndex.value = index;
    tabController.animateTo(index);
  }
}

class MainTabPage extends GetView<MainTabController> {
  const MainTabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller.tabController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swipe between tabs
        children: [
          HomePage(),
          // const ScanQRCodePage(),
          const BookingPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(
                  icon: Icons.home_rounded,
                  label: TKeys.home.translate(),
                  isActive: controller.currentIndex.value == 0,
                  onTap: () => controller.changePage(0),
                ),
                // _BottomNavItem(
                //   icon: Icons.qr_code_rounded,
                //   label: TKeys.scan_qr.translate(),
                //   isActive: controller.currentIndex.value == 1,
                //   onTap: () => controller.changePage(1),
                // ),
                _BottomNavItem(
                  icon: Icons.history_rounded,
                  label: TKeys.history.translate(),
                  isActive: controller.currentIndex.value == 1,
                  onTap: () => controller.changePage(1),
                ),
                _BottomNavItem(
                  icon: Icons.person_rounded,
                  label: TKeys.profile.translate(),
                  isActive: controller.currentIndex.value == 2,
                  onTap: () => controller.changePage(2),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey.shade500,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainTabController>(() => MainTabController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<ScanQRCodeController>(() => ScanQRCodeController());
  }
}
