import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use localhost for iOS simulator, or specific IP for physical device
  // static const String baseUrl = 'http://127.0.0.1:5000/api';
  // static const String socketUrl = 'http://127.0.0.1:5000';

  // For standard emulator use 10.0.2.2, for iOS simulator use 127.0.0.1
  // Configuration: Set to true when testing on physical device
  // Set to false when using emulator
  static const bool _usePhysicalDevice = false;

  // Your computer's local IP address (find with: ipconfig on Windows, ifconfig on Mac/Linux)
  // Make sure phone and computer are on the same WiFi network!
  static const String _deviceIpAddress =
      '192.168.220.36'; // ✅ Your Ethernet IPv4 Address

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    if (Platform.isAndroid) {
      // Physical device: use computer's IP address
      // Emulator: use 10.0.2.2 (special emulator localhost)
      if (_usePhysicalDevice) {
        return 'http://$_deviceIpAddress:5000/api';
      }
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

  static String get socketUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    if (Platform.isAndroid) {
      if (_usePhysicalDevice) {
        return 'http://$_deviceIpAddress:5000';
      }
      return 'http://10.0.2.2:5000';
    }
    return 'http://127.0.0.1:5000';
  }

  // Endpoints
  static const String registerGuest = '/guests/register';
  static const String loginGuest = '/guests/login';
  static const String menu = '/menu';
  static const String orders = '/orders';
  static const String myOrders = '/orders/my';
  static const String paymentCheckout = '/payments/checkout';
  static const String paymentStatus = '/payments/status';
  static const String feedback = '/feedbacks';
}
