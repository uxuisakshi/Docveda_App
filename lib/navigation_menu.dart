import 'package:docveda_app/features/clinic/screens/home/analytics/analytics.dart';
import 'package:docveda_app/features/clinic/screens/home/notifications/notifications.dart';
import 'package:docveda_app/features/clinic/screens/profileScreen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:docveda_app/features/clinic/screens/home/home.dart';
import 'package:docveda_app/utils/constants/colors.dart';
import 'package:docveda_app/utils/helpers/helper_functions.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = DocvedaHelperFunctions.isDarkMode(context);
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // List pageNames = ['Analytics', 'Dashboard', 'Notifications'];
    List pageNames = ['Dashboard', 'ProfileScreen'];

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: darkMode ? DocvedaColors.black : DocvedaColors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), // Rounded corners
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              blurRadius: 10, // Blur radius
              spreadRadius: 2, // Spread radius
              offset: const Offset(0, -3), // Negative offset for top shadow
            ),
          ],
        ),
        child: Obx(
          () => NavigationBar(
            height: 60,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) async {
              controller.selectedIndex.value = index;
              // Log Firebase Analytics Event
              await analytics
                  .logEvent(
                    name: "navigation_selected",
                    parameters: {
                      "index": index,
                      "screen_name": pageNames[index],
                    },
                  )
                  .then((value) {})
                  .catchError((error) {
                    print("Failed to log event: $error");
                  });
            },
            backgroundColor: Colors
                .transparent, // Make NavigationBar transparent to use Container's color
            indicatorColor: DocvedaColors
                .primaryColor, // Background color for selected item
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                16,
              ), // Rounded background for selected item
            ),

            destinations: [
              // NavigationDestination(
              //   icon: Icon(
              //     Iconsax.chart_1,
              //     color: DocvedaColors.primaryColor,
              //   ), // Default icon color
              //   selectedIcon: Icon(
              //     Iconsax.chart_1,
              //     color: DocvedaColors.white,
              //   ), // Selected icon color
              //   label: 'Analytics',
              // ),
              NavigationDestination(
                icon:
                    Icon(Iconsax.element_3, color: DocvedaColors.primaryColor),
                selectedIcon:
                    Icon(Iconsax.element_3, color: DocvedaColors.white),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.user, color: DocvedaColors.primaryColor),
                selectedIcon: Icon(Iconsax.user, color: DocvedaColors.white),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 1.obs;

  final screens = [
    // Dischargescreen(),
    // AnalyticsScreen(),
    HomeScreen(), // Pass accessToken here
    ProfileScreen(), // Pass accessToken
    // NotificationsScreen(),
  ];
}
