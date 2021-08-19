import 'dart:io';
import 'dart:typed_data';
import './testprint.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_esc_pos_bluetooth/flutter_esc_pos_bluetooth.dart';
import 'package:flutter/services.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  FlutterEscPosBluetooth bluetooth = FlutterEscPosBluetooth.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  late TestPrint testPrint;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // initSavetoPath();
    testPrint= TestPrint();
  }

  initSavetoPath()async{
    //read and write
    //image max 300px X 300px
    // final filename = 'yourlogo.png';
    // var bytes = await rootBundle.load("assets/images/yourlogo.png");
    // String dir = (await getApplicationDocumentsDirectory()).path;
    // writeToFile(bytes,'$dir/$filename');
    // setState(() {
    //   pathImage='$dir/$filename';
    // });
  }


  Future<void> initPlatformState() async {
    bool? isConnected=await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // TODO - Error
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case FlutterEscPosBluetooth.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case FlutterEscPosBluetooth.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if(isConnected??false) {
      setState(() {
        _connected=true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Blue Thermal Printer'),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 10,),
                    Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 30,),
                    Expanded(
                      child: DropdownButton<BluetoothDevice>(
                        items: _getDeviceItems(),
                        onChanged: (value) {
                          setState(() {
                            _device = value;
                          });
                        },
                         value: _device,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.brown,
                      onPressed:(){
                        initPlatformState();
                      },
                      child: Text('Refresh', style: TextStyle(color: Colors.white),),
                    ),
                    SizedBox(width: 20,),
                    RaisedButton(
                      color: _connected ?Colors.red:Colors.green,
                      onPressed:
                      _connected ? _disconnect : _connect,
                      child: Text(_connected ? 'Disconnect' : 'Connect', style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                  child:  RaisedButton(
                    color: Colors.brown,
                    onPressed:(){
                      testPrint.sample();
                    },
                    child: Text('PRINT TEST', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
        value: BluetoothDevice.fromMap({'name':'None','address':''}),
      ));
    } else {
      _devices.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text('${device.name}'),
          value: device,
        ));
      });
    }
    return items;
  }


  void _connect() {
    if (_device == null) {
      show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!(isConnected??false)) {
          print(_device);
          bluetooth.connect(_device!.address??'').catchError((error) {
            setState(() => _connected = false);
          });
          setState(() => _connected = true);
        }
      });
    }
  }


  void _disconnect() {
    bluetooth.disconnect();
    setState(() => _connected = true);
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future show(
      String message, {
        Duration duration: const Duration(seconds: 3),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    Scaffold.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}