import 'package:docveda_app/common/widgets/app_text/app_text.dart';
import 'package:docveda_app/common/widgets/appbar/appbar.dart';
import 'package:docveda_app/common/widgets/card/patient_card.dart';
import 'package:docveda_app/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:docveda_app/common/widgets/date_switcher_bar/date_switcher_bar.dart';
import 'package:docveda_app/common/widgets/toggle/toggle.dart';
import 'package:docveda_app/common/widgets/primary_button/primary_button.dart';
import 'package:docveda_app/common/widgets/toggle/toggleController.dart';
import 'package:docveda_app/features/authentication/screens/login/service/api_service.dart';
import 'package:docveda_app/features/clinic/screens/viewReportScreen/viewReportScreen.dart';
import 'package:docveda_app/utils/constants/colors.dart';
import 'package:docveda_app/utils/constants/sizes.dart';
import 'package:docveda_app/utils/constants/text_strings.dart';
import 'package:docveda_app/utils/helpers/date_formater.dart';
import 'package:docveda_app/utils/helpers/format_amount.dart';
import 'package:docveda_app/utils/helpers/format_name.dart';
import 'package:docveda_app/utils/pdf/pdf1.dart';
import 'package:docveda_app/utils/theme/custom_themes/text_style_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:intl/intl.dart';

class DiscountsScreen extends StatefulWidget {
  final bool isSelectedMonthly;
  final DateTime prevSelectedDate;
  const DiscountsScreen(
      {super.key,
      required this.isSelectedMonthly,
      required this.prevSelectedDate});

  @override
  State<DiscountsScreen> createState() => _DiscountsScreenState();
}

class _DiscountsScreenState extends State<DiscountsScreen> {
  final ApiService apiService = ApiService();
  int selectedPatientIndex = 0;
  late Future<List<Map<String, dynamic>>> patientData;
  late List<Map<String, dynamic>> patients = [];

