import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';

class SocketService {
  late IO.Socket _socket;

  // Singleton
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  void init() {
    _socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect() // Connect manually
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('Socket Connected: ${_socket.id}');
    });

    _socket.onDisconnect((_) => print('Socket Disconnected'));

    _socket.onError((data) => print('Socket Error: $data'));
  }

  IO.Socket get socket => _socket;

  void disconnect() {
    _socket.disconnect();
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  void off(String event) {
    _socket.off(event);
  }
}
