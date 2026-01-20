import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdFrequencyManager {
  static const String _lastAdShownKey = 'last_ad_shown_timestamp';
  static const String _isFirstClickKey = 'is_first_click';
  static const String _randomIntervalKey = 'random_interval_minutes';

  // Minimum time between ads (in minutes) - random between 5-8 minutes
  static const int _minTimeBetweenAds = 5;
  static const int _maxTimeBetweenAds = 8;

  /// Check if an ad should be shown based on first click or time interval
  static Future<bool> shouldShowAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if this is the first click ever
      final isFirstClick = prefs.getBool(_isFirstClickKey) ?? true;

      if (isFirstClick) {
        // First click always shows ad
        await prefs.setBool(_isFirstClickKey, false);
        await prefs.setInt(
          _lastAdShownKey,
          DateTime.now().millisecondsSinceEpoch,
        );

        // Generate and store random interval for this session
        final randomMinutes =
            _minTimeBetweenAds +
            (DateTime.now().millisecond %
                (_maxTimeBetweenAds - _minTimeBetweenAds + 1));
        await prefs.setInt(_randomIntervalKey, randomMinutes);

        debugPrint(
          "AdFrequencyManager: First click - showing ad (next ad in $randomMinutes minutes)",
        );
        return true;
      }

      // For subsequent clicks, check time interval
      final lastAdShown = prefs.getInt(_lastAdShownKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeSinceLastAd =
          (currentTime - lastAdShown) / (1000 * 60); // in minutes

      // Get the stored random interval for this session
      final randomMinutes =
          prefs.getInt(_randomIntervalKey) ?? _minTimeBetweenAds;

      if (timeSinceLastAd >= randomMinutes) {
        // Update last ad shown timestamp
        await prefs.setInt(_lastAdShownKey, currentTime);
        debugPrint(
          "AdFrequencyManager: Time interval passed (${timeSinceLastAd.toStringAsFixed(1)} min >= $randomMinutes min) - showing ad",
        );
        return true;
      } else {
        final remainingTime = randomMinutes - timeSinceLastAd;
        debugPrint(
          "AdFrequencyManager: Time interval not passed (${timeSinceLastAd.toStringAsFixed(1)} min < $randomMinutes min) - no ad. Wait ${remainingTime.toStringAsFixed(1)} more minutes.",
        );
        return false;
      }
    } catch (e) {
      debugPrint("AdFrequencyManager error: $e");
      // If there's an error, default to showing ad occasionally
      return true;
    }
  }

  /// Check if an ad should be shown for dashboard navigation (less frequent)
  static Future<bool> shouldShowAdForDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dashboardLastAdKey = 'dashboard_last_ad_shown';
      final dashboardIntervalKey = 'dashboard_interval_minutes';

      // Dashboard ads should be less frequent - 10-15 minutes
      const int dashboardMinInterval = 10;
      const int dashboardMaxInterval = 15;

      // Check if this is the first dashboard navigation
      final isFirstDashboardClick =
          prefs.getBool('is_first_dashboard_click') ?? true;

      if (isFirstDashboardClick) {
        await prefs.setBool('is_first_dashboard_click', false);
        await prefs.setInt(
          dashboardLastAdKey,
          DateTime.now().millisecondsSinceEpoch,
        );

        final randomMinutes =
            dashboardMinInterval +
            (DateTime.now().millisecond %
                (dashboardMaxInterval - dashboardMinInterval + 1));
        await prefs.setInt(dashboardIntervalKey, randomMinutes);

        debugPrint(
          "AdFrequencyManager: First dashboard click - showing ad (next dashboard ad in $randomMinutes minutes)",
        );
        return true;
      }

      final lastDashboardAd = prefs.getInt(dashboardLastAdKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeSinceLastDashboardAd =
          (currentTime - lastDashboardAd) / (1000 * 60);

      final dashboardInterval =
          prefs.getInt(dashboardIntervalKey) ?? dashboardMinInterval;

      if (timeSinceLastDashboardAd >= dashboardInterval) {
        await prefs.setInt(dashboardLastAdKey, currentTime);
        debugPrint(
          "AdFrequencyManager: Dashboard interval passed - showing ad",
        );
        return true;
      } else {
        final remainingTime = dashboardInterval - timeSinceLastDashboardAd;
        debugPrint(
          "AdFrequencyManager: Dashboard interval not passed - wait ${remainingTime.toStringAsFixed(1)} more minutes",
        );
        return false;
      }
    } catch (e) {
      debugPrint("AdFrequencyManager dashboard error: $e");
      return false; // Don't show ads on error for dashboard
    }
  }

  /// Reset the ad frequency (useful for testing or user preferences)
  static Future<void> resetCounter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastAdShownKey);
      await prefs.remove(_isFirstClickKey);
      await prefs.remove(_randomIntervalKey);
      await prefs.remove('dashboard_last_ad_shown');
      await prefs.remove('dashboard_interval_minutes');
      await prefs.remove('is_first_dashboard_click');
      debugPrint(
        "AdFrequencyManager: Reset completed - next click will be treated as first click",
      );
    } catch (e) {
      debugPrint("AdFrequencyManager reset error: $e");
    }
  }

  /// Get time since last ad (for debugging)
  static Future<double> getTimeSinceLastAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAdShown = prefs.getInt(_lastAdShownKey) ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      return (currentTime - lastAdShown) / (1000 * 60); // in minutes
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if this is the first click (for debugging)
  static Future<bool> isFirstClick() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isFirstClickKey) ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Force show ad (for testing purposes)
  static Future<void> forceShowAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastAdShownKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint("AdFrequencyManager: Force show ad - timestamp updated");
    } catch (e) {
      debugPrint("AdFrequencyManager force show error: $e");
    }
  }

  /// Get current random interval (for debugging)
  static Future<int> getCurrentInterval() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_randomIntervalKey) ?? _minTimeBetweenAds;
    } catch (e) {
      return _minTimeBetweenAds;
    }
  }

  /// Set custom interval for testing (in seconds)
  static Future<void> setTestInterval(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_randomIntervalKey, seconds);
      debugPrint("AdFrequencyManager: Test interval set to $seconds seconds");
    } catch (e) {
      debugPrint("AdFrequencyManager set test interval error: $e");
    }
  }

  /// Set custom dashboard interval for testing (in seconds)
  static Future<void> setDashboardTestInterval(int seconds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('dashboard_interval_minutes', seconds);
      debugPrint(
        "AdFrequencyManager: Dashboard test interval set to $seconds seconds",
      );
    } catch (e) {
      debugPrint("AdFrequencyManager set dashboard test interval error: $e");
    }
  }

  /// Get current dashboard interval (for debugging)
  static Future<int> getCurrentDashboardInterval() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('dashboard_interval_minutes') ?? 10;
    } catch (e) {
      return 10;
    }
  }
}
