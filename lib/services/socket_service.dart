import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;
  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;
  String IP_SERVER = '10.79.2.131';
  

  SocketService() {
    _initConfig();
  }
  void _initConfig() {
    // Dart client
    _socket = IO.io('http://$IP_SERVER:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.onConnect((_) {
      _serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }
}
