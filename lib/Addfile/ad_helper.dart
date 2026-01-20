import 'dart:io';

class AdHelper {
  static bool get isTestMode {
    return true;
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9189593829339774/8982858165';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9189593829339774/1192832203';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9189593829339774/6995823221';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9189593829339774/5934571736';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeAdUnitId2 {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9189593829339774/5934571736';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String getNativeAdUnitIdForScreen(String screenId) {
    switch (screenId) {
      case 'dashboard':
        return nativeAdUnitId;
      case 'detail':
        return nativeAdUnitId2;
      case 'splash':
        return nativeAdUnitId;
      default:
        return nativeAdUnitId;
    }
  }

  static String getProductionNativeAdUnitID(String screenId) {
    if (Platform.isAndroid) {
      switch (screenId) {
        case 'dashboard':
          return 'ca-app-pub-9189593829339774/5934571736';
        case 'detail':
          return 'ca-app-pub-9189593829339774/5934571736';
        case 'splash':
          return 'ca-app-pub-9189593829339774/5934571736';
        default:
          return 'ca-app-pub-9189593829339774/5934571736';
      }
    }
    return '';
  }
}
