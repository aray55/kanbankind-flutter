import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('English'),
            onTap: () {
              Get.updateLocale(const Locale('en', 'US'));
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('العربية'),
            onTap: () {
              Get.updateLocale(const Locale('ar', 'YE'));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
