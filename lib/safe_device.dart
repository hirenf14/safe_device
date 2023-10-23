import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:trust_location/trust_location.dart';

class SafeDevice {
  static const MethodChannel _channel = const MethodChannel('safe_device');

  //Checks whether device JailBroken on iOS/Android?
  static Future<bool> get isJailBroken async {
    final bool isJailBroken = await _channel.invokeMethod('isJailBroken');
    return isJailBroken;
  }

  //Can this device mock location - no need to root!
  static Future<bool> get canMockLocation async {
    if (Platform.isAndroid) {
      return await TrustLocation.isMockLocation;
    } else {
      return !await isRealDevice || await isJailBroken;
    }
  }

  // Checks whether device is real or emulator
  static Future<bool> get isRealDevice async {
    final bool isRealDevice = await _channel.invokeMethod('isRealDevice');
    return isRealDevice;
  }

  // (ANDROID ONLY) Check if application is running on external storage
  static Future<bool> get isOnExternalStorage async {
    final bool isOnExternalStorage =
        await _channel.invokeMethod('isOnExternalStorage');
    return isOnExternalStorage;
  }

  // Check if device violates any of the above
  static Future<bool> get isSafeDevice async {
    // Mock location isn't working properly hence, it will be kept separate. and not here.
    // final bool canMockLocation = await SafeDevice.canMockLocation;
    final bool isJailBroken = await SafeDevice.isJailBroken;
    final bool isRealDevice = await SafeDevice.isRealDevice;
    // When its Android, only at that time it requires to check externalStorage.
    final bool isOnExternalStorage =
        Platform.isAndroid && await SafeDevice.isOnExternalStorage;
    return !isJail && isRealDevice && !isOnExternalStorage;
  }

  // (ANDROID ONLY) Check if development Options is enable on device
  static Future<bool> get isDevelopmentModeEnable async {
    final bool isDevelopmentModeEnable =
        await _channel.invokeMethod('isDevelopmentModeEnable');
    return isDevelopmentModeEnable;
  }
}
