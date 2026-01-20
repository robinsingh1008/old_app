// ignore_for_file: unused_element, depend_on_referenced_packages

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:old_book/firebase_options.dart';
import 'package:old_book/routes/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint("🚀 Initializing Google Mobile Ads...");
  await MobileAds.instance.initialize();
  debugPrint("✅ Google Mobile Ads initialized successfully");

  debugPrint("🚀 Initializing Firebase...");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("✅ Firebase initialized successfully");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    checkForUpdate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkForUpdate() async {
    if (kDebugMode) {
      print('checking for Update');
    }
    InAppUpdate.checkForUpdate()
        .then((info) {
          setState(() {
            if (info.updateAvailability == UpdateAvailability.updateAvailable) {
              if (kDebugMode) {
                print('update available');
              }
              update();
            }
          });
        })
        .catchError((e) {
          if (kDebugMode) {
            print(e.toString());
          }
        });
  }

  void update() async {
    if (kDebugMode) {
      print('Updating');
    }
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {
      if (kDebugMode) {
        print(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "6 Old Books",
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Montserrat'),
      getPages: AppRoutes.appRoutes(),
    );
  }
}
