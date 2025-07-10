import 'package:docveda_app/common/widgets/app_text/app_text.dart';
import 'package:docveda_app/common/widgets/app_text_field/app_text_field.dart';
import 'package:docveda_app/common/widgets/primary_button/primary_button.dart';
import 'package:docveda_app/features/authentication/screens/login/service/api_service.dart';
import 'package:docveda_app/features/authentication/screens/password_configuration/forgot_password.dart';
import 'package:docveda_app/navigation_menu.dart';
import 'package:docveda_app/utils/constants/colors.dart';
import 'package:docveda_app/utils/constants/sizes.dart';
import 'package:docveda_app/utils/constants/text_strings.dart';
import 'package:docveda_app/utils/encryption/pkec_keys.dart';
import 'package:docveda_app/utils/helpers/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:docveda_app/utils/device/device_utility.dart';

class DocvedaLoginForm extends StatefulWidget {
  const DocvedaLoginForm({super.key});

  @override
  _DocvedaLoginFormState createState() => _DocvedaLoginFormState();
}

class _DocvedaLoginFormState extends State<DocvedaLoginForm> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isPasswordVisible = false;
  bool isLoading = false;
  final ApiService apiService = ApiService();
  RxString deviceId = ''.obs;

  @override
  // void initState() {
  //   super.initState();
  //   _loadSavedCredentials();
  // }

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDeviceId();
      _loadSavedCredentials();
    });
  }

  void fetchDeviceId() async {
    deviceId.value = await DocvedaDeviceUtils.getDeviceId() ?? 'Unknown';
  }

  Future<Map<String, dynamic>?> checkDeviceIdOnScreen({
    required BuildContext context,
    required String mobileNo,
    required String deviceId,
  }) async {
    final ApiService apiService = ApiService();

    final getDbNameResponse =
        await apiService.getDbName(context, mobile_no: mobileNo);

    if (getDbNameResponse == null) {
      return null; // Handle error or return an empty map
    }

    final response = await apiService.getDeviceId(
      context,
      mobile_no: mobileNo,
      deviceId: deviceId,
      dbName: getDbNameResponse["DB"],
    );

    return response; // return the response to use it in loginUser
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await StorageHelper.getLoginInfo();
    setState(() {
      rememberMe = credentials['rememberMe'] ?? false;
      usernameController.text = credentials['username'] ?? "";
      passwordController.text = credentials['password'] ?? "";
    });
  }

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      // Separate validation for username and password with more descriptive error messages
      if (username.length > 10) {
        Get.snackbar(
          "Username Error",
          "Username must be less than 10 characters",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DocvedaColors.warning,
          colorText: DocvedaColors.white,
        );
        return;
      }

      if (password.length > 16) {
        Get.snackbar(
          "Password Error",
          "Password must be less than 16 characters",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DocvedaColors.warning,
          colorText: DocvedaColors.white,
        );
        return;
      }

      final pkceKeys = PKCEKeys.generatePKCEKeys();
      String codeVerifier = pkceKeys["code_verifier"] ?? "";
      String codeChallenger = pkceKeys["code_challenge"] ?? "";

      if (username.isEmpty || password.isEmpty) {
        Get.snackbar(
          "Error",
          DocvedaTexts.loginErrorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DocvedaColors.error,
          colorText: DocvedaColors.white,
        );
        return;
      }

      //  Check Device ID after storing tokens
      final deviceCheckRes = await checkDeviceIdOnScreen(
        context: context,
        mobileNo: username,
        deviceId: deviceId.value,
      );
      // print("Device Check Response: $deviceCheckRes");

      if (deviceCheckRes?['data'] == 'N') {
        Get.snackbar(
          "Error",
          "Login with your registered device only.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: DocvedaColors.error,
          colorText: DocvedaColors.white,
        );
        return;
      }

      final authCodeResponse = await apiService.issueAuthCode(
        username,
        password,
        codeChallenger,
      );

      if (!authCodeResponse.containsKey("authCode") &&
          !authCodeResponse.containsKey("code")) {
        throw Exception(DocvedaTexts.authorizationErrorMsg);
      }

      String authCode = authCodeResponse["code"] ?? "";
      if (authCode.isEmpty) {
        throw Exception(DocvedaTexts.authorizationErrorMsg);
      }

      final tokenResponse = await apiService.issueToken(authCode, codeVerifier);
      await StorageHelper.storeTokens(
        tokenResponse["accessToken"],
        tokenResponse["idToken"],
        tokenResponse["refreshToken"],
        username,
      );

      // Save credentials if Remember Me is checked
      await StorageHelper.saveLoginInfo(username, password, rememberMe);

      //  Navigate to home
      Get.offAll(() => NavigationMenu());
    } catch (e) {
      print("Login Error: $e");
      Get.snackbar(
        DocvedaTexts.loginFailedErrorMsg,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DocvedaColors.error,
        colorText: DocvedaColors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DocvedaSizes.spaceBtwSections,
        ),
        child: Column(
          children: [
            DocvedaTextFormField(
              controller: usernameController,
              label: DocvedaTexts.username,
              prefixIcon: Iconsax.direct_right,
            ),
            const SizedBox(height: DocvedaSizes.spaceBtwInputFields),
            DocvedaTextFormField(
              controller: passwordController,
              prefixIcon: Iconsax.password_check,
              label: DocvedaTexts.password,
              obscureText: !isPasswordVisible,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
                icon: Icon(
                  isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                ),
              ),
            ),
            const SizedBox(height: DocvedaSizes.spaceBtwInputFields / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),
                    const DocvedaText(
                      text: DocvedaTexts.rememberMe,
                      style: TextStyle(fontSize: DocvedaSizes.inputFieldRadius),
                    ),
                  ],
                ),
                // TextButton(
                //   onPressed: () => Get.to(() => const ForgotPassword()),
                //   child: const DocvedaText(
                //     text: DocvedaTexts.forgotPassword,
                //     style: TextStyle(fontSize: DocvedaSizes.inputFieldRadius),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: DocvedaSizes.spaceBtwSections),
            PrimaryButton(
              onPressed: loginUser,
              text: isLoading ? 'Logging In...' : DocvedaTexts.login,
              backgroundColor: DocvedaColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

//  class _BottomSheetContent extends StatelessWidget {
//   const _BottomSheetContent();

//   void _launchPlayStore() async {
//     const url =
//         'https://play.google.com/store/apps/details?id=com.example.yourapp'; // Replace with your actual app ID
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(DocvedaSizes.defaultSpace),
//       child: SizedBox(
//         height: MediaQuery.of(context).size.height * 0.35,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start, // Align content to top
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // No extra top padding or margin
//             Image.asset(
//               DocvedaImages.updateApp,
//               height: DocvedaSizes.imgHeightLs,
//             ),
//             const SizedBox(height: DocvedaSizes.spaceBtwItemsLg),
//             const Text(
//               DocvedaTexts.updateAppTitle,
//               style: TextStyle(
//                   fontSize: DocvedaSizes.fontSizeLg,
//                   fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: DocvedaSizes.spaceBtwItemsSm),
//             const Text(
//               DocvedaTexts.updateAppDesc,
//               style: TextStyle(fontSize: 14, color: DocvedaColors.grey),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: DocvedaSizes.defaultSpace),
//             PrimaryButton(
//                 onPressed: _launchPlayStore,
//                 text: DocvedaTexts.goToPlaystore,
//                 backgroundColor: DocvedaColors.primaryColor)
//           ],
//         ),
//       ),
//     );
//   }
// }
}
