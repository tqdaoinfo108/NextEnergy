import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/pages/customs/button.dart';
import 'package:v2/pages/customs/dialog_custom.dart';
import 'package:v2/pages/customs/textfield_custom.dart';
import 'package:v2/pages/profile_detail/profile_detail_controller.dart';
import 'package:v2/utils/string_utils.dart';

import '../../services/localization_service.dart';
import '../customs/circular_progress_indicator.dart';

class ProfileDetailPage extends GetView<ProfileDetailController> {
  const ProfileDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers
    Widget _buildRegisterForm(BuildContext context) {
      var widthOfScreen = MediaQuery.of(context).size.width;
      return Form(
        key: controller.infoAccountKey,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    try {
                      final XFile? pickedFile =
                          await controller.pickerImage.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 600,
                        maxHeight: 600,
                        imageQuality: 80,
                      );
                      if (pickedFile != null) {
                        var userModel = await controller.updateAvatar(
                            base64Encode(await pickedFile.readAsBytes()));
                        controller.getProfile();
                      }
                    } catch (e) {}
                  },
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      (controller.userModel.value.imagesPaths?.isNotEmpty ?? false)
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 3,
                                      color: Colors.grey.shade500,
                                      spreadRadius: 1)
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48.0,
                                backgroundImage: MemoryImage(base64Decode(
                                    controller.userModel.value.imagesPaths!)),
                                backgroundColor: Colors.transparent,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 3,
                                      color: Colors.grey.shade500,
                                      spreadRadius: 1)
                                ],
                              ),
                              child: const CircleAvatar(
                                radius: 48.0,
                                backgroundImage:
                                    AssetImage("assets/images/user.png"),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.camera_enhance_outlined,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFieldCustom(
                  enabled: false,
                  controller: controller.phoneController,
                  TKeys.phone.translate(),
                ),
                const SizedBox(height: 8),
                TextFieldCustom(
                  TKeys.email.translate(),
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
                const SizedBox(height: 8),
                TextFieldCustom(
                  TKeys.full_name.translate(),
                  controller: controller.fullNameController,
                  validator: (s) {
                    if (s == null || s.isEmpty) {
                      return TKeys.dont_blank.translate();
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: widthOfScreen * 0.6,
                  child: ButtonPrimary(TKeys.save.translate(),
                      onPress: () async {
                    if (controller.infoAccountKey.currentState!.validate()) {
                      showDialogCustom(context, () async {
                        bool isSuccess = await controller.updateInfoAccount();
                        if (isSuccess) {
                          EasyLoading.showSuccess(
                              TKeys.success.translate(),
                              duration: const Duration(seconds: 5));
                          controller.getProfile();
                        } else {
                          EasyLoading.showError(
                              TKeys.fail.translate(),
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

    return Obx(() =>  Scaffold(
      appBar: AppBarCustom(
        title: Text(
          TKeys.info_account.translate(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: controller.isLoading.value
          ? const CircularProgressIndicatorCustom()
          : _buildRegisterForm(context),
    ));
  }
}
