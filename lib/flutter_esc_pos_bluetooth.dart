import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'enums.dart';

class FlutterEscPosBluetooth {
  static const int STATE_OFF = 10;
  static const int STATE_TURNING_ON = 11;
  static const int STATE_ON = 12;
  static const int STATE_TURNING_OFF = 13;
  static const int STATE_BLE_TURNING_ON = 14;
  static const int STATE_BLE_ON = 15;
  static const int STATE_BLE_TURNING_OFF = 16;
  static const int ERROR = -1;
  static const int CONNECTED = 1;
  static const int DISCONNECTED = 0;

  static const String namespace = 'flutter_esc_pos_bluetooth';

  static const MethodChannel _channel =
  const MethodChannel('$namespace/methods');

  static const EventChannel _readChannel =
  const EventChannel('$namespace/read');

  static const EventChannel _stateChannel =
  const EventChannel('$namespace/state');

  final StreamController<MethodCall> _methodStreamController =
  new StreamController.broadcast();

  //Stream<MethodCall> get _methodStream => _methodStreamController.stream;

  FlutterEscPosBluetooth._() {
    _channel.setMethodCallHandler((MethodCall call) async {
      _methodStreamController.add(call);
    });
  }

  static FlutterEscPosBluetooth _instance = new FlutterEscPosBluetooth._();

  static FlutterEscPosBluetooth get instance => _instance;

  Stream<int?> onStateChanged() =>
      _stateChannel.receiveBroadcastStream().map((buffer) => buffer);

  Stream<String> onRead() =>
      _readChannel.receiveBroadcastStream().map((buffer) => buffer.toString());

  Future<bool?> get isAvailable async =>
      await _channel.invokeMethod('isAvailable');

  Future<bool?> get isOn async => await _channel.invokeMethod('isOn');

  Future<bool?> get isConnected async =>
      await _channel.invokeMethod('isConnected');

  Future<bool?> get openSettings async =>
      await _channel.invokeMethod('openSettings');

  Future<List<BluetoothDevice>> getBondedDevices() async {
    final List list = await (_channel.invokeMethod('getBondedDevices'));
    return list.map((map) => BluetoothDevice.fromMap(map)).toList();
  }

  Future<dynamic> connect(String device) =>
      _channel.invokeMethod('connect', {"address":device});

  Future<dynamic> disconnect() => _channel.invokeMethod('disconnect');

  Future<dynamic> writeBytes(List<int> message) =>
      _channel.invokeMethod('writeBytes', {'message': Uint8List.fromList(message)});

  Future<PosPrintResult> printTicket(List<int> message) async{
    await _channel.invokeMethod(
        'print', {'bytes':message});
    return PosPrintResult.success;
  }
}
class BluetoothDevice {
  final String? name;
  final String? address;
  final int type = 0;
  bool connected = false;

  BluetoothDevice(this.name, this.address);

  BluetoothDevice.fromMap(Map map)
      : name = map['name'],
        address = map['address'];

  Map<String, dynamic> toMap() => {
    'name': this.name,
    'address': this.address,
    'type': this.type,
    'connected': this.connected,
  };

  operator ==(Object other) {
    return other is BluetoothDevice && other.address == this.address;
  }

  @override
  int get hashCode => address.hashCode;
}
