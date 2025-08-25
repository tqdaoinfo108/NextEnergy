import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/button.dart';
import 'package:v2/pages/customs/circular_progress_indicator.dart';
import 'package:v2/services/localization_service.dart';

import 'package:v2/utils/string_utils.dart';

import '../../model/user_model.dart';
import '../customs/dialog_custom.dart';
import '../customs/textfield_custom.dart';
import 'login_update_controller.dart';

class LoginUpdatePage extends GetView<LoginUpdateController> {
  const LoginUpdatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.userModel = Get.arguments as UserModel;
    final formKey = GlobalKey<FormState>(debugLabel: '_childWidgetKey7');
    return Scaffold(
        appBar: AppBarCustom(
          title: Text(
            TKeys.update_profile.translate(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: Obx(
          () => controller.isLoading.value
              ? const CircularProgressIndicatorCustom()
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFieldNormalCustom(
                              TKeys.full_name.translate(),
                              isRequired: true,
                              controller: controller.fullNameController,
                              validator: (s) {
                                if (s == null || s.isEmpty) {
                                  return TKeys.dont_blank.translate();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFieldNormalCustom(
                              TKeys.email.translate(),
                              isRequired: false,
                              controller: controller.emailController,
                              validator: (s) {
                                if (s != null && s.isNotEmpty) {
                                  if (s.length < 6) {
                                    return TKeys.more_than_6.translate();
                                  }

                                  if (!s.isValidEmail()) {
                                    return TKeys.email_invalid.translate();
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFieldNormalCustom(
                              TKeys.password.translate(),
                              isRequired: true,
                              controller: controller.passwordCurrentController,
                              obscureText: true,
                              validator: (s) {
                                if (s == null || s.isEmpty) {
                                  return TKeys.dont_blank.translate();
                                }

                                if (s.length < 6 || s.length > 32) {
                                  return TKeys.more_than_6.translate();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFieldNormalCustom(
                              TKeys.confirm_password.translate(),
                              isRequired: true,
                              controller: controller.passwordNewController,
                              obscureText: true,
                              validator: (s) {
                                if (s == null || s.isEmpty) {
                                  return TKeys.dont_blank.translate();
                                }

                                if (s.length < 6 || s.length > 32) {
                                  return TKeys.more_than_6.translate();
                                }

                                if (controller.passwordCurrentController.text !=
                                    s) {
                                  return TKeys.password_not_match.translate();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            ButtonPrimary(TKeys.save.translate(),
                                onPress: () async {
                              if (formKey.currentState!.validate()) {
                                showDialogCustom(context, () async {
                                  var isValue =
                                      await controller.onUpdateProfile();
                                  if (!isValue) {
                                    EasyLoading.showError(
                                        TKeys.fail_again.translate(),
                                        duration: const Duration(seconds: 5));
                                  }
                                  // ignore: use_build_context_synchronously
                                  // ref.read(homeProvider.notifier).isInit = true;
                                  // ref.read(homeProvider.notifier).initData();

                                  Get.offAllNamed("/home");
                                }, question: TKeys.do_you_save.translate());
                              }
                            })
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ));
  }
}
