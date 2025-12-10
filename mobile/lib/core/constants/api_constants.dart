import 'package:flutter/material.dart';

import 'dart:io';

class ApiConstants {
  // Use localhost for iOS simulator, or specific IP for physical device
  // static const String baseUrl = 'http://127.0.0.1:5000/api';
  // static const String socketUrl = 'http://127.0.0.1:5000';

  // For standard emulator use 10.0.2.2, for iOS simulator use 127.0.0.1
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

  static String get socketUrl {
    if (Platform.isAndroid) {
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
}
