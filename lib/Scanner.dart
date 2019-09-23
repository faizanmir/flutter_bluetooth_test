import 'dart:async';
import 'dart:core';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothScanner {
  List<BluetoothDevice> bluetoothDeviceList;
  FlutterBlue flutterBlue;
  StreamSubscription scanResult;

  BluetoothScanner(this.flutterBlue,this.bluetoothDeviceList);

 List<BluetoothDevice >scanForDevices() {
   bool isScanning = true;

    scanResult = flutterBlue.scan().listen((scanResult) {
     if(!bluetoothDeviceList.contains(scanResult))
      bluetoothDeviceList.add(scanResult.device);
    });
    scanResult.onDone(()
    {
      isScanning = false;

    });

    if(!isScanning)
      {
        return bluetoothDeviceList;
      }
    else
      {
        return new List<BluetoothDevice>();
      }
  }

  void cancelScan()
  {
    scanResult.cancel();

  }
}
