import 'dart:convert';

import 'package:docveda_app/common/widgets/appbar/appbar.dart';
import 'package:docveda_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:docveda_app/common/widgets/date_switcher_bar/date_switcher_bar.dart';
import 'package:docveda_app/common/widgets/section_heading/section_heading.dart';
import 'package:docveda_app/common/widgets/toggle/toggle.dart';
import 'package:docveda_app/common/widgets/toggle/toggleController.dart';
import 'package:docveda_app/features/authentication/screens/login/login.dart';
import 'package:docveda_app/features/authentication/screens/login/service/api_service.dart';
import 'package:docveda_app/features/clinic/screens/home/widgets/bedTransferCard.dart';
import 'package:docveda_app/features/clinic/screens/home/widgets/expensesSection.dart';
import 'package:docveda_app/features/clinic/screens/home/widgets/patientInformationSection.dart';
import 'package:docveda_app/features/clinic/screens/home/widgets/revenueSection.dart';
import 'package:docveda_app/features/clinic/screens/settings/settingScreen.dart';
import 'package:docveda_app/utils/base64/base64_utility.dart';
import 'package:docveda_app/utils/constants/colors.dart';
import 'package:docveda_app/utils/constants/image_strings.dart';
import 'package:docveda_app/utils/constants/sizes.dart';
import 'package:docveda_app/utils/constants/text_strings.dart';
import 'package:docveda_app/utils/helpers/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final List<String> dashboardItems = [
  DocvedaTexts.dashboardItems1, // "Bed Transfers"
  DocvedaTexts.dashboardItems2, // "Bed Transfers"
  DocvedaTexts.dashboardItems3, // "Bed Transfers"
  DocvedaTexts.dashboardItems4, // "OPD Bills"
  DocvedaTexts.dashboardItems5, // "OPD Payments"z
  DocvedaTexts.dashboardItems6, // "Deposits"
  DocvedaTexts.dashboardItems7, // "IPD Settlements"
  DocvedaTexts.dashboardItems8, // "Discounts"
  DocvedaTexts.dashboardItems9, // "Refunds"
  DocvedaTexts.dashboardItems10, // "opdVisit"
];

Map<String, dynamic>? profileData;

class _HomeScreenState extends State<HomeScreen> {
  // NotificationServices notificationServices = NotificationServices();
  final ApiService apiService = ApiService();
  final ToggleController toggleController = Get.put(ToggleController());

  //  Declare the variable to store API response

  late Future<List<Map<String, dynamic>>> dashboardDataFuture;
  DateTime _selectedDate = DateTime.now();
  bool isMonthly = false; // default to daily

  void _updateDate(DateTime newDate) {
    setState(() {
      if (!mounted) return;

      // print("Home updateDate triggered");
      _selectedDate = newDate;
    });
    // You can navigate or pass the new date to another screen here
  }

  @override
  void initState() {
    super.initState();

    fetchProfileData();
    Future.microtask(() {
      toggleController.isMonthly.value = false;
    });
    // Listen for toggle changes
    toggleController.isMonthly.listen((newValue) {
      if (!mounted) return; //  Prevent listener from calling after dispose
      _handleToggle(newValue); // re-fetch data
    });

    // Load dashboard data after profile is fetched
    dashboardDataFuture = fetchDashboardData(
      isMonthly: isMonthly,
      pDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      pType: isMonthly ? 'MONTHLY' : 'DAILY',
    );
    setState(() {}); // Rebuild UI with new future

    // notificationServices.requestNotificationPermission();
    // notificationServices.firebaseInit(context);
    // notificationServices.setupInteractMessage(context);
    // notificationServices.isTokenRefresh();
    // notificationServices.getDeviceToken().then((value) {
    //   print("Device Token: ");
    //   print(value);
    // });
  }

  //get item => null;