  DateTime selectedDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  bool isMonthly = false;
  Set<int> selectedPatientIndices = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.prevSelectedDate;
    isMonthly = widget.isSelectedMonthly;
    loadDiscountData();
  }

  void loadDiscountData() {
    final toggleController = Get.find<ToggleController>();

    setState(() {
      selectedPatientIndices.clear();

      final isMonthlyToggle = toggleController.isMonthly.value;
      patientData = fetchDiscountData(
        isMonthly: isMonthlyToggle,
        pDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
        pType: isMonthlyToggle ? 'Monthly' : 'Daily',
      );
    });
  }

  Future<List<Map<String, dynamic>>> fetchDiscountData({
    required bool isMonthly,
    required String pType,
    required String pDate,
  }) async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'accessToken');

    if (accessToken != null) {
      try {
        final response = await apiService.getDiscountData(
          accessToken,
          context,
          isMonthly: isMonthly,
          pDate: pDate,
          pType: pType[0].toUpperCase() + pType.substring(1).toLowerCase(),
        );

        if (response != null && response['data'] != null) {
          return List<Map<String, dynamic>>.from(response['data']);
        } else {
          print('Invalid data format or missing "data" field.');
          return [];
        }
      } catch (e) {
        print('Error fetching discount data: $e');
        return [];
      }
    } else {
      print('Access token is null. Please login.');
      return [];
    }
  }

  void _goToPrevious() {
    final toggleController = Get.find<ToggleController>();
    setState(() {
      selectedDate = toggleController.isMonthly.value
          ? DateTime(
              selectedDate.year, selectedDate.month - 1, selectedDate.day)
          : selectedDate.subtract(const Duration(days: 1));
    });
    loadDiscountData();
  }

  void _goToNext() {
    final toggleController = Get.find<ToggleController>();
    setState(() {
      selectedDate = toggleController.isMonthly.value
          ? DateTime(
              selectedDate.year, selectedDate.month + 1, selectedDate.day)
          : selectedDate.add(const Duration(days: 1));
    });
    loadDiscountData();
  }

  // void _handleToggle(bool value) {
  //   setState(() {
  //     isMonthly = value;
  //   });
  //   loadDiscountData(); //  Re-fetch on toggle change
  // }

  void handlePatientSelection(int index) {
    setState(() {
      if (selectedPatientIndices.contains(index)) {
        selectedPatientIndices.remove(index);
      } else {
        selectedPatientIndices.add(index);
      }
    });
  }

  void _updateDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    // You can navigate or pass the new date to another screen here
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final toggleController = Get.find<ToggleController>();

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              DocvedaPrimaryHeaderContainer(
                child: Column(
                  children: [
                    DocvedaAppBar(
                      title: Center(
                        child: Text(
                          "Discounts",
                          style: TextStyleFont.subheading
                              .copyWith(color: DocvedaColors.white),
                        ),
                      ),
                      showBackArrow: true,
                    ),
                    DocvedaToggle(
                      onToggle: (value) {
                        toggleController.isMonthly.value = value;
                        loadDiscountData(); // or any other action you need
                      },
                    ),
                    DateSwitcherBar(
                      selectedDate: _selectedDate,
                      onPrevious: _goToPrevious,
                      onNext: _goToNext,
                      onDateChanged: _updateDate,
                      isMonthly:
                          toggleController.isMonthly.value, // Use global state
                      textColor: DocvedaColors.white,
                      fontSize: DocvedaSizes.fontSizeSm,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: patientData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No discount data available.'));
                    }

                    patients = snapshot.data!;

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: selectedPatientIndices.length ==
                                        patients.length,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          selectedPatientIndices = Set.from(
                                              List.generate(
                                                  patients.length, (i) => i));
                                        } else {
                                          selectedPatientIndices.clear();
                                        }
                                      });
                                    },
                                  ),
                                  DocvedaText(
                                    text:
                                        "${patients.length} settlements found",
                                    style: TextStyleFont.subheading,
                                  ),
                                ],
                              ),
                              const SizedBox(height: DocvedaSizes.xs),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: DocvedaSizes.spaceBtwItems),
                                child: DocvedaText(
                                  text: DocvedaTexts.depositePatientDesc,
                                  style: TextStyleFont.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DocvedaSizes.spaceBtwItemsSsm),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: DocvedaSizes.spaceBtwItems),
                            itemCount: patients.length,
                            itemBuilder: (context, index) {
                              final patient = patients[index];
                              final isSelected =
                                  selectedPatientIndices.contains(index);
                              return PatientCard(
                                index: index,
                                selectedPatientIndex: isSelected ? index : -1,
                                onPatientSelected: handlePatientSelection,
                                topRow: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          size: 16,
                                          color: isSelected
                                              ? DocvedaColors.primaryColor
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 8),
                                        DocvedaText(
                                          text: formatPatientName(
                                              "${patient["Patient Name"] ?? ""}"
                                                  .trim()),
                                          style: TextStyleFont.body.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    DocvedaText(
                                      text:
                                          "${patient["Age"] ?? "--"} • ${patient["Gender"] ?? "--"}",
                                      style: TextStyleFont.caption.copyWith(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                middleRow: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 32, right: 8, top: 8, bottom: 8),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                DocvedaText(
                                                  text: "Admission Date",
                                                  style: TextStyleFont.caption
                                                      .copyWith(
                                                          color: Colors.grey),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                ),
                                                const SizedBox(height: 4),
                                                DocvedaText(
                                                  text: DateFormatter
                                                      .formatDate(patient[
                                                          "Admission Date"]),
                                                  style: TextStyleFont.caption,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  12), // Add space between the two columns
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                DocvedaText(
                                                  text: "Date Of Discount",
                                                  style: TextStyleFont.caption
                                                      .copyWith(
                                                          color: Colors.grey),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                ),
                                                const SizedBox(height: 4),
                                                DocvedaText(
                                                  text: patient[
                                                      "Date Of Discount"],
                                                  style: TextStyleFont.caption,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                          height: 24,
                                          thickness: 1,
                                          color: Colors.grey),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          DocvedaText(
                                            text: "Discount Amount",
                                            style: TextStyleFont.body.copyWith(
                                              color: Colors.grey.shade700,
                                              fontSize: 14,
                                            ),
                                          ),
                                          DocvedaText(
                                            text: FormatAmount.formatAmount(
                                                patient["Discount Amount"] ??
                                                    "0"),
                                            style: TextStyleFont.body.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: DocvedaColors.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                bottomRow: Container(),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (selectedPatientIndices.isNotEmpty)
                SafeArea(
                  top: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: DocvedaSizes.spaceBtwItemsS,
                      ),
                      decoration: BoxDecoration(
                        color: DocvedaColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: DocvedaColors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: PrimaryButton(
                        text: selectedPatientIndices.length == 1
                            ? "View Report"
                            : "Download Reports",
                        backgroundColor: DocvedaColors.primaryColor,
                        onPressed: () {
                          if (selectedPatientIndices.length == 1) {
                            final idx = selectedPatientIndices.first;
                            final patient = patients[idx];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewReportScreen(
                                  patientName:
                                      patient['Patient Name'] ?? 'Unknown',
                                  age: patient['Age'] ?? 'unknown',
                                  gender: patient['Gender'] ?? '',
                                  uhidno: patient['UHID No'],
                                  screenName: "Discount",
                                  admissionDate:
                                      patient['Admission Date'] ?? '',
                                  discountAmount: FormatAmount.formatAmount(
                                      patient['Discount Amount']?.toString() ??
                                          '0',
                                      showSymbol: false),
                                  dateOfDiscount:
                                      patient['Date Of Discount'] ?? '',
                                ),
                              ),
                            );
                          } else {
                            final selectedPatients =
                                selectedPatientIndices.map((i) {
                              final patient = patients[i];
                              // Add screen name if you know the context (e.g., admission/discharge/etc.)
                              return {
                                ...patient,
                                'Screen Name':
                                    'discount', // <-- update this dynamically if needed
                              };
                            }).toList();

                            generateAndShowPdf(selectedPatients);
                          }
                        },
                      ),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }
}
