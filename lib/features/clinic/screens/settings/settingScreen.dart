import 'package:docveda_app/common/widgets/app_text/app_text.dart';
import 'package:docveda_app/features/authentication/screens/login/login.dart';
import 'package:docveda_app/features/clinic/screens/home/analytics/analytics.dart';
import 'package:docveda_app/features/clinic/screens/home/notifications/notifications.dart';
import 'package:docveda_app/features/clinic/screens/profileScreen/profile_screen.dart';
import 'package:docveda_app/utils/constants/colors.dart';
import 'package:docveda_app/utils/constants/sizes.dart';
import 'package:docveda_app/utils/constants/text_strings.dart';
import 'package:docveda_app/utils/helpers/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String version = "";

  @override
  void didChangeDependencies() {
    getAppVersion();
    super.didChangeDependencies();
  }

  getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const DocvedaText(
          text: DocvedaTexts.settings,
          style: TextStyle(color: DocvedaColors.white),
        ),
        backgroundColor: DocvedaColors.primaryColor,
        foregroundColor: DocvedaColors.white,
        iconTheme: const IconThemeData(color: DocvedaColors.white),
      ),
      body: Column(
        children: [
          // Main scrollable content
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: DocvedaSizes.spaceBtwItems),

                // Profile
                ListTile(
                  leading: Icon(Iconsax.user, color: DocvedaColors.primary),
                  title: const DocvedaText(text: DocvedaTexts.profile),
                  subtitle: const DocvedaText(text: DocvedaTexts.profileDesc),
                  // trailing: const Icon(Icons.arrow_forward_ios,
                  //     size: DocvedaSizes.fontSizeMd),
                  onTap: () => Get.to(const ProfileScreen()),
                ),
                const Divider(),

                // Notifications
                // ListTile(
                //   leading:
                //       Icon(Iconsax.notification, color: DocvedaColors.primary),
                //   title: const DocvedaText(text: DocvedaTexts.notifications),
                //   subtitle:
                //       const DocvedaText(text: DocvedaTexts.notificationsDesc),
                //   // trailing: const Icon(Icons.arrow_forward_ios,
                //   //     size: DocvedaSizes.fontSizeMd),
                //   onTap: () => Get.to(const NotificationsScreen()),
                // ),
                // const Divider(),

                // Analytics
                // ListTile(
                //   leading: Icon(Iconsax.chart, color: DocvedaColors.primary),
                //   title: const Text(DocvedaTexts.analytics),
                //   subtitle: const Text(DocvedaTexts.analyticsDesc),
                //   // trailing: const Icon(Icons.arrow_forward_ios,
                //   //     size: DocvedaSizes.fontSizeMd),
                //   onTap: () => Get.to(const AnalyticsScreen()),
                // ),
                // const Divider(),

                // Change Password
                // ListTile(
                //   leading: Icon(Iconsax.lock, color: DocvedaColors.primary),
                //   title: const Text(DocvedaTexts.changePassword),
                //   subtitle: const Text(DocvedaTexts.changePasswordDesc),
                //   // trailing: const Icon(Icons.arrow_forward_ios,
                //   //     size: DocvedaSizes.fontSizeMd),
                //   onTap: () => Get.to(() => const NewPasswordScreen()),
                // ),
                // const Divider(),

                // Logout
                ListTile(
                  leading: const Icon(
                    Iconsax.logout_1,
                    color: DocvedaColors.primaryColor,
                  ),
                  title: const Text(
                    DocvedaTexts.logout,
                    style: TextStyle(
                      color: DocvedaColors.primaryColor,
                      fontSize: DocvedaSizes.fontSizeMd,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Get.dialog(
                      Center(
                        child: Material(
                          color: DocvedaColors.transparent,
                          child: Container(
                            width: Get.width * 0.85,
                            padding: const EdgeInsets.symmetric(
                                horizontal: DocvedaSizes.spaceBtwItemsLg,
                                vertical:
                                    DocvedaSizes.spaceBtwSectionsVertical),
                            decoration: BoxDecoration(
                              color: DocvedaColors.white,
                              borderRadius: BorderRadius.circular(
                                  DocvedaSizes.borderaRadiusXlg),
                              boxShadow: [
                                BoxShadow(
                                  color: DocvedaColors.black,
                                  blurRadius: DocvedaSizes.blurRadius,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  DocvedaTexts.logoutTitle,
                                  style: TextStyle(
                                    fontSize: DocvedaSizes.fontSizeXlg,
                                    fontWeight: FontWeight.w600,
                                    color: DocvedaColors.black,
                                  ),
                                ),
                                const SizedBox(
                                    height: DocvedaSizes.spaceBtwItemsS),
                                const Text(
                                  DocvedaTexts.logoutDesc,
                                  style: TextStyle(
                                    fontSize: DocvedaSizes.fontSizeSm,
                                    color: DocvedaColors.black,
                                  ),
                                ),
                                const SizedBox(
                                    height: DocvedaSizes.spaceBtwItemsXlg),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => Get.back(),
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              DocvedaColors.softGrey,
                                          foregroundColor: DocvedaColors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                DocvedaSizes.borderRadiusXmd),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  DocvedaSizes.paddingVertical),
                                          side: BorderSide
                                              .none, // Removes the blue border
                                        ),
                                        child: const Text(
                                          DocvedaTexts.cancel,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: DocvedaSizes.spaceBtwItemsS),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          StorageHelper.clearTokens();
                                          Get.offAll(() => const LoginScreen());
                                        },
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor:
                                              DocvedaColors.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                DocvedaSizes.borderRadiusXmd),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical:
                                                  DocvedaSizes.paddingVertical),
                                          side: BorderSide
                                              .none, // Removes the blue border
                                        ),
                                        child: const Text(
                                          DocvedaTexts.logout,
                                          style: TextStyle(
                                            color: DocvedaColors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      barrierDismissible: true,
                    );
                  },
                )
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 16.0), // Optional extra spacing
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: DocvedaText(
                      text: "${DocvedaTexts.app_version} $version",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: DocvedaColors.darkGrey,
                        fontSize: DocvedaSizes.fontSizeSm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
