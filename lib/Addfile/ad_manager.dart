import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:old_book/Addfile/ad_helper.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Track active ads by screen and position
  final Map<String, Map<int, NativeAd>> _activeAds = {};
  final Map<String, Map<int, bool>> _adLoadedStatus = {};
  final Map<String, Map<int, bool>> _isLoadingAd = {};
  final Map<String, Map<int, String?>> _adErrors = {};

  // Callbacks for UI updates
  final Map<String, Map<int, VoidCallback>> _updateCallbacks = {};

  // Create and load a native ad for a specific screen and position
  NativeAd createNativeAd(
    String screenId, {
    VoidCallback? onAdLoaded,
    int position = 0,
  }) {
    debugPrint(
      "Creating native ad for screen: $screenId at position: $position",
    );

    // Initialize maps if they don't exist
    _activeAds[screenId] ??= {};
    _adLoadedStatus[screenId] ??= {};
    _isLoadingAd[screenId] ??= {};
    _adErrors[screenId] ??= {};
    _updateCallbacks[screenId] ??= {};

    // Clear any previous errors
    _adErrors[screenId]![position] = null;

    // Prevent multiple simultaneous ad loads for the same screen and position
    if (_isLoadingAd[screenId]![position] == true) {
      debugPrint(
        "Ad already loading for screen: $screenId at position: $position",
      );
      return _activeAds[screenId]![position] ?? _createEmptyAd();
    }

    // Dispose existing ad for this screen and position if any
    disposeAd(screenId, position: position);

    // Reset status
    _adLoadedStatus[screenId]![position] = false;
    _isLoadingAd[screenId]![position] = true;

    // Store callback for UI updates
    if (onAdLoaded != null) {
      _updateCallbacks[screenId]![position] = onAdLoaded;
    }

    final ad = NativeAd(
      adUnitId: AdHelper.isTestMode
          ? AdHelper.getNativeAdUnitIdForScreen(screenId)
          : AdHelper.getProductionNativeAdUnitID(screenId),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint(
            "✅ Ad loaded successfully for screen: $screenId at position: $position",
          );
          debugPrint("Ad unit ID: ${ad.adUnitId}");
          debugPrint("Ad response info: ${ad.responseInfo}");
          _adLoadedStatus[screenId]![position] = true;
          _isLoadingAd[screenId]![position] = false;
          _adErrors[screenId]![position] = null;
          // Trigger UI update callback
          _updateCallbacks[screenId]![position]?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint(
            "❌ NativeAd failed to load for $screenId at position $position: $error",
          );
          debugPrint("Error code: ${error.code}");
          debugPrint("Error message: ${error.message}");
          debugPrint("Error domain: ${error.domain}");
          _adLoadedStatus[screenId]![position] = false;
          _isLoadingAd[screenId]![position] = false;
          _adErrors[screenId]![position] = error.message;
          ad.dispose();

          // Try to reload the ad after a delay if it's a network error
          if (error.code == 0 || error.code == 2) {
            // Network error or no fill
            debugPrint("Network error detected, will retry loading ad");
            Future.delayed(const Duration(seconds: 5), () {
              final isLoading = _isLoadingAd[screenId]?[position] ?? false;
              final isLoaded = _adLoadedStatus[screenId]?[position] ?? false;
              if (!isLoading && !isLoaded) {
                debugPrint("Retrying ad load after network error");
                createNativeAd(screenId, position: position);
              }
            });
          }

          // Trigger UI update callback
          _updateCallbacks[screenId]![position]?.call();
        },
        onAdClicked: (ad) {},
        onAdImpression: (ad) {},
        onAdClosed: (ad) {},
        onAdOpened: (ad) {},
        onAdWillDismissScreen: (ad) {},
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xfffffbed),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    );

    _activeAds[screenId]![position] = ad;
    _adLoadedStatus[screenId]![position] = false;

    ad.load();
    return ad;
  }

  // Create an empty ad for fallback
  NativeAd _createEmptyAd() {
    return NativeAd(
      adUnitId: 'ca-app-pub-3940256099942544/2247696110', // Test ad unit
      listener: NativeAdListener(
        onAdLoaded: (ad) {},
        onAdFailedToLoad: (ad, error) {},
        onAdClicked: (ad) {},
        onAdImpression: (ad) {},
        onAdClosed: (ad) {},
        onAdOpened: (ad) {},
        onAdWillDismissScreen: (ad) {},
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xfffffbed),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.italic,
          size: 16.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          style: NativeTemplateFontStyle.normal,
          size: 16.0,
        ),
      ),
    );
  }

  // Get ad for a specific screen and position
  NativeAd? getAd(String screenId, {int position = 0}) {
    return _activeAds[screenId]?[position];
  }

  // Check if ad is loaded for a specific screen and position
  bool isAdLoaded(String screenId, {int position = 0}) {
    return _adLoadedStatus[screenId]?[position] ?? false;
  }

  // Check if ad is valid and can be used
  bool isAdValid(String screenId, {int position = 0}) {
    final ad = _activeAds[screenId]?[position];
    return ad != null && _adLoadedStatus[screenId]?[position] == true;
  }

  // Check if ad is currently loading
  bool isAdLoading(String screenId, {int position = 0}) {
    return _isLoadingAd[screenId]?[position] ?? false;
  }

  // Check if ad has an error
  bool hasAdError(String screenId, {int position = 0}) {
    return _adErrors[screenId]?[position] != null;
  }

  // Get ad error message
  String? getAdError(String screenId, {int position = 0}) {
    return _adErrors[screenId]?[position];
  }

  // Dispose ad for a specific screen and position
  void disposeAd(String screenId, {int position = 0}) {
    final ad = _activeAds[screenId]?[position];
    if (ad != null) {
      debugPrint("Disposing ad for screen: $screenId at position: $position");
      try {
        ad.dispose();
      } catch (e) {
        debugPrint(
          "Error disposing ad for $screenId at position $position: $e",
        );
      }
      _activeAds[screenId]?.remove(position);
      _adLoadedStatus[screenId]?.remove(position);
      _isLoadingAd[screenId]?.remove(position);
      _adErrors[screenId]?.remove(position);
      _updateCallbacks[screenId]?.remove(position);
    }
  }

  // Dispose all ads for a screen
  void disposeAllAdsForScreen(String screenId) {
    if (_activeAds[screenId] != null) {
      for (final ad in _activeAds[screenId]!.values) {
        try {
          ad.dispose();
        } catch (e) {
          debugPrint("Error disposing ad: $e");
        }
      }
      _activeAds.remove(screenId);
      _adLoadedStatus.remove(screenId);
      _isLoadingAd.remove(screenId);
      _adErrors.remove(screenId);
      _updateCallbacks.remove(screenId);
    }
  }

  // Dispose all ads
  void disposeAllAds() {
    for (final screenAds in _activeAds.values) {
      for (final ad in screenAds.values) {
        try {
          ad.dispose();
        } catch (e) {
          debugPrint("Error disposing ad: $e");
        }
      }
    }
    _activeAds.clear();
    _adLoadedStatus.clear();
    _isLoadingAd.clear();
    _adErrors.clear();
    _updateCallbacks.clear();
  }

  // Create AdWidget with proper key for a specific screen and position
  Widget createAdWidget(String screenId, {int position = 0}) {
    debugPrint("🎯 Creating AdWidget for $screenId at position $position");
    try {
      final ad = getAd(screenId, position: position);
      debugPrint("Ad object: $ad");
      debugPrint("Is ad loaded: ${isAdLoaded(screenId, position: position)}");

      if (ad != null && isAdLoaded(screenId, position: position)) {
        // Use a STABLE key per screen+position to avoid multiple AdWidgets with same ad in one frame
        final stableKey = ValueKey('${screenId}ad$position');
        debugPrint("✅ Creating AdWidget with key: $stableKey");
        return AdWidget(key: stableKey, ad: ad);
      } else {
        debugPrint(
          "❌ Ad is null or not loaded for $screenId at position $position",
        );
      }
    } catch (e) {
      debugPrint(
        "Error creating AdWidget for $screenId at position $position: $e",
      );
      // If there's an error, dispose the ad and return empty widget
      disposeAd(screenId, position: position);
    }
    return const SizedBox.shrink();
  }

  // Create a smart ad widget that handles loading, error, and success states
  Widget createSmartAdWidget(String screenId, {int position = 0}) {
    debugPrint(
      "🔍 Creating smart ad widget for $screenId at position $position",
    );
    debugPrint("Is loading: ${isAdLoading(screenId, position: position)}");
    debugPrint("Has error: ${hasAdError(screenId, position: position)}");
    debugPrint("Is valid: ${isAdValid(screenId, position: position)}");
    debugPrint("Is loaded: ${isAdLoaded(screenId, position: position)}");

    // If ad is loading, show shimmer
    if (isAdLoading(screenId, position: position)) {
      debugPrint("📱 Showing shimmer for $screenId at position $position");
      return _buildShimmerAd();
    }

    // If ad has error, try to reload it instead of showing error
    if (hasAdError(screenId, position: position)) {
      debugPrint(
        "❌ Ad has error for $screenId at position $position, attempting to reload",
      );
      // Clear the error and try to reload
      _adErrors[screenId]?[position] = null;
      _isLoadingAd[screenId]?[position] = false;
      _adLoadedStatus[screenId]?[position] = false;

      // Try to create a new ad
      createNativeAd(screenId, position: position);
      return _buildShimmerAd(); // Show loading while retrying
    }

    // If ad is valid, show the ad
    if (isAdValid(screenId, position: position)) {
      debugPrint("✅ Showing ad widget for $screenId at position $position");
      try {
        return createAdWidget(screenId, position: position);
      } catch (e) {
        debugPrint(
          "Error creating ad widget for $screenId at position $position: $e",
        );
        // If there's an error creating the widget, dispose the ad and show placeholder
        disposeAd(screenId, position: position);
        return _buildPlaceholderAd();
      }
    }

    // If no ad available, try to create one
    debugPrint(
      "📄 No ad available for $screenId at position $position, creating new ad",
    );
    createNativeAd(screenId, position: position);
    return _buildShimmerAd(); // Show loading while creating
  }

  // Build shimmer loading effect for ads
  Widget _buildShimmerAd() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  // Build placeholder for when no ad is available
  Widget _buildPlaceholderAd() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Center(
        child: Text(
          'Advertisement',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Force refresh ad for a specific screen and position
  void forceRefreshAd(
    String screenId, {
    VoidCallback? onAdLoaded,
    int position = 0,
  }) {
    if (_isLoadingAd[screenId]?[position] == true) {
      debugPrint(
        "Ad refresh skipped - already loading for $screenId at position $position",
      );
      return;
    }

    disposeAd(screenId, position: position);
    // Small delay to ensure disposal is complete
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_isLoadingAd[screenId]?[position] != true) {
        createNativeAd(screenId, onAdLoaded: onAdLoaded, position: position);
      }
    });
  }

  // Check if ad exists for a screen and position
  bool hasAd(String screenId, {int position = 0}) {
    return _activeAds[screenId]?.containsKey(position) ?? false;
  }

  // Get the number of ads for a screen
  int getAdCount(String screenId) {
    return _activeAds[screenId]?.length ?? 0;
  }

  // Force clear all errors and retry loading ads for a screen
  void forceRetryAdsForScreen(String screenId) {
    debugPrint("Force retrying ads for screen: $screenId");
    if (_activeAds[screenId] != null) {
      // Dispose all existing ads
      for (final ad in _activeAds[screenId]!.values) {
        try {
          ad.dispose();
        } catch (e) {
          debugPrint("Error disposing ad: $e");
        }
      }
      _activeAds.remove(screenId);
      _adLoadedStatus.remove(screenId);
      _isLoadingAd.remove(screenId);
      _adErrors.remove(screenId);
      _updateCallbacks.remove(screenId);
    }

    // Recreate ads
    createNativeAd(screenId, position: 0);
  }

  // Clear all errors for a screen
  void clearErrorsForScreen(String screenId) {
    debugPrint("Clearing errors for screen: $screenId");
    if (_adErrors[screenId] != null) {
      _adErrors[screenId]!.clear();
    }
  }
}
