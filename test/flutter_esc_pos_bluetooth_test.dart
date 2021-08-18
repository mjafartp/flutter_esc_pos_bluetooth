import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_esc_pos_bluetooth/flutter_esc_pos_bluetooth.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_esc_pos_bluetooth');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterEscPosBluetooth.platformVersion, '42');
  });
}
