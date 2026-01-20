// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:old_book/utils/comman_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:http/http.dart' as http;

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 1.5,
      shape: Border.all(color: Colors.white),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 60, bottom: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset("assets/icons/cross.png", scale: 2.5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Demo user",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed("/feedback_screen");
                    },
                    leading: Image.asset("assets/icon/icon.png", scale: 4),
                    title: Text(
                      "App Feedback/Rate Us",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 2),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed("/privacy_policy");
                    },
                    leading: Image.asset("assets/icon/icon.png", scale: 4),
                    title: Text(
                      "Legal/Privacy Policy",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 5),
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      checkLoginorNot();
                    },
                    leading: Image.asset("assets/icon/icon.png", scale: 4),
                    title: Text(
                      "Log Out",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  checkLoginorNot() async {
    CustomAlertDialog.show(
      context,
      'Log Out',
      'Are you sure you want to logout?',
      'Cancel',
      () {
        Get.back();
      },
      'Ok',
      () {
        Get.back();
        getProfileData();
      },
    );
  }

  Future<void> getProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("login");
    await prefs.remove("Persent");
    await prefs.remove("home_showcase_shown");
    exit(0);
  }
}
