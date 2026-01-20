import 'package:get/get.dart';
import 'package:old_book/screen/detail_page.dart';
import 'package:old_book/screen/dashboard.dart';
import 'package:old_book/screen/open_pdf.dart';

import 'package:old_book/splash_screen.dart';

import 'routes_name.dart';

class AppRoutes {
  static appRoutes() => [
    GetPage(
      name: RouteName.SplashScreen,
      page: () => const SplashScreen(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade,
    ),
    GetPage(
      name: RouteName.Dashboard,
      page: () => const Dashboard(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade,
    ),
    GetPage(
      name: RouteName.DetailPage,
      page: () => const DetailPage(routeName: "", title: ""),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade,
    ),
    GetPage(
      name: RouteName.OpenPdf,
      page: () => const OpenPdf(),
      transitionDuration: const Duration(milliseconds: 250),
      transition: Transition.leftToRightWithFade,
    ),
  ];
}