  Future<void> fetchProfileData() async {
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final username = await storage.read(key: 'username');
    final String? mobileNo = username; // Replace with dynamic value if needed

    if (accessToken != null) {
      final data = await apiService.getProfileData(
        accessToken,
        context,
        mobile_no: mobileNo ?? "",
      );
      setState(() {
        profileData = data?['data'][0];
        // print("Profile data fetched: $profileData");
      });
      // if (mounted) {
      //   setState(() {
      //     profileData = data;
      //   });
      // }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => const LoginScreen());
      });
    }
    print("Profile data: $profileData");
  }

  Future<List<Map<String, dynamic>>> fetchDashboardData({
    required bool isMonthly,
    required String pType,
    required String pDate,
  }) async {
    String? accessToken = await StorageHelper.getAccessToken();

    if (accessToken != null) {
      try {
        final response = await apiService.getCards(accessToken, context,
            isMonthly: isMonthly, pDate: pDate, pType: pType);
        // print("API Response from home: ${response}");
        if (response != null && response['statusCode'] == 401) {
          StorageHelper.clearTokens();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAll(() => const LoginScreen());
          });
          return [];
        }
        if (response != null && response['data'] != null) {
          return List<Map<String, dynamic>>.from(response['data']);
        } else {
          return [];
        }
      } catch (e) {
        print('Error fetching dashboard data: $e');
        return [];
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => const LoginScreen());
      });
      return [];
    }
  }

  //  Function to fetch data and store it in `dashboardData`
  void loadDashboardData() async {}

  DateTime selectedDate = DateTime.now();
  //bool isMonthly = false;

  void _goToPrevious() {
    final isMonthly = toggleController.isMonthly.value;
    setState(() {
      selectedDate = isMonthly
          ? DateTime(
              selectedDate.year, selectedDate.month - 1, selectedDate.day)
          : selectedDate.subtract(const Duration(days: 1));

      dashboardDataFuture = fetchDashboardData(
        isMonthly: isMonthly,
        pDate: DateFormat('yyyy-MM-dd').format(selectedDate),
        pType: isMonthly ? 'MONTHLY' : 'DAILY',
      );
    });
  }

  void _goToNext() {
    setState(() {
      selectedDate = isMonthly
          ? DateTime(
              selectedDate.year, selectedDate.month + 1, selectedDate.day)
          : selectedDate.add(const Duration(days: 1));

      dashboardDataFuture = fetchDashboardData(
        isMonthly: isMonthly,
        pDate: DateFormat('yyyy-MM-dd').format(selectedDate),
        pType: isMonthly ? 'MONTHLY' : 'DAILY',
      );
    });
  }

  void _handleToggle(bool newValue) {
    if (!mounted) return;

    setState(() {
      isMonthly = newValue;

      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      final type = isMonthly ? 'MONTHLY' : 'DAILY';

      dashboardDataFuture = fetchDashboardData(
        isMonthly: isMonthly,
        pType: type,
        pDate: formattedDate,
      );
    });
  }

  List<Map<String, dynamic>> extractOptionsFromData({
    required Map<String, dynamic> data,
    required List<String> keys,
  }) {
    List<Map<String, dynamic>> options = [];

    for (String key in keys) {
      if (data.containsKey(key)) {
        options.add({
          'label':
              key.replaceAll('_', ' '), // Optional: make key human-readable
          'value': data[key],
          'key': key,
        });
      }
    }

    return options;
  }

  ImageProvider getLogoImage(Map<String, dynamic>? profileData) {
    try {
      final base64Logo = profileData?['Base64_Logo_Path'];

      if (base64Logo != null && base64Logo.isNotEmpty) {
        final cleanString = cleanBase64(base64Logo);
        final decodedBytes = base64Decode(cleanString);

        // Validate image bytes length before returning MemoryImage
        if (decodedBytes.isNotEmpty) {
          return MemoryImage(decodedBytes);
        }
      }
    } catch (e) {
      print('Error decoding logo: $e');
    }

    // Fallback to default logo if error or invalid base64
    return const AssetImage(DocvedaImages.clinicLogo);
  }

  @override
  Widget build(BuildContext context) {
    // Prepare the logo image inside build method
    ImageProvider logoImage = getLogoImage(profileData);

    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dashboardDataFuture,
        builder: (context, snapshot) {
          bool isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (isLoading && !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No dashboard data found.'));
          }

          final dashboardData = snapshot.data!;

          List<Map<String, dynamic>> patientDataArray = extractOptionsFromData(
            data: dashboardData[0],
            keys: ["Admission", "Discharge", "OPD_Visits"],
          );

          List<Map<String, dynamic>> revenueDataArray = extractOptionsFromData(
            data: dashboardData[0],
            keys: ["Deposit", "OPD_Payment", "IPD_Settlement"],
          );

          List<Map<String, dynamic>> expenseDataArray = extractOptionsFromData(
            data: dashboardData[0],
            keys: ["Total_Discount", "Total_Refund"],
          );

          return SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              DocvedaPrimaryHeaderContainer(
                child: Column(
                  children: [
                    DocvedaAppBar(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: DocvedaColors.white,
                                backgroundImage: logoImage,
                              ),
                              const SizedBox(
                                width: DocvedaSizes.spaceBtwItems,
                              ),
                              Column(
                                children: [
                                  Text(
                                    profileData?['f_DV_Clinic_Name'] ?? " ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .apply(color: DocvedaColors.white),
                                  ),
                                  Row(
                                    children: [
                                      // Image.asset(
                                      //   DocvedaImages.protectLogo,
                                      //   width: DocvedaSizes.imageWidthS,
                                      //   height: DocvedaSizes.imageHeightS,
                                      //   fit: BoxFit.contain,
                                      // ),
                                      // const SizedBox(
                                      //   width: DocvedaSizes.spaceBtwItemsSm,
                                      // ),
                                      Text(
                                        DocvedaTexts.logo,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium!.apply(
                                              color: DocvedaColors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: DocvedaSizes.spaceBtwItemsSm,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Iconsax.setting_25,
                                color: DocvedaColors.white,
                              ),
                              onPressed: () {
                                Get.to(() => const SettingScreen());
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: DocvedaSizes.spaceBtwItemsS,
                    ),
                    const SizedBox(height: DocvedaSizes.spaceBtwItemsS),
                    const DocvedaToggle(),
                    DateSwitcherBar(
                      selectedDate: _selectedDate,
                      onPrevious: _goToPrevious,
                      onNext: _goToNext,
                      onDateChanged: _updateDate,
                      isMonthly: isMonthly, // Use global state
                      textColor: DocvedaColors.white,
                      fontSize: DocvedaSizes.fontSizeSm,
                    ),
                    const SizedBox(height: DocvedaSizes.spaceBtwItemsS),
                  ],
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 200),
                const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: DocvedaColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 100),
              ] else if (snapshot.hasData) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: DocvedaSizes.defaultSpace),
                  child: Column(
                    children: [
                      // PATIENT INFORMATION
                      DocvedaSectionHeading(
                        title: 'PATIENT INFORMATION',
                        showActionButton: false,
                        textStyle: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: DocvedaSizes.fontSizeMd,
                          fontWeight: FontWeight.bold,
                          color: DocvedaColors.textTitle,
                        ),
                      ),

                      const SizedBox(height: DocvedaSizes.spaceBtwItemsLg),

                      PatientInformationSection(
                        patientDataArray: patientDataArray,
                        isSelectedMonthly: toggleController.isMonthly.value,
                        prevSelectedDate: _selectedDate,
                      ),

                      const SizedBox(height: DocvedaSizes.spaceBtwItemsS),

                      BedTransferCard(
                          bedTransferCount:
                              dashboardData[0]['Bed_Transfer'] ?? 0,
                          isSelectedMonthly: toggleController.isMonthly.value,
                          prevSelectedDate: _selectedDate),

                      const SizedBox(height: DocvedaSizes.spaceBtwItems),
                      DocvedaSectionHeading(
                        title: 'REVENUE',
                        showActionButton: false,
                        textStyle: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: DocvedaSizes.fontSizeMd,
                          fontWeight: FontWeight.bold,
                          color: DocvedaColors.textTitle,
                        ),
                        image: DocvedaImages.revenueImg,
                      ),

                      const SizedBox(height: DocvedaSizes.spaceBtwItems),

                      RevenueSection(
                          revenueDataArray: revenueDataArray,
                          isSelectedMonthly: toggleController.isMonthly.value,
                          prevSelectedDate: _selectedDate),

                      const SizedBox(height: DocvedaSizes.spaceBtwItems),

                      // EXPENSES
                      DocvedaSectionHeading(
                        title: 'EXPENSES',
                        showActionButton: false,
                        textStyle: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: DocvedaSizes.fontSizeMd,
                          fontWeight: FontWeight.bold,
                          color: DocvedaColors.textTitle,
                        ),
                        image: DocvedaImages.expensesImg,
                      ),

                      const SizedBox(height: DocvedaSizes.spaceBtwItems),
                      ExpensesSection(
                          expenseDataArray: expenseDataArray,
                          isSelectedMonthly: toggleController.isMonthly.value,
                          prevSelectedDate: _selectedDate),

                      const SizedBox(height: DocvedaSizes.spaceBtwSections),
                    ],
                  ),
                ),
              ],
            ]),
          );
        },
      ),
    );
  }
}
