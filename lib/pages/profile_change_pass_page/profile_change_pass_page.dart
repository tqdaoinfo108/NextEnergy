// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/button.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/pages/customs/textfield_custom.dart';
import 'package:v2/pages/profile_change_pass_page/profile_change_pass_controller.dart';
import '../../services/localization_service.dart';
import '../customs/circular_progress_indicator.dart';
import '../login/login_controller.dart';

class ProfileChangePassPage extends GetView<ProfileChangePassController> {
  const ProfileChangePassPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   

    Widget buildChangePassForm(BuildContext context) {
      var widthOfScreen = MediaQuery.of(context).size.width;
      return Form(
        key: controller.formKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 24),
                if (controller.userModel?.loginType != LoginType.forgetPassword)
                  Column(
                    children: [
                      TextFieldCustom(
                        TKeys.password_current.translate(),
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
                      const SizedBox(height: 24),
                    ],
                  ),
                TextFieldCustom(
                  TKeys.password_new.translate(),
                  controller: controller.passwordNewController,
                  obscureText: true,
                  validator: (s) {
                    if (s == null || s.isEmpty) {
                      return TKeys.dont_blank.translate();
                    }

                    if (s.length < 6) {
                      return TKeys.more_than_6.translate();
                    }
                  },
                ),
                const SizedBox(height: 24),
                TextFieldCustom(
                  TKeys.confirm_password.translate(),
                  obscureText: true,
                  validator: (s) {
                    if (s == null || s.isEmpty) {
                      return TKeys.dont_blank.translate();
                    }

                    if (s.length < 6 || s.length > 32) {
                      return TKeys.more_than_6.translate();
                    }

                    if (controller.passwordNewController.text != s) {
                      return TKeys.password_not_match.translate();
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: widthOfScreen * 0.6,
                  child: ButtonPrimary(TKeys.save.translate(),
                      onPress: () async {
                    if (controller.formKey.currentState!.validate()) {
                      showDialogCustom(context, () async {
                        var isSuccess = await controller.letChangePass();
                        if (isSuccess) {
                          EasyLoading.showSuccess(
                              TKeys.success.translate(),
                              duration: const Duration(seconds: 5));
                          if (controller.userModel!.loginType ==
                              LoginType.forgetPassword) {
                            Get.offAndToNamed("/login");
                          } else {
                            Navigator.pop(context);
                          }
                        } else {
                          EasyLoading.showError(
                              TKeys.password_incorrect
                                  .translate(),
                              duration: const Duration(seconds: 5));
                        }
                      });
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Obx (() => Scaffold(
      appBar: AppBarCustom(
        title: Text(
          TKeys.password.translate(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: controller.isLoading.value
          ? const CircularProgressIndicatorCustom()
          : buildChangePassForm(context),
    ));
  }
}
