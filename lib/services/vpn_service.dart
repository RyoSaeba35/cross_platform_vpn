import 'package:flutter/services.dart';

class VpnService {
  static const MethodChannel _platform = MethodChannel('com.vulcain.vpn/control');

  static Future<bool> startVpn() async {
    try {
      return await _platform.invokeMethod('startVpn');
    } on PlatformException catch (e) {
      throw Exception("Failed to start VPN: ${e.message}");
    }
  }

  static Future<bool> stopVpn() async {
    try {
      return await _platform.invokeMethod('stopVpn');
    } on PlatformException catch (e) {
      throw Exception("Failed to stop VPN: ${e.message}");
    }
  }

  static Future<bool> getStatus() async {
    try {
      return await _platform.invokeMethod('getStatus');
    } on PlatformException catch (e) {
      throw Exception("Failed to get VPN status: ${e.message}");
    }
  }
}
