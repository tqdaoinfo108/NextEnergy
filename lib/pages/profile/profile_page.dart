import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v2/model/user_model.dart';
import 'package:v2/pages/customs/appbar.dart';
import 'package:v2/services/base_hive.dart';
import 'package:v2/services/localization_service.dart';
import 'package:v2/utils/const.dart';

import '../../services/https.dart';
import '../login/login_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String languageValue = "English";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    languageValue =
        HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en") == "en"
            ? "English"
            : "Việt Nam";
    toggleLanguage(HiveHelper.get(Constants.LANGUAGE_CODE, defaultvalue: "en"));
  }

  void toggleLanguage(String lang) {
    languageValue = lang == "en" ? "English" : "Việt Nam";
    setState(() {
      languageValue = languageValue;
      HiveHelper.put(Constants.LANGUAGE_CODE, lang);
    });
    HttpHelper.updateLanguageCode();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      // appBar: AppBarCustom(
      //   title: Text(
      //     TKeys.profile.translate(),
      //     style: theme.textTheme.headlineSmall?.copyWith(
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      // ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: CustomScrollView(
                slivers: [
                  // User Profile Header
                  SliverToBoxAdapter(
                    child: _buildUserProfileHeader(theme),
                  ),
            
                  // Account Section
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                        theme, TKeys.info_account.translate()),
                  ),
                  SliverToBoxAdapter(
                    child: _buildAccountSection(theme),
                  ),
            
                  // Settings Section
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(theme, TKeys.settings.translate()),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSettingsSection(theme),
                  ),
            
                  // Danger Zone Section
                  SliverToBoxAdapter(
                    child:
                        _buildSectionHeader(theme, TKeys.danger_zone.translate()),
                  ),
                  SliverToBoxAdapter(
                    child: _buildDangerSection(theme),
                  ),
            
                  // App Info Section
                  SliverToBoxAdapter(
                    child: _buildAppInfoSection(theme),
                  ),
            
                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              ),
          ),
    );
  } // User Profile Header với avatar và thông tin cơ bản

  Widget _buildUserProfileHeader(ThemeData theme) {
    // Lấy thông tin user từ Hive
    final fullName =
        HiveHelper.get(Constants.FULL_NAME, defaultvalue: "NextEnergy User");
    final phone = HiveHelper.get(Constants.PHONE, defaultvalue: "");
    final userId = HiveHelper.get(Constants.USER_ID, defaultvalue: "");
    final avatarUrl = HiveHelper.get(Constants.AVARTA, defaultvalue: "");

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: avatarUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userId != null 
                      ? TKeys.premium_member.translate()
                      : TKeys.premium_member.translate(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "⚡ ${TKeys.active_status.translate()}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit Profile Button
          IconButton(
            onPressed: () => Get.toNamed("/profile_detail"),
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  // Account Section
  Widget _buildAccountSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildModernMenuItem(
            theme,
            Icons.person_outline,
            TKeys.info_account.translate(),
            TKeys.manage_personal_information.translate(),
            () => Get.toNamed("/profile_detail"),
          ),
          _buildDivider(),
          _buildModernMenuItem(
            theme,
            Icons.card_membership_outlined,
            TKeys.member_code.translate(),
            TKeys.view_membership_details.translate(),
            () => Get.toNamed("/member_code"),
          ),
          _buildDivider(),
          _buildModernMenuItem(
            theme,
            Icons.payment_outlined,
            TKeys.payment_method.translate(),
            TKeys.manage_payment_methods.translate(),
            () async {
              String? result = await Get.toNamed("/pin_code_form",
                  arguments: "/payment_list") as String?;
              if (result != null && result.isNotEmpty) {
                Get.toNamed("/payment_list");
              }
            },
          ),
          _buildDivider(),
          _buildModernMenuItem(
            theme,
            Icons.devices_outlined,
            TKeys.session_device.translate(),
            TKeys.manage_connected_devices.translate(),
            () => Get.toNamed("/session_device"),
          ),
          _buildDivider(),
          _buildModernMenuItem(
            theme,
            Icons.lock_outline,
            TKeys.change_password.translate(),
            TKeys.update_your_password.translate(),
            () {
              Get.toNamed("/profile_change_pass",
                  arguments: UserModel()..loginType = LoginType.none);
            },
          ),
        ],
      ),
    );
  }

  // Settings Section
  Widget _buildSettingsSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLanguageMenuItem(theme),
          _buildDivider(),
          // _buildThemeMenuItem(theme),
        ],
      ),
    );
  }

  // Danger Zone Section
  Widget _buildDangerSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildModernMenuItem(
            theme,
            Icons.logout,
            TKeys.sign_out.translate(),
            TKeys.sign_out_from_account.translate(),
            () => letLogout(context),
            isDestructive: true,
          ),
          _buildDivider(),
          _buildModernMenuItem(
            theme,
            Icons.delete_forever_outlined,
            TKeys.delete_account.translate(),
            TKeys.permanently_delete_account.translate(),
            () => letDeleteAccount(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  // App Info Section
  Widget _buildAppInfoSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TKeys.version.translate(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "v1.0.0",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Menu Item
  Widget _buildModernMenuItem(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final textColor = isDestructive ? Colors.red : null;
    final iconColor = isDestructive ? Colors.red : theme.primaryColor;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  // Language Menu Item
  Widget _buildLanguageMenuItem(ThemeData theme) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.language,
          color: theme.primaryColor,
          size: 22,
        ),
      ),
      title: Text(
        TKeys.language.translate(),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        TKeys.choose_preferred_language.translate(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: buildSelectLanguage(context),
    );
  }

  // // Theme Menu Item
  // Widget _buildThemeMenuItem(ThemeData theme) {
  //   return ListTile(
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //     leading: Container(
  //       width: 40,
  //       height: 40,
  //       decoration: BoxDecoration(
  //         color: theme.primaryColor.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Icon(
  //         Get.isDarkMode ? Icons.dark_mode : Icons.light_mode,
  //         color: theme.primaryColor,
  //         size: 22,
  //       ),
  //     ),
  //     title: Text(
  //       TKeys.dark_mode.translate(),
  //       style: theme.textTheme.bodyLarge?.copyWith(
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //     subtitle: Text(
  //       TKeys.switch_theme_mode.translate(),
  //       style: theme.textTheme.bodySmall?.copyWith(
  //         color: Colors.grey.shade600,
  //       ),
  //     ),
  //     trailing: Switch(
  //       value: Get.isDarkMode,
  //       onChanged: (v) {
  //         Get.changeThemeMode(v ? ThemeMode.dark : ThemeMode.light);
  //         HiveHelper.put(Constants.IS_DARK_MODE, v);
  //         setState(() {}); // Refresh icon
  //       },
  //       activeColor: theme.primaryColor,
  //     ),
  //   );
  // }

  // Divider
  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 20,
      color: Colors.grey.shade200,
    );
  }

  DropdownButton<String> buildSelectLanguage(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButton<String>(
      value: languageValue,
      icon: Icon(
        Icons.expand_more,
        color: theme.primaryColor,
        size: 20,
      ),
      onChanged: (String? value) async {
        var lang = value == "English" ? "en" : "vi";
        await Get.updateLocale(Locale(lang, ""));
        toggleLanguage(lang);
      },
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(12),
      items: [
        DropdownMenuItem<String>(
          value: "English",
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🇺🇸", style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                "English",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        DropdownMenuItem<String>(
          value: "Việt Nam",
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🇻🇳", style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                "Việt Nam",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  letLogout(BuildContext cxt) {
    final theme = Theme.of(cxt);

    return showDialog<void>(
      context: cxt,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                TKeys.notification.translate(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            TKeys.logout_confirmation.translate(),
            style: theme.textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                TKeys.no.translate(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                setState(() {
                  _isLoading = true;
                });
                await _performLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(TKeys.yes.translate()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Unsubscribe từ Firebase messaging
      await FirebaseMessaging.instance
          .unsubscribeFromTopic("user${HiveHelper.get(Constants.USER_ID)}");

      // Xóa thông tin user
      HiveHelper.remove(Constants.USER_ID);
      HiveHelper.remove(Constants.LAST_LOGIN);
      HiveHelper.remove(Constants.PAYMENT_CARD);
      HiveHelper.remove(Constants.LOCAL_PIN_CODE);

      // Chuyển về trang login
      Get.offAllNamed("/login");
    } catch (e) {
      print("Error during logout: $e");
      // Vẫn chuyển về login dù có lỗi
      Get.offAllNamed("/login");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  letDeleteAccount(BuildContext cxt) {
    final theme = Theme.of(cxt);

    return showDialog<void>(
      context: cxt,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  TKeys.notification.translate(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TKeys.delete_account_message.translate(),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        TKeys.action_cannot_undone.translate(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                TKeys.no.translate(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                setState(() {
                  _isLoading = true;
                });

                var user = await HttpHelper.deleteAccount();
                if (user != null && user.data != null) {
                  await FirebaseMessaging.instance.unsubscribeFromTopic(
                      "user${HiveHelper.get(Constants.USER_ID)}");
                  HiveHelper.remove(Constants.USER_ID);
                  HiveHelper.remove(Constants.LAST_LOGIN);
                  HiveHelper.remove(Constants.PAYMENT_CARD);
                  HiveHelper.remove(Constants.LOCAL_PIN_CODE);
                  Get.offAllNamed("/login");
                }

                setState(() {
                  _isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(TKeys.yes.translate()),
            ),
          ],
        );
      },
    );
  }
}
